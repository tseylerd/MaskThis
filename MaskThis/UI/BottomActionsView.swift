import SwiftUI

struct BottomActionsView: View {
    var body: some View {
        VStack {
            SettingsLink()
            
            Button(UITexts.Actions.quit) {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
