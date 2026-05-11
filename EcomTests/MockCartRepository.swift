//
//  MockCartRepository.swift
//  EcomTests
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation
@testable import Ecom

actor MockCartRepository: CartRepository {
    var cartItems: [Product] = []
    private var itemsObservers: [UUID: AsyncStream<[Product]>.Continuation] = [:]
    private var yieldWaiters: [CheckedContinuation<Void, Never>] = []

    func addToCart(product: Product) async {
        cartItems.append(product)
        broadcast()
    }

    func removeFromCart(productID: Int) async {
        cartItems.removeAll { $0.id == productID }
        broadcast()
    }

    func observeCartItems() async -> AsyncStream<[Product]> {
        let id = UUID()
        let (stream, continuation) = AsyncStream<[Product]>.makeStream(bufferingPolicy: .bufferingNewest(1))
        itemsObservers[id] = continuation
        continuation.yield(cartItems)
        signalYield()
        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeItemsObserver(id) }
        }
        return stream
    }

    func observeCartCount() async -> AsyncStream<Int> {
        AsyncStream { $0.finish() }
    }

    /// Suspends until the next yield to subscribers occurs.
    /// Use this from tests to wait for repository state-change propagation
    /// without `Task.sleep` time-based hacks.
    func waitForNextYield() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            yieldWaiters.append(continuation)
        }
    }

    private func broadcast() {
        for continuation in itemsObservers.values {
            continuation.yield(cartItems)
        }
        signalYield()
    }

    private func signalYield() {
        let waiters = yieldWaiters
        yieldWaiters.removeAll()
        for waiter in waiters { waiter.resume() }
    }

    private func removeItemsObserver(_ id: UUID) {
        itemsObservers[id] = nil
    }
}
