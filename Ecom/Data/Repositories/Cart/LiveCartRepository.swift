//
//  LiveCartRepository.swift
//  Ecom
//
//  Multi-observer reactive cart repository. Reference implementation
//  for any future IoT repo: state lives inside the actor, fan-out via
//  `Broadcaster`. Single-continuation patterns are forbidden by design.
//

import Foundation

actor LiveCartRepository: CartRepository {
    private var cartItems: [Product] = []
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
