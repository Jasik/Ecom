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
    
    private let getProducts: GetProductsUseCase
    private let searchProducts: SearchProductsUseCase
    private let observeCartCount: ObserveCartCountUseCase
    
    init(
        getProducts: GetProductsUseCase,
        searchProducts: SearchProductsUseCase,
        observeCartCount: ObserveCartCountUseCase
    ) {
        self.getProducts = getProducts
        self.searchProducts = searchProducts
        self.observeCartCount = observeCartCount
    }
    
    convenience init() {
        self.init(
            getProducts: GetProductsUseCase(),
            searchProducts: SearchProductsUseCase(),
            observeCartCount: ObserveCartCountUseCase()
        )
    }
    
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
    
    public func observeCart() async {
        for await count in await observeCartCount.execute() {
            self.cartCount = count
        }
    }
}
