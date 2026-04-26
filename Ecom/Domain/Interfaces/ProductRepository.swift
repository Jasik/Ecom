//
//  ProductRepository.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

protocol ProductRepository: Sendable {
    func getProducts() async throws -> [Product]
    func searchProducts(query: String) async throws -> [Product]
}
