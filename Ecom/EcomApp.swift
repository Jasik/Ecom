//
//  EcomApp.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import SwiftUI

@main
struct EcomApp: App {
    @State private var router = ShopRouter()
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                CatalogView()
                    .navigationDestination(for: MainRoute.self) { route in
                        switch route {
                        case .productDetail(let product):
                            ProductDetailView(product: product)
                        }
                    }
            }
            .environment(router)
        }
    }
}
