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
    private var lastState: ClipboardState?
    
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
        self.lastState = ClipboardState(changes: NSPasteboard.general.changeCount, string: nil)
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
        guard newCount != lastState?.changes else {
            return
        }

        Self.LOG.info("Processing clipboard on change count: \(newCount)")

        model.lastError = nil
        
        guard let (toMask, toLeave) = findTextToMask(), let toMask else {
            Self.LOG.info("Failed to find text in clipboard")
            lastState = ClipboardState(changes: newCount, string: nil)
            return
        }

        guard lastState?.string != toMask else {
            lastState = ClipboardState(changes: newCount, string: toMask)
            Self.LOG.info("Text is not changed")
            return
        }
        
        lastState = ClipboardState(changes: newCount, string: toMask)
        
        model.appStatus = .processing
        defer {
            model.appStatus = .ready
        }
        
        var sessionId: UUID? = nil
        if AppSettings.shared.showProgressNotification {
            sessionId = notificationsManager.show(
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
        
        let processedText = await self.processText(engine, toMask)
        
        guard let processedText else {
            Self.LOG.info("Processed text is nil")
            if let sessionId {
                notificationsManager.hide(sessionId)
            }
            return
        }
        
        if let (currentTextToMask, _) = findTextToMask(), currentTextToMask != toMask {
            Self.LOG.info("Text changed while processing")
            if let sessionId {
                notificationsManager.hide(sessionId)
            }
            return
        }
        
        guard processedText.trimmingCharacters(in: .whitespacesAndNewlines) != toMask.trimmingCharacters(in: .whitespacesAndNewlines) else {
            Self.LOG.info("Text wasn't masked")
            if AppSettings.shared.showResultNotification {
                _ = notificationsManager.show(
                    NotificationData(
                        title: UITexts.Notifications.nothingMasked,
                        subtitle: nil,
                        note: nil,
                        type: .info,
                        autoClose: true,
                        progress: false
                    )
                )
            } else if let sessionId {
                notificationsManager.hide(sessionId)
            }
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
        
        if AppSettings.shared.showResultNotification {
            _ = notificationsManager.show(
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
    
    private nonisolated func findTextToMask() -> (String?, [NSPasteboardItem])? {
        guard let items = NSPasteboard.general.pasteboardItems else {
            return nil
        }
        
        var itemsToLeave: [NSPasteboardItem] = []
        var toMask: String? = nil
        for item in items {
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
    
    private func processText(_ engine: AIInferenceEngine, _ text: String) async -> String? {
        do {
            Self.LOG.info("Running AI...")
            return try await engine.mask(text)
        } catch {
            Self.LOG.error("Error sanitizing text: \(error.localizedDescription)")
            if AppSettings.shared.showResultNotification {
                _ = await notificationsManager.show(NotificationData(title: UITexts.Notifications.error, subtitle: error.localizedDescription, note: nil, type: .error, autoClose: true, progress: false))
            }
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

fileprivate struct ClipboardState {
    let changes: Int
    let string: String?
}
