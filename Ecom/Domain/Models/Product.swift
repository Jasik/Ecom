//
//  Product.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

nonisolated struct Product: Identifiable, Hashable, Sendable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let images: [String]
    let thumbnail: String
}

nonisolated extension Product {
    /// Locale-aware currency formatting. Replace the currency code once the
    /// real product API exposes it per-product (DummyJSON does not).
    var formattedPrice: String {
        price.formatted(.currency(code: "USD"))
    }
}
