import SwiftUI
import FoundationModels

@MainActor
@Observable
class AppModel {
    var appStatus: AppStatus = .ready
    var aiStatus: AppleIntelligenceStatus = .ready
    var modelState: ModelState = .prepare
    
    var lastError: String?
}

enum AppStatus {
    case ready
    case processing
}

enum AppleIntelligenceStatus {
    case ready
    case unavailable(reason: SystemLanguageModel.Availability.UnavailableReason)
}

enum ModelState {
    case prepare
    case downloading(fraction: Double)
    case error(text: String)
    case ready
    case paused
    
    var isReady: Bool {
        if case .ready = self {
            return true
        }
        return false
    }
}
