import Foundation
import Atomics

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
    static func withTimeout<T: Sendable>(
        duration: Duration,
        operation: @escaping @Sendable () async throws -> T
    ) async throws -> T? {
        return try await withConditionalTimeout(duration: duration) { _ in
            try await operation()
        }
    }

    static func withConditionalTimeout<T: Sendable>(
        duration: Duration,
        operation: @escaping @Sendable (@Sendable () -> Void) async throws -> T
    ) async throws -> T? {
        let timeout = ManagedAtomic(true)
        let mainTask: Task<T, Error> = Task<T, Error>.detached {
            try await operation {
                timeout.store(false, ordering: .sequentiallyConsistent)
            }
        }
        
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await mainTask.value
            }
            group.addTask {
                try await Task.sleep(for: duration)
                if timeout.load(ordering: .sequentiallyConsistent) {
                    throw TimeoutError()
                } else {
                    return try await mainTask.value
                }
            }
            
            do {
                let result = try await group.next()
                
                group.cancelAll()
                
                return result
            } catch {
                group.cancelAll()
                mainTask.cancel()
                throw error
            }
        }
    }
}

class TimeoutError: LocalizedError {
    var errorDescription: String {
        UITexts.Statuses.Errors.timeoutWhileMasking
    }
}
