//
//  ProductResponse.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

struct ProductResponse: Decodable, Sendable {
    let products: [Product]
}
