import SwiftUI

struct ManualModeStatusView: View {
    @Environment(UIScheme.self) var scheme
    
    var body: some View {
        Label(UITexts.Statuses.manualModeStatus, systemImage: scheme.manualModeImage)
    }
}
