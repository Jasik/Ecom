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
        let total = items.reduce(0.0) { $0 + $1.price }
        return total.formatted(.currency(code: "USD"))
    }

    @ObservationIgnored @Injected(\.cartRepo) private var cartRepo
    @ObservationIgnored private let bag = TaskBag()

    func startObserving() async {
        for await updatedItems in await cartRepo.observeCartItems() {
            self.items = updatedItems
        }
    }

    func remove(productID: Int) {
        bag.add { [cartRepo] in
            await cartRepo.removeFromCart(productID: productID)
            AppLogger.info("Товар \(productID) удалён", category: .ui)
        }
    }
}
