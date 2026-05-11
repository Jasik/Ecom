//
//  AddToCartUseCase.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

struct AddToCartUseCase: Sendable {
    @Injected(\.cartRepo) private var repo
    
    func execute(_ product: Product) async {
        await repo.addToCart(product: product)
    }
}
