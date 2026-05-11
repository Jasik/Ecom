//
//  RetryPolicy.swift
//  Ecom
//

import Foundation

nonisolated public struct RetryPolicy: Sendable {
    public enum Backoff: Sendable {
        case fixed
        case exponential
        case exponentialJitter
    }
    
    public let maxAttempts: Int
    public let baseDelay: TimeInterval
    public let backoff: Backoff
    
    public init(maxAttempts: Int = 3, baseDelay: TimeInterval = 1.0, backoff: Backoff = .exponential) {
        self.maxAttempts = maxAttempts
        self.baseDelay = baseDelay
        self.backoff = backoff
    }
}

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
