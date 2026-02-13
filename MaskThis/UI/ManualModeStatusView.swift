import SwiftUI

struct ManualModeStatusView: View {
    @Environment(UIScheme.self) var scheme
    @Environment(ClipboardManager.self) var clipboardManager
    
    @State var enabled: Bool = true
    
    var body: some View {
        Label(UITexts.Statuses.manualModeStatus, systemImage: scheme.manualModeImage)
    }
}
