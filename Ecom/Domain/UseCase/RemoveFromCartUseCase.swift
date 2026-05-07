//
//  RemoveFromCartUseCase.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

struct RemoveFromCartUseCase: Sendable {
    @Injected(\.cartRepo) private var repo
    
    func execute(productID: Int) async throws {
        AppLogger.info("Пытаемся удалить товар с ID: \(productID)", category: .domain)
        try await repo.removeFromCart(productID: productID)
    }
}
