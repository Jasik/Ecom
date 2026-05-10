//
//  CartRepository.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

protocol CartRepository: Sendable {
    func addToCart(product: Product) async
    func removeFromCart(productID: Int) async
    func observeCartCount() async -> AsyncStream<Int>
    func observeCartItems() async -> AsyncStream<[Product]>
}
