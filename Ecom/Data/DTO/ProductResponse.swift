//
//  ProductResponse.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

nonisolated struct ProductResponse: Decodable, Sendable {
    let products: [ProductDTO]
}

nonisolated struct ProductDTO: Decodable, Sendable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let images: [String]
    let thumbnail: String
    
    nonisolated func toDomain() -> Product {
        Product(
            id: id,
            title: title,
            description: description,
            price: price,
            images: images,
            thumbnail: thumbnail
        )
    }
}
