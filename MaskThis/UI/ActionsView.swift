import SwiftUI
import KeyboardShortcuts

struct ActionsView: View {
    @Environment(ClipboardManager.self) var clipboardManager
    @Environment(UIScheme.self) var scheme

    @State var disabled: Bool = false
    var body: some View {
        Button {
            disabled = true
            Task(priority: .userInitiated) {
                _ = await clipboardManager.maskClipboard()
                disabled = false
            }
        } label: {
            Label(UITexts.Actions.mask, systemImage: scheme.eyeDisabledImage)
        }
        .disabled(disabled || !clipboardManager.canMask)
        .globalKeyboardShortcut(.maskClipboardContent)
    }
}
