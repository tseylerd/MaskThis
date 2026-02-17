import SwiftUI
import OSLog
import KeyboardShortcuts

@MainActor
@Observable
class ClipboardManager {
    private static nonisolated let LOG = Logger(subsystem: Subsystems.CLIPBOARD, category: "ClipboardManager")
    
    private let model: AppModel
    private let settingsModel: AppSettingsModel
    private let aiMonitor: AIMonitor
    private let notificationsManager: CustomNotificationManager
    
    @ObservationIgnored
    private var lastState: ClipboardState?
    @ObservationIgnored
    private var aiTask: Task<String?, Never>?
    @ObservationIgnored
    private var inferenceId: UUID?
    @ObservationIgnored
    private var mainTask: Task<Void, Never>?
    
    var canMask: Bool {
        guard case .ready = self.model.appStatus else {
            return false
        }
        
        guard case .ready = self.model.aiStatus else {
            return false
        }
        
        guard let _ = self.aiMonitor.inference else {
            return false
        }
        
        return true
    }
    
    init(_ appModel: AppModel, _ aiMonitor: AIMonitor, _ settingsModel: AppSettingsModel, _ notificationsManager: CustomNotificationManager) {
        self.model = appModel
        self.aiMonitor = aiMonitor
        self.notificationsManager = notificationsManager
        self.settingsModel = settingsModel
        
        KeyboardShortcuts.onKeyUp(for: .maskClipboardContent) {
            Task(priority: .userInitiated) {
                await self.maskClipboard()
            }
        }
    }
    
    func pullActualState() {
        self.lastState = ClipboardState(changes: NSPasteboard.general.changeCount, string: nil)
    }
    
    func subscribeOnChanges() {
        self.lastState = ClipboardState(changes: NSPasteboard.general.changeCount, string: nil)
        mainTask = Task.detached(priority: .background) {
            while !Task.isCancelled {
                await Util.delay(.milliseconds(500))
                
                guard await self.settingsModel.auto else {
                    await Util.delay(.seconds(1))
                    continue
                }
                
                if let duration = await self.maskClipboardTry() {
                    await Util.delay(duration)
                }
            }
        }
    }
    
    func maskClipboard() async {
        _ = await self.maskClipboardInternal(RequestedMaskingStrategy(), NotificationsStrategy(settingsModel, notificationsManager, true, true))
    }
    
    private func maskClipboardTry() async -> Duration? {
        return await self.maskClipboardInternal(AutoMaskingStrategy(), NotificationsStrategy(settingsModel, notificationsManager, false, false))
    }
    
    private func maskClipboardInternal(_ maskingStrategy: MaskingStrategy, _ notificationsStrategy: NotificationsStrategy) async -> Duration? {
        guard canMask else {
            Self.LOG.info("App is not ready")
            return .seconds(1)
        }
        
        guard let engine = self.aiMonitor.inference else {
            Self.LOG.info("Model adapter is not loaded")
            return .seconds(1)
        }
        
        await self.processClipboard(engine, maskingStrategy, notificationsStrategy)
        return nil
    }
    
