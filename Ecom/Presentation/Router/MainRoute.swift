//
//  MainRoute.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import SwiftUI

enum MainRoute: Hashable {
    case productDetail(product: Product)
}

@MainActor
@Observable
final class ShopRouter {
    var path: [MainRoute] = []
    func push(_ route: MainRoute) { path.append(route) }
}
