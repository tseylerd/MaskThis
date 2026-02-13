import SwiftUI

struct MenuView: View {
    var body: some View {
        VStack {
            StatusView()
            ActionsView()
            Divider()
            OptionsView()
            Divider()
            
            Button(UITexts.Actions.quit) {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
