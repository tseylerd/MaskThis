import SwiftUI
import StoreKit

struct RateAppLink: View {
    @Environment(UIScheme.self) var scheme
    @Environment(\.requestReview) var requestReview

    var body: some View {
        Button {
            requestReview()
        } label: {
            Label(UITexts.Actions.rateApp, systemImage: scheme.rateAppImage)
        }
    }
}
