//
//  ProductResponse.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

struct ProductResponse: Decodable, Sendable {
    let products: [ProductDTO]
}

struct ProductDTO: Decodable, Sendable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let images: [String]
    let thumbnail: String
    
    func toDomain() -> Product {
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
