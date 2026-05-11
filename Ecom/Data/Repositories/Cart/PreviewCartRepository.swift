//
//  PreviewCartRepository.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/27.
//

import Foundation

#if DEBUG
actor PreviewCartRepository: CartRepository {
    private let items: [Product] = [.mock, .mock]
    
    func addToCart(product: Product) async {}
    func removeFromCart(productID: Int) async {}
    func observeCartCount() async -> AsyncStream<Int> {
        AsyncStream {
            $0.yield(items.count)
            $0.finish()
        }
    }
    func observeCartItems() async -> AsyncStream<[Product]> {
        AsyncStream {
            $0.yield(items)
            $0.finish()
        }
    }
}

actor MockEmptyCartRepository: CartRepository {
    func addToCart(product: Product) async {}
    func removeFromCart(productID: Int) async {}
    
    func observeCartCount() async -> AsyncStream<Int> {
        AsyncStream {
            $0.yield(0)
            $0.finish()
        }
    }
    
    func observeCartItems() async -> AsyncStream<[Product]> {
        AsyncStream {
            $0.yield([])
            $0.finish()
        }
    }
}
#endif
