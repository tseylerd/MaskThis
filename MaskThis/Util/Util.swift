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

extension Task where Success == Never, Failure == Never {
    static func withTimeout<T>(
        duration: Duration,
        operation: @escaping @Sendable () async throws -> T
    ) async throws -> T? {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                return try await operation()
            }
            group.addTask {
                await Util.delay(duration)
                throw TimeoutError()
            }
            
            let result = try await group.next()
            
            group.cancelAll()
            
            return result
        }
    }
}

class TimeoutError: LocalizedError {
    var errorDescription: String {
        UITexts.Statuses.Errors.timeoutWhileMasking
    }
}
