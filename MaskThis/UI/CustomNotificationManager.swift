import SwiftUI

@MainActor
@Observable
class CustomNotificationManager {
    @ObservationIgnored
    private var sessionId: UUID? = nil
    @ObservationIgnored
    private var window: NSWindow? = nil
    
    private let appSettingsModel: AppSettingsModel
    private let scheme: UIScheme
    
    init(appSettingsModel: AppSettingsModel, scheme: UIScheme) {
        self.appSettingsModel = appSettingsModel
        self.scheme = scheme
    }
    
    func hide(_ sessionId: UUID) {
        guard sessionId == self.sessionId else {
            return
        }
        
        guard let window else {
            return
        }
        
        hide(sessionId, window) {
            self.window = nil
        }
    }
    
    private func hide(_ sessionId: UUID, _ window: NSWindow, _ onFinish: @escaping () -> Void) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.5
            window.animator().alphaValue = 0
        } completionHandler: { [weak window] in
            guard let window else {
                return
            }
            DispatchQueue.main.async {
                if sessionId == self.sessionId {
                    window.close()
                    onFinish()
                }
            }
        }
    }
    
    func show(_ data: NotificationData) -> UUID {
        window?.close()
        window = nil
        
        let newSessionId = UUID()
        sessionId = newSessionId
        
        Task(priority: .userInitiated) { @MainActor in
            guard self.sessionId == newSessionId else {
                return
            }
            
            let view = NotificationView(data: data)
                .environment(appSettingsModel)
                .environment(scheme)
                .fixedSize()
            let hostingController = NSHostingController(rootView: view)
            let newWindow = NSWindow(
                contentRect: NSRect(
                    x: 0,
                    y: 0,
                    width: 200,
                    height: 100
                ),
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )
                
            newWindow.contentViewController = hostingController
            newWindow.backgroundColor = .clear
            newWindow.hasShadow = false
            newWindow.level = .floating
            newWindow.ignoresMouseEvents = true
            newWindow.isReleasedWhenClosed = false
            newWindow.center()
            
            let targetSize = hostingController.sizeThatFits(in: CGSize(width: CGFloat.infinity, height: CGFloat.infinity))
            newWindow.setContentSize(targetSize)
            newWindow.alphaValue = 0
            if let targetPoint = calculatePosition(relativeTo: targetSize) {
                newWindow.setFrameOrigin(targetPoint)
            }
            
            newWindow.orderFront(nil)
            self.window = newWindow
            
            await NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.5
                context.timingFunction = CAMediaTimingFunction(name: .default)
                
                newWindow.animator().alphaValue = 1.0
            }
            
            await Util.delay(.seconds(3))
            
            guard newSessionId == sessionId else {
                return
            }
            
            guard data.autoClose else {
                return
            }
            
            hide(newSessionId, newWindow) {
                self.window = nil
            }
            
        }
        
        return newSessionId
    }
    
    private func calculatePosition(relativeTo size: CGSize) -> NSPoint? {
        guard let screen = NSScreen.main else {
            return nil
        }
        let screenRect = screen.visibleFrame
        let x = screenRect.midX - (size.width / 2)
        let y = screenRect.minY + 100
        return NSPoint(x: x, y: y)
    }
}
