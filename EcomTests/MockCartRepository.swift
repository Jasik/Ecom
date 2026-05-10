//
//  MockCartRepository.swift
//  EcomTests
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation
@testable import Ecom

/// Test double backed by `Broadcaster`, so multi-observer guarantees are
/// the same as production. Tests that need to await a yield should observe
/// the stream directly rather than poll state.
actor MockCartRepository: CartRepository {
    private(set) var cartItems: [Product] = []
    private let itemsBroadcaster = Broadcaster<[Product]>(initialValue: [])
    private let countBroadcaster = Broadcaster<Int>(initialValue: 0)

    func addToCart(product: Product) async {
        cartItems.append(product)
        await notify()
    }

    func removeFromCart(productID: Int) async {
        cartItems.removeAll { $0.id == productID }
        await notify()
    }

    func observeCartItems() async -> AsyncStream<[Product]> {
        await itemsBroadcaster.subscribe()
    }

    func observeCartCount() async -> AsyncStream<Int> {
        await countBroadcaster.subscribe()
    }

    private func notify() async {
        let snapshot = cartItems
        await itemsBroadcaster.send(snapshot)
        await countBroadcaster.send(snapshot.count)
    }
}
