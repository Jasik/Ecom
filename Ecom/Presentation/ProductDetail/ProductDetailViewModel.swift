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
    
    private let addToCartUseCase: AddToCartUseCase
    
    init(product: Product, addToCartUseCase: AddToCartUseCase) {
        self.product = product
        self.addToCartUseCase = addToCartUseCase
    }
    
    convenience init(product: Product) {
        self.init(
            product: product,
            addToCartUseCase: AddToCartUseCase()
        )
    }
    
    func addToCart() {
        Task {
            await addToCartUseCase.execute(product)
            isAddedToCart = true
            try? await Task.sleep(for: .seconds(2))
            isAddedToCart = false
        }
    }
}
