import FoundationModels
import Foundation

@MainActor
class AIInferenceEngine {
    private static let PROMPTS = Util.loadPrompts()
    
    let model: SystemLanguageModel
    
    init(_ model: SystemLanguageModel) {
        self.model = model
    }
    
    func mask(_ text: String) async throws -> String {
        let session = LanguageModelSession(model: model)
        return try await session.respond(to: Util.embed(text: text, to: Self.PROMPTS.mask.user), generating: String.self).content
    }
}

struct PromptsCollection {
    let mask: AIPrompt
}

struct AIPrompt {
    let instructions: String
    let user: String
}
