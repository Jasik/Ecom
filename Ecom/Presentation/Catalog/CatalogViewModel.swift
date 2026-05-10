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
    var loadState: LoadState<[Product], Error> = .loading
    var searchQuery: String = ""
    var cartCount: Int = 0

    @ObservationIgnored @Injected(\.productRepo) private var productRepo
    @ObservationIgnored @Injected(\.cartRepo) private var cartRepo

    func load() async {
        let lastKnown = loadState.value
        loadState = .loading
        do {
            let products = try await productRepo.getProducts()
            AppLogger.info("Fetched \(products.count) products", category: .ui)
            loadState = .fresh(products)
        } catch {
            AppLogger.error(error, category: .ui)
            loadState = .failed(error, lastKnown: lastKnown)
        }
    }

    func performSearch() async {
        guard !searchQuery.isEmpty else {
            await load()
            return
        }
        let lastKnown = loadState.value
        loadState = .loading
        do {
            let products = try await productRepo.searchProducts(query: searchQuery)
            loadState = .fresh(products)
        } catch {
            AppLogger.error(error, category: .ui)
            loadState = .failed(error, lastKnown: lastKnown)
        }
    }

    func observeCart() async {
        for await count in await cartRepo.observeCartCount() {
            self.cartCount = count
        }
    }
}
