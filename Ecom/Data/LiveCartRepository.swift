//
//  LiveCartRepository.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

actor LiveCartRepository: CartRepository {
    private var cartItems: [Product] = []
    
    private var itemsContinuation: AsyncStream<[Product]>.Continuation?
    private var countContinuation: AsyncStream<Int>.Continuation?
    
    func addToCart(product: Product) async {
        cartItems.append(product)
        notify()
    }
    
    func removeFromCart(productID: Int) async {
        cartItems.removeAll { $0.id == productID }
        notify()
    }
    
    func observeCartItems() async -> AsyncStream<[Product]> {
        let (stream, continuation) = AsyncStream<[Product]>.makeStream()
        self.itemsContinuation = continuation
        continuation.yield(cartItems)
        return stream
    }
    
    func observeCartCount() async -> AsyncStream<Int> {
        let (stream, continuation) = AsyncStream<Int>.makeStream()
        self.countContinuation = continuation
        continuation.yield(cartItems.count)
        return stream
    }
    
    private func notify() {
        itemsContinuation?.yield(cartItems)
        countContinuation?.yield(cartItems.count)
    }
}

private struct CartRepoKey: DependencyKey { static let liveValue: any CartRepository = LiveCartRepository() }
extension DependencyValues {
    var cartRepo: any CartRepository { self[CartRepoKey.self] }
}
