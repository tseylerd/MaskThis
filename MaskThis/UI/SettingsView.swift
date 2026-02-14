import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
    @Environment(UIScheme.self) var scheme
    @Environment(AppSettingsModel.self) var settingsModel

    var body: some View {
        @Bindable var settingsModel = self.settingsModel
        TabView(selection: $settingsModel.tab) {
            Tab(UITexts.Settings.General.tabName, systemImage: scheme.generalSettingsImage, value: .general) {
                GeneralTabView()
            }
            Tab(UITexts.Settings.OSS.tabName, systemImage: scheme.ossSettingsImage, value: .ossSoftware) {
                OpenSourceSoftwareTabView()
            }
        }
        .scenePadding()
        .frame(maxWidth: 800, maxHeight: 600)
        .frame(width: 800, height: 600)
    }
}

fileprivate struct GeneralTabView: View {
    var body: some View {
        Form {
            VStack {
                HStack {
                    Text(UITexts.Settings.General.shortcut)
                    KeyboardShortcuts.Recorder(for: .maskClipboardContent)
                }
                Text(UITexts.Settings.General.shortcutDescription)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

fileprivate struct OpenSourceSoftwareTabView: View {
    var body: some View {
        Form {
            LicensesView()
        }
    }
}
