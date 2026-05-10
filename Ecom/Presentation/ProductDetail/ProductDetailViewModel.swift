//
//  ProductDetailViewModel.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

@MainActor
@Observable
final class ProductDetailViewModel {
    let product: Product
    var isAddedToCart: Bool = false

    @ObservationIgnored @Injected(\.cartRepo) private var cartRepo
    @ObservationIgnored private let bag = TaskBag()

    init(product: Product) {
        self.product = product
    }

    /// Cancels any in-flight add task before starting a new one. Without
    /// this, repeated taps stack 2-second sleep tasks that race to flip
    /// `isAddedToCart` back to false.
    func addToCart() {
        bag.cancelAll()
        bag.add { [cartRepo, product] in
            await cartRepo.addToCart(product: product)
            self.isAddedToCart = true
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            self.isAddedToCart = false
        }
    }
}
