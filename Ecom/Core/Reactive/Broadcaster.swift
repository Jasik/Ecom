//
//  Broadcaster.swift
//  Ecom
//

import Foundation

public actor Broadcaster<T: Sendable> {
    private var observers: [UUID: AsyncStream<T>.Continuation] = [:]
    private var lastValue: T?
    
    public init() {}
    
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
    
    public func send(_ value: T) {
        lastValue = value
        for observer in observers.values {
            observer.yield(value)
        }
    }
    
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
