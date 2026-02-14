import SwiftUI

struct BottomActionsView: View {
    @Environment(UIScheme.self) var scheme
    
    var body: some View {
        VStack {
            SettingsLink()
            
            Button {
                NSApp.orderFrontStandardAboutPanel(nil)
            } label: {
                Label(UITexts.Actions.about, systemImage: scheme.aboutImage)
            }
            
            Divider()
            Button(UITexts.Actions.quit) {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
