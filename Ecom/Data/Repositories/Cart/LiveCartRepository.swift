//
//  LiveCartRepository.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

actor LiveCartRepository: CartRepository {
    private var cartItems: [Product] = []
    private let itemsBroadcaster = Broadcaster<[Product]>()
    private let countBroadcaster = Broadcaster<Int>()

    func addToCart(product: Product) async {
        cartItems.append(product)
        await broadcast()
    }

    func removeFromCart(productID: Int) async {
        cartItems.removeAll { $0.id == productID }
        await broadcast()
    }

    func observeCartItems() async -> AsyncStream<[Product]> {
        await itemsBroadcaster.subscribe()
    }

    func observeCartCount() async -> AsyncStream<Int> {
        await countBroadcaster.subscribe()
    }

    private func broadcast() async {
        await itemsBroadcaster.send(cartItems)
        await countBroadcaster.send(cartItems.count)
    }
}

