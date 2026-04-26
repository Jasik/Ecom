//
//  MockProductRepository.swift
//  EcomTests
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation
@testable import Ecom

struct MockProductRepository: ProductRepository {
    var stubProducts: [Product] = []
    var shouldThrowError: Bool = false
    
    func getProducts() async throws -> [Product] {
        if shouldThrowError { throw NetworkError.requestFailed }
        return stubProducts
    }
    
    func searchProducts(query: String) async throws -> [Product] {
        if shouldThrowError { throw NetworkError.requestFailed }
        return stubProducts.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }
}
