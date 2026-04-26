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
    private var itemsContinuation: AsyncStream<[Product]>.Continuation?
    
    func addToCart(product: Product) async {
        cartItems.append(product)
        itemsContinuation?.yield(cartItems)
    }
    
    func removeFromCart(productID: Int) async {
        cartItems.removeAll { $0.id == productID }
        itemsContinuation?.yield(cartItems)
    }
    
    func observeCartItems() async -> AsyncStream<[Product]> {
        let (stream, continuation) = AsyncStream<[Product]>.makeStream()
        self.itemsContinuation = continuation
        continuation.yield(cartItems)
        return stream
    }
    
    func observeCartCount() async -> AsyncStream<Int> {
        AsyncStream { $0.finish() }
    }
}
