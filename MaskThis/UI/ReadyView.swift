import SwiftUI

struct ReadyView: View {
    @Environment(UIScheme.self) var scheme
    
    var body: some View {
        HStack {
            Circle()
                .fill(scheme.readyStatusColor)
                .frame(width: 4, height: 4)
            Text(UITexts.Statuses.readyStatus)
        }
    }
}
