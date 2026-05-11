//
//  LiveCartRepository.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

actor LiveCartRepository: CartRepository {
    private var cartItems: [Product] = []
    private var itemsObservers: [UUID: AsyncStream<[Product]>.Continuation] = [:]
    private var countObservers: [UUID: AsyncStream<Int>.Continuation] = [:]

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
        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeItemsObserver(id) }
        }
        return stream
    }

    func observeCartCount() async -> AsyncStream<Int> {
        let id = UUID()
        let (stream, continuation) = AsyncStream<Int>.makeStream(bufferingPolicy: .bufferingNewest(1))
        countObservers[id] = continuation
        continuation.yield(cartItems.count)
        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeCountObserver(id) }
        }
        return stream
    }

    private func broadcast() {
        for continuation in itemsObservers.values {
            continuation.yield(cartItems)
        }
        for continuation in countObservers.values {
            continuation.yield(cartItems.count)
        }
    }

    private func removeItemsObserver(_ id: UUID) {
        itemsObservers[id] = nil
    }

    private func removeCountObserver(_ id: UUID) {
        countObservers[id] = nil
    }
}

