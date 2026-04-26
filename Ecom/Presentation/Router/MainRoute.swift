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

enum CartInternalRoute: Hashable {
    case checkout
    case addressSelection
}

enum SheetRoute: Identifiable {
    case cart
    
    var id: String {
        switch self {
        case .cart:
            "cart_sheet"
        }
    }
}

@MainActor
@Observable
final class ShopRouter {
    var path: [MainRoute] = []
    var cartPath: [CartInternalRoute] = []
    var sheet: SheetRoute? = nil
    
    func push(_ route: MainRoute) {
        path.append(route)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func pushCart(_ route: CartInternalRoute) {
        cartPath.append(route)
    }
    
    func popCart() {
        if !cartPath.isEmpty {
            cartPath.removeLast()
        }
    }
    
    func popToRoot() {
        path.removeAll()
    }
    
    func presentSheet(_ route: SheetRoute) {
        sheet = route
    }
    
    func dismissSheet() {
        sheet = nil
    }
}
