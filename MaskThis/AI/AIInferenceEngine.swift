import FoundationModels
import Foundation

actor AIInferenceEngine {
    private static let MAX_TOKENS = 512
    private static let MAX_OUTPUT_TOKENS = 768
    private static let MAX_LENGTH = Util.tokensToSymbols(MAX_TOKENS)
    
    private let model: SystemLanguageModel
    private let preprocessor: TextProcessor
    private let postProcessor: TextProcessor
    
    init(_ model: SystemLanguageModel) async {
        self.model = model
        self.preprocessor = await InputPreprocessor()
        self.postProcessor = await OutputProcessor()
    }
    
    func mask(_ text: String) async throws -> String {
        guard text.count < Self.MAX_LENGTH else {
            throw InferenceError.textIsTooBig
        }
        
        try Task.checkCancellation()
        
        let session = LanguageModelSession(model: model)
        try Task.checkCancellation()
        
        let localResult = try await session.respond(to: preprocessor.process(text), generating: String.self, options: GenerationOptions(temperature: 0.2, maximumResponseTokens: Self.MAX_OUTPUT_TOKENS)).content
        try Task.checkCancellation()
        
        return await postProcessor.process(localResult)
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
