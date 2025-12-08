import SwiftUI
import FoundationModels

struct AIErrorView: View {
    @Environment(UIScheme.self) var scheme
    let reason: SystemLanguageModel.Availability.UnavailableReason
    
    var body: some View {
        if case .appleIntelligenceNotEnabled = reason {
            Text(UITexts.Statuses.Errors.appleIntelligenceNotEnabled)
        } else if case .deviceNotEligible = reason {
            Text(UITexts.Statuses.Errors.appleIntelligenceNotSupported)
        } else if case .modelNotReady = reason {
            HStack {
                ProgressView()
                Text(UITexts.Statuses.Errors.appleIntelligenceLoading)
            }
        }
    }
}
