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
    var loadState: LoadState<Void, Error> = .idle
    var totalPrice: String {
        let total = items.reduce(0.0) { $1.price + $0 }
        return total.formatted(.currency(code: "USD"))
    }
    
    @ObservationIgnored @Injected(\.cartRepo) private var cartRepo
    
    func startObserving() async {
        let stream = await cartRepo.observeCartItems()
        for await updatedItems in stream {
            self.items = updatedItems
        }
    }
    
    func remove(productID: Int) {
        Task {
            await cartRepo.removeFromCart(productID: productID)
            AppLogger.info("Товар успешно удален с экрана", category: .ui)
        }
    }
}
