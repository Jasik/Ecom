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
    
    @ObservationIgnored @Injected(\.addToCartUseCase) private var addToCartUseCase
    
    init(product: Product) {
        self.product = product
    }
    
    func addToCart() {
        Task {
            await addToCartUseCase.execute(product)
            isAddedToCart = true
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            isAddedToCart = false
        }
    }
}