    private func processClipboard(_ engine: AIInferenceEngine, _ maskingStrategy: MaskingStrategy, _ notificationsStrategy: NotificationsStrategy) async {
        guard let checkpoint = maskingStrategy.acquire(lastState) else {
            return
        }

        let newCount = checkpoint.currentChangeCount
        Self.LOG.info("Processing clipboard on change count: \(newCount)")

        model.lastError = nil
        
        guard let (toMask, toLeave) = findTextToMask(), let toMask else {
            Self.LOG.info("Failed to find text in clipboard")
            lastState = ClipboardState(changes: newCount, string: nil)
            notificationsStrategy.showNoTextFound()
            return
        }

        guard maskingStrategy.makesSenseToMask(lastState, toMask) else {
            lastState = ClipboardState(changes: newCount, string: toMask)
            Self.LOG.info("Text is not changed")
            return
        }
        
        lastState = ClipboardState(changes: newCount, string: toMask)
        
        let myInferenceId = UUID()
        self.inferenceId = myInferenceId
        model.appStatus = .processing
        defer {
            model.appStatus = .ready
        }
        
        let notificationLifetime = notificationsStrategy.showProgress(NotificationData(
            title: UITexts.Notifications.maskingSensitiveInformation,
            subtitle: nil,
            note: UITexts.Notifications.maskingSensitiveInformationNote,
            type: .info,
            autoClose: false,
            progress: true
        ) { id in
            if self.inferenceId == myInferenceId {
                self.aiTask?.cancel()
                self.notificationsManager.hide(id)
            }
        })
        
        let task = Task(priority: .userInitiated) {
            await self.processText(engine, toMask, notificationsStrategy)
        }
        
        self.aiTask = task
        
        let processedText: String? = await task.value
        
        guard !task.isCancelled else {
            Self.LOG.info("Task is cancelled")
            notificationLifetime?.close()
            return
        }
        
        guard let processedText else {
            Self.LOG.info("Processed text is nil")
            notificationLifetime?.close()
            return
        }
        
        if let (currentTextToMask, _) = findTextToMask(), currentTextToMask != toMask {
            Self.LOG.info("Text changed while processing")
            notificationsStrategy.showTextChange()
            notificationLifetime?.close()
            return
        }
        
        guard inferenceId == myInferenceId else {
            Self.LOG.info("New inference invoked")
            notificationLifetime?.close()
            return
        }
        
        guard processedText.trimmingCharacters(in: .whitespacesAndNewlines) != toMask.trimmingCharacters(in: .whitespacesAndNewlines) else {
            Self.LOG.info("Text wasn't masked")
            _ = notificationsStrategy.showResult(
                NotificationData(
                    title: UITexts.Notifications.nothingMasked,
                    subtitle: nil,
                    note: nil,
                    type: .info,
                    autoClose: true,
                    progress: false,
                ) { id in
                    self.notificationsManager.hide(id)
                }
            )
            notificationLifetime?.close()
            return
        }
        
        Self.LOG.info("Setting new items")
        let newItem = NSPasteboardItem()
        var newItems: [NSPasteboardItem] = Array(toLeave)
        
        newItem.setData(processedText.data(using: .utf8)!, forType: .string)
        newItems.append(newItem)
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects(newItems)
        
        lastState = ClipboardState(changes: NSPasteboard.general.changeCount, string: processedText)
        
        _ = notificationsStrategy.showResult(
            NotificationData(
                title: UITexts.Notifications.successfullyMasked,
                subtitle: nil,
                note: UITexts.Notifications.successfullyMaskedNote,
                type: .info,
                autoClose: true,
                progress: false
            ) { id in
                self.notificationsManager.hide(id)
            }
        )
        notificationLifetime?.close()
    }
    
    private nonisolated func findTextToMask() -> (String?, [NSPasteboardItem])? {
        guard let items = NSPasteboard.general.pasteboardItems else {
            return nil
        }
        
        var itemsToLeave: [NSPasteboardItem] = []
        var toMask: String? = nil
        for item in items {
            guard !item.isTypeToSkip else {
                return nil
            }
            
            guard item.isTextType else {
                itemsToLeave.append(item)
                continue
            }
            guard let string = item.asString() else {
                continue
            }
            toMask = string
        }
        return (toMask, itemsToLeave)
    }
    
    private func processText(_ engine: AIInferenceEngine, _ text: String, _ notificationsStrategy: NotificationsStrategy) async -> String? {
        do {
            Self.LOG.info("Running AI...")
            return try await Task.withTimeout(duration: .seconds(60)) {
                try await engine.mask(text)
            }
        } catch _ as CancellationError {
            Self.LOG.info("Cancelled inference")
            return nil
        } catch _ as TimeoutError {
            Self.LOG.info("Timeout")
            _ = notificationsStrategy.showResult(
                NotificationData(title: UITexts.Notifications.error, subtitle: UITexts.Statuses.Errors.timeoutWhileMasking, note: nil, type: .error, autoClose: true, progress: false) { id in
                    self.notificationsManager.hide(id)
                }
            )
            return nil
        } catch {
            Self.LOG.error("Error sanitizing text: \(error.localizedDescription)")
            _ = notificationsStrategy.showResult(NotificationData(title: UITexts.Notifications.error, subtitle: error.localizedDescription, note: nil, type: .error, autoClose: true, progress: false) { id in
                self.notificationsManager.hide(id)
            })
            await MainActor.run {
                model.lastError = error.localizedDescription
            }
            return nil
        }
    }
}

