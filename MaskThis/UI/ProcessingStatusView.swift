import SwiftUI

struct ProcessingStatusView: View {
    var body: some View {
        HStack {
            ProgressView()
            Text(UITexts.Statuses.progressStatus)
        }
    }
}
