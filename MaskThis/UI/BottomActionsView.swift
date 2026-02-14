import SwiftUI

struct BottomActionsView: View {
    @Environment(UIScheme.self) var scheme
    @Environment(AppSettingsModel.self) var settingsModel
    
    @Environment(\.openSettings) var openSettings
    var body: some View {
        VStack {
            SettingsLink()
            Menu {
                HowToUseLink()
                
                ContactUsLink()
                RateAppLink()
                
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
            } label: {
                Label(UITexts.Actions.help, systemImage: scheme.helpImage)
            }
            
            Divider()
            Button(UITexts.Actions.quit) {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
