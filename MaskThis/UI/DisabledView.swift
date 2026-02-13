import SwiftUI

struct DisabledView: View {
    @Environment(UIScheme.self) var scheme
    
    var body: some View {
        Label(UITexts.Statuses.disabledStatus, systemImage: scheme.noImage)
    }
}
