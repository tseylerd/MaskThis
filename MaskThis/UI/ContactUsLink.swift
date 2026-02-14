import SwiftUI

struct ContactUsLink: View {
    @Environment(UIScheme.self) var scheme
    
    var body: some View {
        Button {
            if let url = URL(string: "mailto:devemail") {
                NSWorkspace.shared.open(url)
            }
        } label: {
            Label(UITexts.Actions.contactUs, systemImage: scheme.feedbackImage)
        }
    }
}
