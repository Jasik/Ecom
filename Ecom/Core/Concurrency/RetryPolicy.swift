//
//  RetryPolicy.swift
//  Ecom
//
//  Reusable retry helper. Applies to network, SDK calls, anything async
//  that can transiently fail. Honours `Task.isCancelled` between attempts.
//

import Foundation

public nonisolated struct RetryPolicy: Sendable {
    public nonisolated enum Backoff: Sendable {
        case fixed
        case exponential
        case exponentialJitter
    }

    public let maxAttempts: Int
    public let baseDelay: Duration
    public let backoff: Backoff

    public init(maxAttempts: Int, baseDelay: Duration, backoff: Backoff) {
        self.maxAttempts = maxAttempts
        self.baseDelay = baseDelay
        self.backoff = backoff
    }

    public static let network = RetryPolicy(
        maxAttempts: 3,
        baseDelay: .seconds(1),
        backoff: .exponentialJitter
    )

    public static let streaming = RetryPolicy(
        maxAttempts: .max,
        baseDelay: .seconds(2),
        backoff: .exponentialJitter
    )

    public static let none = RetryPolicy(
        maxAttempts: 1,
        baseDelay: .zero,
        backoff: .fixed
    )

    /// Computes the delay before attempt #`attempt` (1-indexed; the first
    /// attempt has no preceding delay so callers should skip `delay(for: 1)`).
    func delay(for attempt: Int) -> Duration {
        let exponent = max(0, attempt - 2)
        let multiplier: Double
        switch backoff {
        case .fixed:
            multiplier = 1
        case .exponential:
            multiplier = pow(2.0, Double(exponent))
        case .exponentialJitter:
            let base = pow(2.0, Double(exponent))
            multiplier = base * Double.random(in: 0.5...1.5)
        }
        return baseDelay * multiplier
    }
}

/// Runs `operation`, retrying transient failures per `policy`. Stops
/// immediately on cancellation. Re-throws the last encountered error if every
/// attempt fails.
public nonisolated func withRetry<T: Sendable>(
    _ policy: RetryPolicy,
    operation: @Sendable () async throws -> T
) async throws -> T {
    var lastError: Error?
    for attempt in 1...max(1, policy.maxAttempts) {
        try Task.checkCancellation()
        do {
            return try await operation()
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            lastError = error
            if attempt == policy.maxAttempts { break }
            let delay = policy.delay(for: attempt + 1)
            if delay > .zero {
                try await Task.sleep(for: delay)
            }
        }
    }
    throw lastError ?? CancellationError()
}
