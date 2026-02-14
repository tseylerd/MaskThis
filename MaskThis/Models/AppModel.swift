import SwiftUI
import FoundationModels

@MainActor
@Observable
class AppModel {
    var appStatus: AppStatus = .ready
    private(set) var aiStatus: AppleIntelligenceStatus = .ready
    var modelState: ModelState = .prepare
    
    var lastError: String?
    
    func markAppleIntelligenceReady() {
        if case .ready = aiStatus {
            return
        }
        
        aiStatus = .ready
    }
    
    func markAppleIntelligenceUnavailable(_ reason: SystemLanguageModel.Availability.UnavailableReason) {
        if case .unavailable(let myReason) = aiStatus {
            if myReason == reason {
                return
            }
        }
        
        aiStatus = .unavailable(reason: reason)
    }
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
