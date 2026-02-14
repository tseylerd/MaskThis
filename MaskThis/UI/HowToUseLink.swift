import SwiftUI

struct HowToUseLink: View {
    @Environment(\.openWindow) var openWindow
    @Environment(UIScheme.self) var scheme
    
    var body: some View {
        Button {
            openWindow(id: Constants.WindowID.howToUse)
        } label: {
            Label(UITexts.Actions.howToUse, systemImage: scheme.howToUseImage)
        }
    }
}
