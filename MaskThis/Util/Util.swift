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
}
