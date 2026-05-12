//
//  Broadcaster.swift
//  Ecom
//

import Foundation

/// A thread-safe broadcaster that allows multiple subscribers to receive values asynchronously.
/// Features a buffer of 1 (newest value) and immediately replays the last value to new subscribers.
public actor Broadcaster<T: Sendable> {
    private var observers: [UUID: AsyncStream<T>.Continuation] = [:]
    private var lastValue: T?
    
    /// Initializes a new, empty broadcaster.
    public init() {}
    
    /// Subscribes to the broadcaster, returning an `AsyncStream` that yields values as they are sent.
    public func subscribe() -> AsyncStream<T> {
        let id = UUID()
        let (stream, continuation) = AsyncStream<T>.makeStream(bufferingPolicy: .bufferingNewest(1))
        
        observers[id] = continuation
        
        if let lastValue {
            continuation.yield(lastValue)
        }
        
        continuation.onTermination = { [weak self] _ in
            Task { [weak self] in
                await self?.removeObserver(id)
            }
        }
        
        return stream
    }
    
    /// Sends a new value to all current subscribers and stores it for future subscribers.
    public func send(_ value: T) {
        lastValue = value
        for observer in observers.values {
            observer.yield(value)
        }
    }
    
    /// Finishes all active streams, signalling that no more values will be produced.
    public func finish() {
        for observer in observers.values {
            observer.finish()
        }
        observers.removeAll()
    }
    
    private func removeObserver(_ id: UUID) {
        observers[id] = nil
    }
}
