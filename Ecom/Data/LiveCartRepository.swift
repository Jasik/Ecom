//
//  LiveCartRepository.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

actor LiveCartRepository: CartRepository {
    private var cartItems: [Product] = []
    private var streamContinuation: AsyncStream<Int>.Continuation?
    
    
    func addToCart(product: Product) async {
        cartItems.append(product)
        streamContinuation?.yield(cartItems.count)
    }
    
    func observeCartCount() async -> AsyncStream<Int> {
        let (stream, continuation) = AsyncStream<Int>.makeStream()
        
        self.streamContinuation = continuation
        
        continuation.yield(cartItems.count)
        
        continuation.onTermination = { [weak self] _ in
            Task { await self?.clearContinuation() }
        }
        
        return stream
    }
    
    private func clearContinuation() { self.streamContinuation = nil }
}

private struct CartRepoKey: DependencyKey { static let liveValue: any CartRepository = LiveCartRepository() }
extension DependencyValues {
    var cartRepo: any CartRepository { self[CartRepoKey.self] }
}
