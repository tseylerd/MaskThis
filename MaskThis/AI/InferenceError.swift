import Foundation

enum InferenceError: LocalizedError {
    case textIsTooBig
    
    var errorDescription: String? {
        switch self {
        case .textIsTooBig:
            return UITexts.Statuses.Errors.tooBigText
        }
    }
}
