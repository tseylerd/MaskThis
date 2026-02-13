import SwiftUI

struct ProcessingStatusView: View {
    @Environment(UIScheme.self) var scheme
    
    var body: some View {
        Label(UITexts.Statuses.progressStatus, systemImage: scheme.progressImage)
    }
}
