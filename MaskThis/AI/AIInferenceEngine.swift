import FoundationModels
import Foundation

@MainActor
class AIInferenceEngine {
    private static let MAX_TOKENS = 512
    private static let MAX_LENGTH = Util.tokensToSymbols(2048)
    
    private static let PROMPTS = Util.loadPrompts()
    
    let model: SystemLanguageModel
    
    init(_ model: SystemLanguageModel) {
        self.model = model
    }
    
    func mask(_ text: String) async throws -> String {
        guard text.count < Self.MAX_LENGTH else {
            throw InferenceError.textIsTooBig
        }
        
        let maxSymbols = Util.tokensToSymbols(Self.MAX_TOKENS)
        
        var result = ""
        let chunks = split(text, maxSymbols)
        for chunk in chunks {
            let session = LanguageModelSession(model: model)
            result += try await session.respond(to: Util.embed(text: chunk, to: Self.PROMPTS.mask.user), generating: String.self).content
        }
        return result
    }
    
    private func split(_ text: String, _ chunkSize: Int) -> [String] {
        var result: [String] = []
        for i in stride(from: 0, to: text.count, by: chunkSize) {
            let startIndex = text.index(text.startIndex, offsetBy: i)
            let endIndex = text.index(text.startIndex, offsetBy: min(i + chunkSize, text.count))
            result.append(String(text[startIndex..<endIndex]))
        }
        return result
    }
}

struct PromptsCollection {
    let mask: AIPrompt
}

struct AIPrompt {
    let instructions: String
    let user: String
}
