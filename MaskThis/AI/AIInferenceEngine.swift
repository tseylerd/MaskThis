import FoundationModels
import Foundation

@MainActor
class AIInferenceEngine {
    private static let MAX_TOKENS = 512
    private static let MAX_LENGTH = Util.tokensToSymbols(2048)
    
    let model: SystemLanguageModel
    
    private let preprocessor: TextProcessor
    private let postProcessor: TextProcessor
    
    init(_ model: SystemLanguageModel) {
        self.model = model
        self.preprocessor = InputPreprocessor()
        self.postProcessor = OutputProcessor()
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
            let localResult = try await session.respond(to: preprocessor.process(chunk), generating: String.self, options: GenerationOptions(temperature: 0.1)).content
            result += postProcessor.process(localResult)
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

protocol TextProcessor {
    func process(_ string: String) -> String
}

fileprivate class InputPreprocessor: TextProcessor {
    fileprivate static let PREFIX = "[RAW] "
    
    func process(_ string: String) -> String {
        "\(Self.PREFIX)\(string)"
    }
}

fileprivate class OutputProcessor: TextProcessor {
    func process(_ string: String) -> String {
        if string.starts(with: InputPreprocessor.PREFIX) {
            String(string.suffix(string.count - InputPreprocessor.PREFIX.count))
        } else {
            string
        }
    }
}
