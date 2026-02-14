import SwiftUI

struct OptionsView: View {
    @Environment(AppSettingsModel.self) var settings
    
    var body: some View {
        @Bindable var settings = self.settings
        VStack(alignment: .leading) {
            Toggle(UITexts.Toggles.auto, isOn: $settings.auto)
            Toggle(UITexts.Toggles.showNotifications, isOn: $settings.showNotification)
            Toggle(UITexts.Toggles.launchAtLogin, isOn: $settings.launchAtLogin)
        }
    }
}
