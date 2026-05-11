//
//  GetProductsUseCase.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

struct GetProductsUseCase: Sendable {
    @Injected(\.productRepo) private var repo
    func execute() async throws -> [Product] {
        try await repo.getProducts()
    }
}
