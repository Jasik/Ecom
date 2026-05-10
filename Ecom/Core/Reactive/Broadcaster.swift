//
//  Broadcaster.swift
//  Ecom
//
//  Multi-observer async stream primitive. Use for any reactive source that
//  must support N independent subscribers (cart, device state, presence, etc.).
//
//  Notes:
//  - `subscribe()` registers SYNCHRONOUSLY under actor isolation, so there is
//    no race window between handing out a stream and the next `send()`.
//  - Each subscriber gets the latest cached value immediately (replay-of-1).
//  - Buffering policy is `.bufferingNewest(1)`. For high-throughput sources
//    (e.g. video frames at 30fps) prefer a dedicated lock-based distributor —
//    actor hops on every `send` are expensive at that rate.
//

import Foundation

/// Replays the last value to new subscribers and fans out subsequent values
/// to every active subscriber. Thread-safe by virtue of being an actor.
public actor Broadcaster<Value: Sendable> {
    private var observers: [UUID: AsyncStream<Value>.Continuation] = [:]
    private var lastValue: Value?
    private var isFinished = false

    private let bufferingPolicy: AsyncStream<Value>.Continuation.BufferingPolicy

    public init(
        initialValue: Value? = nil,
        bufferingPolicy: AsyncStream<Value>.Continuation.BufferingPolicy = .bufferingNewest(1)
    ) {
        self.lastValue = initialValue
        self.bufferingPolicy = bufferingPolicy
    }

    /// Returns a new `AsyncStream` that replays the latest cached value (if any)
    /// and receives every subsequent `send`. Cancellation/termination of the
    /// consumer side automatically unregisters the observer.
    public func subscribe() -> AsyncStream<Value> {
        AsyncStream(bufferingPolicy: bufferingPolicy) { continuation in
            let id = UUID()
            self.observers[id] = continuation
            if let last = self.lastValue { continuation.yield(last) }
            if self.isFinished { continuation.finish() }
            continuation.onTermination = { [weak self] _ in
                guard let self else { return }
                Task { await self.unregister(id: id) }
            }
        }
    }

    /// Caches `value` as the latest and yields it to every subscriber.
    public func send(_ value: Value) {
        guard !isFinished else { return }
        lastValue = value
        for c in observers.values { c.yield(value) }
    }

    /// Finishes every active stream and rejects further sends. Subscribers
    /// created after `finish()` will immediately receive `finish()` themselves.
    public func finish() {
        isFinished = true
        for c in observers.values { c.finish() }
        observers.removeAll()
    }

    /// Number of currently active subscribers. Test-only conveniences.
    public var observerCount: Int { observers.count }

    private func unregister(id: UUID) { observers[id] = nil }
}