fileprivate nonisolated extension NSPasteboardItem {
    var isTextType: Bool {
        types.contains(.string) ||
        types.contains(.html) ||
        types.contains(.rtf) ||
        types.contains(.tabularText)
    }
    
    var isTypeToSkip: Bool {
        types.contains(.fileURL) ||
        types.contains(.fileContents) ||
        types.contains(.URL) ||
        types.contains(.pdf) ||
        types.contains(.png) ||
        types.contains(.sound) ||
        types.contains(.tiff)
    }
    
    func asString() -> String? {
        guard types.contains(.string) else {
            return nil
        }
        
        guard let string = data(forType: .string) else {
            return nil
        }
        
        return String(data: string, encoding: .utf8)
    }
}

fileprivate struct ClipboardState {
    let changes: Int
    let string: String?
}

fileprivate protocol MaskingStrategy {
    var id: String {
        get
    }
    
    func acquire(_ state: ClipboardState?) -> (any MaskingCheckpoint)?
    func makesSenseToMask(_ state: ClipboardState?, _ newText: String) -> Bool
}

fileprivate protocol MaskingCheckpoint {
    var currentChangeCount: Int {
        get
    }
}

fileprivate class AutoMaskingStrategy: MaskingStrategy {
    var id: String = "Auto"
    
    func acquire(_ state: ClipboardState?) -> (any MaskingCheckpoint)? {
        let newCount = NSPasteboard.general.changeCount
        return newCount != state?.changes ? MaskingCheckpointImpl(currentChangeCount: newCount) : nil
    }
    
    func makesSenseToMask(_ state: ClipboardState?, _ newText: String) -> Bool {
        return state?.string != newText
    }
}

fileprivate class RequestedMaskingStrategy: MaskingStrategy {
    var id: String = "Requested"
    
    func acquire(_ state: ClipboardState?) -> (any MaskingCheckpoint)? {
        return MaskingCheckpointImpl(currentChangeCount: NSPasteboard.general.changeCount)
    }
    
    func makesSenseToMask(_ state: ClipboardState?, _ newText: String) -> Bool {
        true
    }
}

fileprivate struct MaskingCheckpointImpl: MaskingCheckpoint {
    var currentChangeCount: Int
}

fileprivate class NotificationsStrategy {
    private let settings: AppSettingsModel
    private let manager: CustomNotificationManager
    private let isShowNoText: Bool
    private let isShowTextChanged: Bool
    
    init(_ settings: AppSettingsModel, _ manager: CustomNotificationManager, _ showNoTextFound: Bool, _ showTextChanged: Bool) {
        self.settings = settings
        self.manager = manager
        self.isShowNoText = showNoTextFound
        self.isShowTextChanged = showTextChanged
    }
    
    func showTextChange() {
        guard isShowTextChanged else {
            return
        }
        
        let data = NotificationData(
            title: UITexts.Notifications.textChanged,
            subtitle: nil,
            note: nil,
            type: .info,
            autoClose: true,
            progress: false
        ) { id in
            self.manager.hide(id)
        }
        
        _ = manager.show(data)
    }
    
    func showNoTextFound() {
        guard isShowNoText else {
            return
        }
        
        let data = NotificationData(
            title: UITexts.Notifications.noTextFound,
            subtitle: nil,
            note: nil,
            type: .info,
            autoClose: true,
            progress: false
        ) { id in
            self.manager.hide(id)
        }
        
        _ = manager.show(data)
    }
    
    func showProgress(_ data: NotificationData) -> NotificationLifetime? {
        guard settings.showProgressNotification else {
            return nil
        }
        
        return manager.show(data)
    }
    
    func showResult(_ data: NotificationData) -> NotificationLifetime? {
        guard settings.showResultNotification else {
            return nil
        }
        
        return manager.show(data)
    }
}
