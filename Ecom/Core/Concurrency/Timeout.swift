//
//  Timeout.swift
//  Ecom
//

import Foundation

/// Error thrown when an operation wrapped in `withTimeout` exceeds its time limit.
nonisolated public struct TimeoutError: Error {}

/// Executes an asynchronous operation, throwing a `TimeoutError` if it does not complete within the specified duration.
///
/// - Parameters:
///   - seconds: The maximum duration allowed for the operation, in seconds.
///   - operation: The asynchronous closure to execute.
/// - Returns: The result of the operation if it completes in time.
/// - Throws: `TimeoutError` if the time limit is reached, or any error thrown by the operation itself.
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
