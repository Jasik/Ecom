//
//  SearchProductsUseCase.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

struct SearchProductsUseCase: Sendable {
    @Injected(\.productRepo) private var repo
    func execute(query: String) async throws -> [Product] {
        try await repo.searchProducts(query: query)
    }
}
