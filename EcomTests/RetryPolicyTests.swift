//
//  RetryPolicyTests.swift
//  EcomTests
//

import Testing
import Foundation
@testable import Ecom

@Suite("RetryPolicy Tests")
struct RetryPolicyTests {
    
    final class AttemptTracker: @unchecked Sendable {
        var count = 0
        func inc() { count += 1 }
    }
    
    @Test func testSuccessOnFirstAttempt() async throws {
        let tracker = AttemptTracker()
        let result = try await withRetry(RetryPolicy(maxAttempts: 3)) {
            tracker.inc()
            return "Success"
        }
        #expect(result == "Success")
        #expect(tracker.count == 1)
    }
    
    @Test func testSuccessAfterRetries() async throws {
        let tracker = AttemptTracker()
        let policy = RetryPolicy(maxAttempts: 3, baseDelay: 0.01, backoff: .fixed)
        let result = try await withRetry(policy) {
            tracker.inc()
            if tracker.count < 3 {
                throw URLError(.badServerResponse)
            }
            return "Finally"
        }
        #expect(result == "Finally")
        #expect(tracker.count == 3)
    }
    
    @Test func testFailsAfterMaxAttempts() async throws {
        let tracker = AttemptTracker()
        let policy = RetryPolicy(maxAttempts: 2, baseDelay: 0.01, backoff: .fixed)
        do {
            _ = try await withRetry(policy) {
                tracker.inc()
                throw URLError(.badServerResponse)
            }
            Issue.record("Should have thrown")
        } catch {
            #expect(tracker.count == 2)
        }
    }
    
    @Test func testCancellationStopsRetry() async throws {
        let policy = RetryPolicy(maxAttempts: 5, baseDelay: 0.1, backoff: .fixed)
        let task = Task {
            try await withRetry(policy) {
                throw URLError(.badServerResponse)
            }
        }
        task.cancel()
        do {
            _ = try await task.value
            Issue.record("Should throw CancellationError")
        } catch is CancellationError {
            // Success
        } catch {
            Issue.record("Wrong error: \(error)")
        }
    }
}
