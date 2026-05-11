//
//  Timeout.swift
//  Ecom
//

import Foundation

nonisolated public struct TimeoutError: Error {}

public func withTimeout<T: Sendable>(
    _ seconds: TimeInterval,
    operation: @Sendable @escaping () async throws -> T
) async throws -> T {
    return try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            return try await operation()
        }
        
        group.addTask {
            try await Task.sleep(for: .seconds(seconds))
            throw TimeoutError()
        }
        
        guard let result = try await group.next() else {
            throw CancellationError()
        }
        
        group.cancelAll()
        return result
    }
}
