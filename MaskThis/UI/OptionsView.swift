import SwiftUI

struct OptionsView: View {
    @Environment(AppSettingsModel.self) var settings
    
    let hints: Bool
    
    var body: some View {
        @Bindable var settings = self.settings
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 4) {
                Toggle(UITexts.Toggles.auto, isOn: $settings.auto)
                if hints {
                    Text(UITexts.Toggles.autoDescription)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Toggle(UITexts.Toggles.showProgressNotifications, isOn: $settings.showProgressNotification)
                if hints {
                    Text(UITexts.Toggles.showProgressNotificationsDescription)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Toggle(UITexts.Toggles.showResultNotifications, isOn: $settings.showResultNotification)
                if hints {
                    Text(UITexts.Toggles.showResultNotificationsDescription)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            
            Toggle(UITexts.Toggles.launchAtLogin, isOn: $settings.launchAtLogin)
        }
    }
}
