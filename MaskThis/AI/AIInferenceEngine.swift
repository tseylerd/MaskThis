import FoundationModels
import Foundation

actor AIInferenceEngine {
    static nonisolated let MAX_LENGTH = Util.tokensToSymbols(2048)
    static nonisolated let MAX_CHUNKS = 4
    static nonisolated let CHUNK_SIZE = Util.tokensToSymbols(MAX_TOKENS)
    static nonisolated let SENTENCE_SEPARATORS: [Character] = [".", ";", "?", "!"]
    
    private static let MAX_TOKENS = 512
    private static let MAX_OUTPUT_TOKENS = 768
    
    private let maxChunkLength: Int
    private let model: SystemLanguageModel
    private let preprocessor: TextPreprocessor
    
    init(_ model: SystemLanguageModel, _ maxChunkLength: Int = CHUNK_SIZE) async {
        self.maxChunkLength = maxChunkLength
        self.model = model
        self.preprocessor = InputPreprocessor()
    }
    
    func mask(_ text: String) async throws -> String {
        guard text.count < Self.MAX_LENGTH else {
            throw InferenceError.textIsTooBig
        }
        
        try Task.checkCancellation()
        
        let chunks = Chunker.chunks(from: text, by: Self.SENTENCE_SEPARATORS, withMaxSybolsOf: maxChunkLength)
        guard chunks.count <= Self.MAX_CHUNKS else {
            throw InferenceError.textIsTooBig
        }
        
        var result = ""
        for chunk in chunks {
            guard !chunk.isEmptyOrSpaces else {
                result += chunk
                continue
            }
            
            let session = LanguageModelSession(model: model)
            try Task.checkCancellation()
            
            let preprocessingResult = preprocessor.process(chunk)
            let localResult = try await session.respond(to: preprocessingResult.string, generating: String.self, options: GenerationOptions(temperature: 0.2, maximumResponseTokens: Self.MAX_OUTPUT_TOKENS)).content
            
            try Task.checkCancellation()
            result += preprocessingResult.postprocessor.process(localResult)
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

nonisolated protocol TextPreprocessor {
    func process(_ string: String) -> PreprocessorResult
}

nonisolated protocol TextPostprocessor {
    func process(_ string: String) -> String
}

nonisolated struct PreprocessorResult {
    let string: String
    let postprocessor: TextPostprocessor
}

fileprivate nonisolated class InputPreprocessor: TextPreprocessor {
    fileprivate static let PREFIX = "[RAW] "
    
    func process(_ string: String) -> PreprocessorResult {
        guard !string.isEmptyOrSpaces else {
            return PreprocessorResult(string: "", postprocessor: OutputProcessor(string, nil))
        }
        
        let startOfMeaningfulContent = string.startOfMeaningfulContent()
        let endOfMeaningfulContent = string.endOfMeaningfulContent()
        
        guard let startOfMeaningfulContent else {
            guard let endOfMeaningfulContent else {
                return PreprocessorResult(string: "", postprocessor: OutputProcessor(string, nil))
            }
            
            let postSpaces = endOfMeaningfulContent == string.endIndex ? nil : String(string[endOfMeaningfulContent..<string.endIndex])
            let resultString = endOfMeaningfulContent == string.endIndex ? string : String(string[string.startIndex..<endOfMeaningfulContent])
            
            return PreprocessorResult(string: appendPrefix(resultString), postprocessor: OutputProcessor(nil, postSpaces))
        }
        
        let preSpaces = String(string[string.startIndex..<startOfMeaningfulContent])
        guard let endOfMeaningfulContent else {
            let resultString = String(string[startOfMeaningfulContent..<string.endIndex])
            return PreprocessorResult(string: appendPrefix(resultString), postprocessor: OutputProcessor(preSpaces, nil))
        }
        
        let postSpaces = endOfMeaningfulContent == string.endIndex ? nil : String(string[endOfMeaningfulContent..<string.endIndex])
        let resultString = String(string[startOfMeaningfulContent..<endOfMeaningfulContent])
        return PreprocessorResult(string: appendPrefix(resultString), postprocessor: OutputProcessor(preSpaces, postSpaces))
    }
    
    private func appendPrefix(_ string: String) -> String {
        "\(Self.PREFIX)\(string)"
    }
}

fileprivate nonisolated class OutputProcessor: TextPostprocessor {
    private let preSpaces: String?
    private let postSpaces: String?
    
    init(_ preSpaces: String?, _ postSpaces: String?) {
        self.preSpaces = preSpaces
        self.postSpaces = postSpaces
    }
    
    func process(_ string: String) -> String {
        let withoutPrefix = trimPrefix(string)
        
        return [preSpaces, withoutPrefix, postSpaces]
            .compactMap { s in s }
            .joined(separator: "")
    }
    
    private func trimPrefix(_ string: String) -> String {
        if string.starts(with: InputPreprocessor.PREFIX) {
            String(string.suffix(string.count - InputPreprocessor.PREFIX.count))
        } else {
            string
        }
    }
}
