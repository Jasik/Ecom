//
//  PreviewProductRepository.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/27.
//

import Foundation

#if DEBUG
struct PreviewProductRepository: ProductRepository {
    func getProducts() async throws -> [Product] {
        [.mock, .mock, .mockExpensive]
    }
    
    func searchProducts(query: String) async throws -> [Product] {
        [.mock]
    }
}
#endif
