//
//  Product.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

struct Product: Identifiable, Hashable, Sendable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let images: [String]
    let thumbnail: String
}

extension Product {
    var formattedPrice: String {
        return "$\(price)"
    }
}
