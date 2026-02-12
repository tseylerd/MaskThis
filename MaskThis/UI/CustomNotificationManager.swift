import SwiftUI

@MainActor
class CustomNotificationManager {
    static let shared = CustomNotificationManager()
    
    private var sessionId: UUID? = nil
    private var window: NSWindow? = nil
    
    func show(_ data: NotificationData) async {
        window?.close()
        window = nil
        
        let newSessionId = UUID()
        sessionId = newSessionId
        
        let view = NotificationView(data: data).fixedSize()
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
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.5
            newWindow.animator().alphaValue = 0
        } completionHandler: { [weak newWindow] in
            guard let newWindow else {
                return
            }
            DispatchQueue.main.async {
                if newSessionId == self.sessionId {
                    newWindow.close()
                    self.window = nil
                }
            }
        }
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
