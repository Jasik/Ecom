//
//  LiveProductRepository.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

struct LiveProductRepository: ProductRepository {
    @Injected(\.apiClient) private var api
    
    nonisolated func getProducts() async throws -> [Product] {
        let response: ProductResponse = try await api.fetch(url: "https://dummyjson.com/products?limit=20")
        return response.products.map { $0.toDomain() }
    }
    
    nonisolated func searchProducts(query: String) async throws -> [Product] {
        guard var components = URLComponents(string: "https://dummyjson.com/products/search") else {
            throw URLError(.badURL)
        }
        components.queryItems = [URLQueryItem(name: "q", value: query)]
        guard let urlString = components.url?.absoluteString else {
            throw URLError(.badURL)
        }
        let response: ProductResponse = try await api.fetch(url: urlString)
        return response.products.map { $0.toDomain() }
    }
}

