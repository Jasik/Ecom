//
//  Timeout.swift
//  Ecom
//
//  Race-based timeout helper. Throws `TimeoutError` if `operation` does not
//  complete within `duration`. The losing branch is cancelled.
//

import Foundation

public nonisolated struct TimeoutError: Error, Sendable, CustomStringConvertible {
    public let duration: Duration
    public init(duration: Duration) { self.duration = duration }
    public var description: String { "Operation timed out after \(duration)" }
}

public nonisolated func withTimeout<T: Sendable>(
    _ duration: Duration,
    operation: @Sendable @escaping () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask { try await operation() }
        group.addTask {
            try await Task.sleep(for: duration)
            throw TimeoutError(duration: duration)
        }
        defer { group.cancelAll() }
        guard let result = try await group.next() else {
            throw TimeoutError(duration: duration)
        }
        return result
    }
}
