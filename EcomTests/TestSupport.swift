//
//  TestSupport.swift
//  EcomTests
//
//  Helpers shared across tests. Replaces ad-hoc `Task.sleep` waits with
//  bounded condition polling so flakes degrade into clear failures.
//

import Foundation

/// Polls `condition` on the current actor until it becomes true or `timeout`
/// expires. Throws if the timeout is hit. The interval is intentionally tiny —
/// this isn't a "wait a bit and hope" — the next yield of the system task
/// scheduler is enough to deliver actor-hop continuations.
func waitUntil(
    timeout: Duration,
    interval: Duration = .milliseconds(2),
    _ condition: () -> Bool
) async throws {
    let deadline = ContinuousClock.now.advanced(by: timeout)
    while ContinuousClock.now < deadline {
        if condition() { return }
        try await Task.sleep(for: interval)
    }
    if !condition() {
        struct WaitTimedOut: Error, CustomStringConvertible {
            let timeout: Duration
            var description: String { "waitUntil timed out after \(timeout)" }
        }
        throw WaitTimedOut(timeout: timeout)
    }
}
