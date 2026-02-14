import SwiftUI

struct MenuView: View {
    var body: some View {
        VStack {
            StatusView()
            ActionsView()
            Divider()
            OptionsView(hints: false)
            Divider()
            BottomActionsView()
        }
    }
}
