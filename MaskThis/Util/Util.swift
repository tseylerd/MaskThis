import Foundation

nonisolated struct Util {
    private init() { }
    
    static func delay(_ duration: Duration) async {
        try? await Task.sleep(for: duration)
    }
    
    static func adapterUrl() -> URL {
        return Bundle.main.url(forResource: "mask_adapter", withExtension: "fmadapter")!
    }
    
    static func tokensToSymbols(_ tokens: Int) -> Int {
        return tokens * 3
    }
    
    static func loadPrompts() -> PromptsCollection {
        let bundleURL = Bundle.main.url(forResource: "prompts", withExtension: "bundle")!
       
        let instructionsURL = bundleURL.appendingPathComponent("mask.instructions.txt")
        let userURL = bundleURL.appendingPathComponent("mask.user.txt")
        
        let instructionsText = try! String(contentsOf: instructionsURL, encoding: .utf8)
        let userText = try! String(contentsOf: userURL, encoding: .utf8)
        
        return PromptsCollection(
            mask: AIPrompt(
                instructions: instructionsText,
                user: userText
            )
        )
    }
    
    static func embed(text: String, to prompt: String) -> String {
        return prompt.replacingOccurrences(of: PromptMarkers.TEXT, with: text)
    }
}

fileprivate nonisolated struct PromptMarkers {
    static let TEXT = "{{TEXT}}"
}
