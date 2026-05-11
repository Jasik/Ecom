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
    var loadState: LoadState<Void, Error> = .idle
    var cartCount = 0

    @ObservationIgnored @Injected(\.productRepo) private var productRepo
    @ObservationIgnored @Injected(\.cartRepo) private var cartRepo
    
    func load() async {
        loadState = .loading
        do {
            let products = try await productRepo.getProducts()
            AppLogger.info("Fetched products \(products)", category: .ui)
            self.products = products
            loadState = .loaded(())
        } catch {
            AppLogger.error(error, category: .ui)
            loadState = .failed(error)
        }
    }
    
    func performSearch() async {
        guard !searchQuery.isEmpty else {
            await load()
            return
        }
        loadState = .loading
        do {
            products = try await productRepo.searchProducts(query: searchQuery)
            loadState = .loaded(())
        } catch {
            AppLogger.error(error, category: .ui)
            loadState = .failed(error)
        }
    }
    
    func observeCart() async {
        for await count in await cartRepo.observeCartCount() {
            self.cartCount = count
        }
    }
}
