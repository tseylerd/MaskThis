import Foundation
import Atomics
import FoundationModels

nonisolated struct Util {
    private init() { }
    
    static func delay(_ duration: Duration) async {
        try? await Task.sleep(for: duration)
    }
    
    static func compatibleAdapterIdentifier(_ name: String) -> String? {
        return SystemLanguageModel.Adapter.compatibleAdapterIdentifiers(
             name: name
        ).first
    }
    
    static func tokensToSymbols(_ tokens: Int) -> Int {
        return tokens * 3
    }
}

nonisolated extension StringProtocol {
    var isEmptyOrSpaces: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func startOfMeaningfulContent() -> String.Index? {
        var index = startIndex
        guard index < endIndex else {
            return nil
        }
        
        while index < endIndex && (self[index].isWhitespace || self[index].isNewline) {
            index = self.index(after: index)
        }
        
        return index < endIndex ? index : nil
    }
    
    func endOfMeaningfulContent() -> String.Index? {
        let endIndex = self.endIndex
        guard endIndex > startIndex else {
            return nil
        }
        
        var currentIndex = endIndex
        while currentIndex > startIndex {
            let nextIndex = self.index(before: currentIndex)
            let char = self[nextIndex]
            guard char.isNewline || char.isWhitespace else {
                break
            }
            currentIndex = nextIndex
        }
        
        return currentIndex
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
