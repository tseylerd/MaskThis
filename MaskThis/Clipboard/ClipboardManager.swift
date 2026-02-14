import SwiftUI
import OSLog
import KeyboardShortcuts

@MainActor
@Observable
class ClipboardManager {
    private static nonisolated let LOG = Logger(subsystem: Subsystems.CLIPBOARD, category: "ClipboardManager")
    
    private let model: AppModel
    private let aiMonitor: AIMonitor
    private let notificationsManager: CustomNotificationManager
    
    @ObservationIgnored
    private var currentChangeCount: Int = 0
    
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
    
    init(_ appModel: AppModel, _ aiMonitor: AIMonitor, _ notificationsManager: CustomNotificationManager) {
        self.model = appModel
        self.aiMonitor = aiMonitor
        self.notificationsManager = notificationsManager
        
        KeyboardShortcuts.onKeyUp(for: .maskClipboardContent) {
            Task(priority: .userInitiated) {
                await self.maskClipboard()
            }
        }
    }
    
    func subscribeOnChanges() {
        self.currentChangeCount = NSPasteboard.general.changeCount
        Task.detached(priority: .background) {
            while true {
                await Util.delay(.milliseconds(500))
                
                guard await AppSettings.shared.auto else {
                    await Util.delay(.seconds(1))
                    continue
                }
                
                if let duration = await self.maskClipboard() {
                    await Util.delay(duration)
                }
            }
        }
    }
    
    func maskClipboard() async -> Duration? {
        guard canMask else {
            Self.LOG.info("App is not ready")
            return .seconds(1)
        }
        
        guard let engine = self.aiMonitor.inference else {
            Self.LOG.info("Model adapter is not loaded")
            return .seconds(1)
        }
        
        await self.processClipboard(engine)
        return nil
    }
    
    private func processClipboard(_ engine: AIInferenceEngine) async {
        let newCount = NSPasteboard.general.changeCount
        guard newCount != currentChangeCount else {
            return
        }

        Self.LOG.info("Processing clipboard")

        model.lastError = nil
        self.currentChangeCount = newCount
        
        guard let items = NSPasteboard.general.pasteboardItems else {
            return
        }
        
        var newItems: [NSPasteboardItem] = []
        var toMask: String? = nil
        for item in items {
            guard item.isTextType else {
                newItems.append(item)
                continue
            }
            guard let string = item.asString() else {
                continue
            }
            toMask = string
        }
        guard let toMask else {
            Self.LOG.info("Nothing to mask")
            return
        }
        
        
        model.appStatus = .processing
        defer {
            model.appStatus = .ready
        }
        
        var sessionId: UUID? = nil
        if AppSettings.shared.showNotification {
            sessionId = await notificationsManager.show(
                NotificationData(
                    title: UITexts.Notifications.maskingSensitiveInformation,
                    subtitle: nil,
                    note: nil,
                    type: .info,
                    autoClose: false,
                    progress: true
                )
            )
        }
        
        let processedText = await Task.detached(priority: .high) {
            await self.processText(engine, toMask)
        }.value
        
        guard let processedText else {
            Self.LOG.info("Processed text is nil")
            if let sessionId {
                notificationsManager.hide(sessionId)
            }
            return
        }
        
        let changesCountNow = NSPasteboard.general.changeCount
        guard changesCountNow == newCount else {
            Self.LOG.info("Noticed change in between")
            if let sessionId {
                notificationsManager.hide(sessionId)
            }
            return
        }
        
        currentChangeCount = NSPasteboard.general.changeCount
        
        guard processedText.trimmingCharacters(in: .whitespacesAndNewlines) != toMask.trimmingCharacters(in: .whitespacesAndNewlines) else {
            Self.LOG.info("Text wasn't masked")
            _ = await notificationsManager.show(
                NotificationData(
                    title: UITexts.Notifications.nothingMasked,
                    subtitle: nil,
                    note: nil,
                    type: .info,
                    autoClose: true,
                    progress: false
                )
            )
            return
        }
        
        let newItem = NSPasteboardItem()
        
        newItem.setData(processedText.data(using: .utf8)!, forType: .string)
        newItems.append(newItem)
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects(newItems)

        Self.LOG.info("Setting new items")
        
        if AppSettings.shared.showNotification {
            _ = await notificationsManager.show(
                NotificationData(
                    title: UITexts.Notifications.successfullyMasked,
                    subtitle: nil,
                    note: UITexts.Notifications.successfullyMaskedNote,
                    type: .info,
                    autoClose: true,
                    progress: false
                )
            )
        }
    }
    
    private nonisolated func processText(_ engine: AIInferenceEngine, _ text: String) async -> String? {
        do {
            Self.LOG.info("Running AI...")
            return try await engine.mask(text)
        } catch {
            Self.LOG.error("Error sanitizing text: \(error.localizedDescription)")
            if await AppSettings.shared.showNotification {
                _ = await notificationsManager.show(NotificationData(title: UITexts.Notifications.error, subtitle: error.localizedDescription, note: nil, type: .error, autoClose: true, progress: false))
            }
            await MainActor.run {
                model.lastError = error.localizedDescription
            }
            return nil
        }
    }
}

fileprivate extension NSPasteboardItem {
    var isTextType: Bool {
        types.contains(.string) ||
        types.contains(.html) ||
        types.contains(.fileContents) ||
        types.contains(.rtf) ||
        types.contains(.tabularText)
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
