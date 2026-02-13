import SwiftUI

struct AutoModeStatusView: View {
    @Environment(UIScheme.self) var scheme
    
    var body: some View {
        Label(UITexts.Statuses.autoModeStatus, systemImage: scheme.autoModeImage)
    }
}
