import SwiftUI

struct MenuView: View {
    var body: some View {
        VStack {
            StatusView()
            
            Divider()
            OptionsView()
            Divider()
            
            Button(UITexts.Actions.quit) {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
