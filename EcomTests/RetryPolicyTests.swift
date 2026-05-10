//
//  RetryPolicyTests.swift
//  EcomTests
//

import Testing
import Foundation
@testable import Ecom

@Suite struct RetryPolicyTests {
    @Test func retriesUntilSuccess() async throws {
        let attempts = Counter()
        let policy = RetryPolicy(maxAttempts: 3, baseDelay: .milliseconds(1), backoff: .fixed)

        let result = try await withRetry(policy) {
            let n = await attempts.increment()
            if n < 3 { throw SampleError.boom }
            return n
        }

        #expect(result == 3)
        #expect(await attempts.value == 3)
    }

    @Test func rethrowsAfterExhaustingAttempts() async {
        let policy = RetryPolicy(maxAttempts: 2, baseDelay: .milliseconds(1), backoff: .fixed)
        let attempts = Counter()

        await #expect(throws: SampleError.boom) {
            try await withRetry(policy) {
                _ = await attempts.increment()
                throw SampleError.boom
            }
        }
        #expect(await attempts.value == 2)
    }

    @Test func cancellationStopsRetry() async {
        let policy = RetryPolicy(maxAttempts: .max, baseDelay: .seconds(10), backoff: .fixed)
        let attempts = Counter()

        let task = Task {
            try await withRetry(policy) {
                _ = await attempts.increment()
                throw SampleError.boom
            }
        }
        // Let one attempt run.
        try? await Task.sleep(for: .milliseconds(20))
        task.cancel()

        let result = await task.result
        if case .success = result { Issue.record("should have thrown") }
        let count = await attempts.value
        #expect(count <= 2, "expected retry loop to stop quickly after cancel, was \(count)")
    }
}

private enum SampleError: Error, Equatable { case boom }

private actor Counter {
    private(set) var value = 0
    func increment() -> Int {
        value += 1
        return value
    }
}
