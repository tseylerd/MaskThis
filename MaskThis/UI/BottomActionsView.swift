import SwiftUI

struct BottomActionsView: View {
    @Environment(UIScheme.self) var scheme
    @Environment(AppSettingsModel.self) var settingsModel
    
    @Environment(\.openSettings) var openSettings
    var body: some View {
        VStack {
            SettingsLink()
            Button {
                settingsModel.tab = .ossSoftware
                openSettings()
            } label: {
                Label(UITexts.Actions.ossUsed, systemImage: scheme.ossSettingsImage)
            }
            Button {
                NSApp.orderFrontStandardAboutPanel(nil)
            } label: {
                Label(UITexts.Actions.about, systemImage: scheme.aboutImage)
            }

            ContactUsLink()
            RateAppLink()
            Divider()
            Button(UITexts.Actions.quit) {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
