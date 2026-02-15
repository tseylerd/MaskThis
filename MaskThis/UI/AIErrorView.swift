import SwiftUI
import FoundationModels

struct AIErrorView: View {
    @Environment(UIScheme.self) var scheme
    let reason: SystemLanguageModel.Availability.UnavailableReason
    
    var body: some View {
        if case .appleIntelligenceNotEnabled = reason {
            Label {
                Text(UITexts.Statuses.Errors.appleIntelligenceNotEnabled)
                    .foregroundColor(scheme.errorTextColor)
            } icon: {
                Image(systemName: scheme.warningImage)
            }
        } else if case .deviceNotEligible = reason {
            Label {
                Text(UITexts.Statuses.Errors.appleIntelligenceNotSupported)
                    .foregroundColor(scheme.errorTextColor)
            } icon: {
                Image(systemName: scheme.warningImage)
            }
        } else if case .modelNotReady = reason {
            Label {
                Text(UITexts.Statuses.Errors.appleIntelligenceLoading)
                    .foregroundColor(scheme.errorTextColor)
            } icon: {
                Image(systemName: scheme.warningImage)
            }
        }
    }
}
