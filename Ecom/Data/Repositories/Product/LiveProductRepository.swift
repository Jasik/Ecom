//
//  LiveProductRepository.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

struct LiveProductRepository: ProductRepository {
    @Injected(\.apiClient) private var api

    private nonisolated static let baseURL = URL(string: "https://dummyjson.com")!

    nonisolated func getProducts() async throws -> [Product] {
        var components = URLComponents(url: Self.baseURL.appendingPathComponent("products"), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "limit", value: "20")]
        let response: ProductResponse = try await api.fetch(url: components.url!.absoluteString)
        return response.products.map { $0.toDomain() }
    }

    nonisolated func searchProducts(query: String) async throws -> [Product] {
        var components = URLComponents(url: Self.baseURL.appendingPathComponent("products/search"), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "q", value: query)]
        let response: ProductResponse = try await api.fetch(url: components.url!.absoluteString)
        return response.products.map { $0.toDomain() }
    }
}
