import SwiftUI
import FoundationModels

struct AIErrorView: View {
    @Environment(UIScheme.self) var scheme
    let reason: SystemLanguageModel.Availability.UnavailableReason
    
    var body: some View {
        if case .appleIntelligenceNotEnabled = reason {
            Label(UITexts.Statuses.Errors.appleIntelligenceNotEnabled, systemImage: scheme.warningImage)
        } else if case .deviceNotEligible = reason {
            Label(UITexts.Statuses.Errors.appleIntelligenceNotSupported, systemImage: scheme.warningImage)
        } else if case .modelNotReady = reason {
            Label(UITexts.Statuses.Errors.appleIntelligenceLoading, systemImage: scheme.warningImage)
        }
    }
}
