//
//  RetryPolicy.swift
//  Ecom
//

import Foundation

/// A configuration object defining the rules for retrying a failed asynchronous operation.
nonisolated public struct RetryPolicy: Sendable {
    /// The strategy for calculating the delay between retry attempts.
    public enum Backoff: Sendable {
        /// A constant delay between all attempts.
        case fixed
        /// Delay doubles with each attempt.
        case exponential
        /// Delay doubles with each attempt, with added randomness to avoid thundering herd problems.
        case exponentialJitter
    }
    
    /// The maximum number of attempts before giving up.
    public let maxAttempts: Int
    /// The base delay applied before the first retry (or used as the constant delay for `.fixed`).
    public let baseDelay: TimeInterval
    /// The backoff strategy to employ.
    public let backoff: Backoff
    
    /// Initializes a new retry policy.
    public init(maxAttempts: Int = 3, baseDelay: TimeInterval = 1.0, backoff: Backoff = .exponential) {
        self.maxAttempts = maxAttempts
        self.baseDelay = baseDelay
        self.backoff = backoff
    }
}

/// Executes an asynchronous operation, retrying it according to the specified policy if it fails.
///
/// - Parameters:
///   - policy: The `RetryPolicy` dictating max attempts and backoff duration. Defaults to standard exponential backoff.
///   - operation: The throwing async closure to execute.
/// - Returns: The result of the operation if it succeeds within the allowed attempts.
/// - Throws: The last error encountered if all attempts fail, or `CancellationError` if the task is cancelled.
public func withRetry<T: Sendable>(
    _ policy: RetryPolicy = RetryPolicy(),
    operation: @Sendable @escaping () async throws -> T
) async throws -> T {
    var attempt = 0
    while attempt < policy.maxAttempts {
        if Task.isCancelled { throw CancellationError() }
        do {
            return try await operation()
        } catch {
            attempt += 1
            if attempt >= policy.maxAttempts {
                throw error
            }
            if Task.isCancelled { throw CancellationError() }
            
            let delay: TimeInterval
            switch policy.backoff {
            case .fixed:
                delay = policy.baseDelay
            case .exponential:
                delay = policy.baseDelay * pow(2.0, Double(attempt - 1))
            case .exponentialJitter:
                let exp = policy.baseDelay * pow(2.0, Double(attempt - 1))
                delay = Double.random(in: (exp * 0.5)...exp)
            }
            
            try await Task.sleep(for: .seconds(delay))
        }
    }
    throw CancellationError()
}
