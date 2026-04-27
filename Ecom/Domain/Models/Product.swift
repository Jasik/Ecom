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

extension Product {
    static let mock = Product(
        id: 1,
        title: "Apple MacBook Pro 14",
        description: "Чип M3 Pro, 18 ГБ объединенной памяти, 512 ГБ SSD.",
        price: 1999.0,
        images: ["https://dummyjson.com/image/i/products/1/1.jpg"],
        thumbnail: "https://dummyjson.com/image/i/products/1/thumbnail.jpg"
    )
}
