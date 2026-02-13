import SwiftUI

struct ReadyView: View {
    @Environment(UIScheme.self) var scheme
    
    var body: some View {
        Label(UITexts.Statuses.readyStatus, systemImage: scheme.readyImage)
    }
}
