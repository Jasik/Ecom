//
//  BroadcasterTests.swift
//  EcomTests
//

import Testing
import Foundation
@testable import Ecom

@Suite struct BroadcasterTests {
    @Test func newSubscriberReceivesLastValueImmediately() async {
        let b = Broadcaster<Int>()
        await b.send(42)

        var iterator = await b.subscribe().makeAsyncIterator()
        let value = await iterator.next()
        #expect(value == 42)
    }

    @Test func threeSubscribersAllReceiveSameSequence() async throws {
        // Use unbounded buffer so the assertion is on full sequence delivery,
        // independent of consumer scheduling. Production uses the default
        // `.bufferingNewest(1)` and only guarantees last-value delivery.
        let b = Broadcaster<Int>(initialValue: 0, bufferingPolicy: .unbounded)
        let s1 = await b.subscribe()
        let s2 = await b.subscribe()
        let s3 = await b.subscribe()

        for v in 1...3 {
            await b.send(v)
        }
        await b.finish()

        async let r1 = collectAll(s1)
        async let r2 = collectAll(s2)
        async let r3 = collectAll(s3)

        let (v1, v2, v3) = await (r1, r2, r3)
        #expect(v1 == [0, 1, 2, 3])
        #expect(v2 == [0, 1, 2, 3])
        #expect(v3 == [0, 1, 2, 3])
    }

    @Test func cancellingOneSubscriberDoesNotAffectOthers() async throws {
        let b = Broadcaster<Int>(initialValue: 0, bufferingPolicy: .unbounded)

        let s1 = await b.subscribe()
        let dropStream = await b.subscribe()
        #expect(await b.observerCount == 2)

        let dropTask = Task { await collectAll(dropStream) }
        dropTask.cancel()
        _ = await dropTask.value
        try await waitUntil(timeout: .seconds(1)) { await b.observerCount == 1 }

        for v in 1...2 {
            await b.send(v)
        }
        await b.finish()

        let result = await collectAll(s1)
        #expect(result == [0, 1, 2])
    }

    @Test func finishStopsAllSubscribers() async {
        let b = Broadcaster<Int>(initialValue: 7)
        let stream = await b.subscribe()
        await b.finish()

        var values: [Int] = []
        for await v in stream {
            values.append(v)
        }
        #expect(values == [7])
    }
}

private func collectAll<S: AsyncSequence & Sendable>(
    _ stream: S
) async -> [S.Element] where S.Element: Sendable {
    var out: [S.Element] = []
    do {
        for try await v in stream {
            out.append(v)
        }
    } catch {}
    return out
}

private func waitUntil(
    timeout: Duration,
    _ condition: () async -> Bool
) async throws {
    let deadline = ContinuousClock.now.advanced(by: timeout)
    while ContinuousClock.now < deadline {
        if await condition() { return }
        try await Task.sleep(for: .milliseconds(2))
    }
    if await !condition() {
        struct WaitTimedOut: Error {}
        throw WaitTimedOut()
    }
}
