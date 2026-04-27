//
//  CartViewModel.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

@MainActor
@Observable
final class CartViewModel {
    var items: [Product] = []
    var totalPrice: String {
        let total = items.reduce(0) { $1.price + $0 }
        return "$\(String(format: "%.2f", total))"
    }
    
    @ObservationIgnored @Injected(\.observeCartItemsUseCase) private var observeCartItems
    @ObservationIgnored @Injected(\.removeFromCartUseCase) private var removeFromCart
    
    func startObserving() async {
        let stream = await observeCartItems.execute()
        for await updatedItems in stream {
            self.items = updatedItems
        }
    }
    
    func remove(productID: Int) {
        Task {
            await removeFromCart.execute(productID: productID)
        }
    }
}
