//
//  Product+Mock.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/27.
//

import Foundation

#if DEBUG
extension Product {
    static let mock = Product(
        id: 1,
        title: "Apple MacBook Pro 14",
        description: "Чип M3 Pro, 18 ГБ объединенной памяти, 512 ГБ SSD.",
        price: 1999.0,
        images: ["https://dummyjson.com/image/i/products/1/1.jpg"],
        thumbnail: "https://dummyjson.com/image/i/products/1/thumbnail.jpg"
    )
    
    static let mockExpensive = Product(
        id: 2,
        title: "MacBook",
        description: "",
        price: 2999.0,
        images: ["https://dummyjson.com/image/i/products/1/1.jpg"],
        thumbnail: "https://dummyjson.com/image/i/products/1/thumbnail.jpg"
    )
}
#endif
