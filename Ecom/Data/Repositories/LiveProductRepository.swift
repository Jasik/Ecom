//
//  LiveProductRepository.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

struct LiveProductRepository: ProductRepository {
    @Injected(\.apiClient) private var api
    
    func getProducts() async throws -> [Product] {
        let response: ProductResponse = try await api.fetch(url: "https://dummyjson.com/products?limit=20")
        return response.products.map { $0.toDomain() }
    }
    
    func searchProducts(query: String) async throws -> [Product] {
        let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let response: ProductResponse = try await api.fetch(url: "https://dummyjson.com/products/search?q=\(safeQuery)")
        return response.products.map { $0.toDomain() }
    }
}

#if DEBUG
struct PreviewProductRepository: ProductRepository {
    func getProducts() async throws -> [Product] {
        [.mock, .mock, .mock]
    }
    
    func searchProducts(query: String) async throws -> [Product] {
        [.mock]
    }
}
#endif

private struct ProductRepoKey: DependencyKey {
    static let liveValue: any ProductRepository = LiveProductRepository()
    #if DEBUG
    static let previewValue: any ProductRepository = PreviewProductRepository()
    #endif
}

extension DependencyValues {
    var productRepo: any ProductRepository {
        get { self[ProductRepoKey.self] }
        set { self[ProductRepoKey.self] = newValue }
    }
}
