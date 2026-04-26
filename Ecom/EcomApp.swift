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
            .sheet(item: $router.sheet) { sheetRoute in
                switch sheetRoute {
                case .cart:
                    NavigationStack(path: Bindable(router).cartPath) {
                        CartView()
                            .navigationDestination(for: CartInternalRoute.self) { internalRoute in
                                switch internalRoute {
                                case .checkout:
                                    Text("Экран оплаты")
                                case .addressSelection:
                                    Text("Выбор адреса")
                                }
                            }
                            .toolbar {
                                ToolbarItem(placement: .topBarLeading) {
                                    Button(role: .close) {
                                        router.dismissSheet()
                                    }
                                }
                            }
                    }
                    .environment(router)
                }
            }
        }
    }
}
