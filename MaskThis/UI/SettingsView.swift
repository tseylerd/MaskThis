import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
    @Environment(UIScheme.self) var scheme
    
    @State var tab: SettingsTab = .general
    
    var body: some View {
        TabView(selection: $tab) {
            Tab(UITexts.Settings.General.tabName, systemImage: scheme.generalSettingsImage, value: .general) {
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
        .scenePadding()
        .frame(maxWidth: 800, maxHeight: 600)
        .frame(width: 800, height: 600)
    }
}

enum SettingsTab: Hashable {
    case general
}
