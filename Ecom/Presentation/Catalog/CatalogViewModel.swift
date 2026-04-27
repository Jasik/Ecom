//
//  CatalogViewModel.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

@MainActor
@Observable
final class CatalogViewModel {
    var products: [Product] = []
    var searchQuery: String = ""
    var isLoading = false
    var cartCount = 0

    @ObservationIgnored @Injected(\.getProductsUseCase) private var getProducts
    @ObservationIgnored @Injected(\.searchProductsUseCase) private var searchProducts
    @ObservationIgnored @Injected(\.observeCartCountUseCase) private var observeCartCount
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        products = (try? await getProducts.execute()) ?? []
    }
    
    func preformSearch() async {
        guard !searchQuery.isEmpty else {
            return await load()
        }
        isLoading = true
        defer { isLoading = false }
        products = (try? await searchProducts.execute(query: searchQuery)) ?? []
    }
    
    func observeCart() async {
        for await count in await observeCartCount.execute() {
            self.cartCount = count
        }
    }
}
