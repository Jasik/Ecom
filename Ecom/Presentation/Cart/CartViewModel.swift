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
    
    private let observeItems: ObserveCartItemsUseCase
    private let removeItem: RemoveFromCartUseCase
    
    init(observeItems: ObserveCartItemsUseCase, removeItem: RemoveFromCartUseCase) {
        self.observeItems = observeItems
        self.removeItem = removeItem
    }
    
    convenience init () {
        self.init(
            observeItems: ObserveCartItemsUseCase(),
            removeItem: RemoveFromCartUseCase()
        )
    }
    
    func startObserving() async {
        let stream = await observeItems.execute()
        for await updatedItems in stream {
            self.items = updatedItems
        }
    }
    
    func remove(productID: Int) {
        Task {
            await removeItem.execute(productID: productID)
        }
    }
}
