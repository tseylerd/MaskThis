import SwiftUI

struct DisabledView: View {
    @Environment(UIScheme.self) var scheme
    
    var body: some View {
        HStack {
            Circle()
                .fill(scheme.disabledStatusColor)
                .frame(width: 4, height: 4)
            Text(UITexts.Statuses.disabledStatus)
        }
    }
}
