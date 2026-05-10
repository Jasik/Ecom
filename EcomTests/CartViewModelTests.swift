//
//  CartViewModelTests.swift
//  EcomTests
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Testing
import Foundation
@testable import Ecom

@MainActor
@Suite struct CartViewModelTests {
    let mockProduct = Product(id: 1, title: "iPhone", description: "Phone", price: 999.0, images: [], thumbnail: "")

    @Test func removeItemFromCartUpdatesList() async throws {
        let mockRepo = MockCartRepository()
        await mockRepo.addToCart(product: mockProduct)

        var deps = DependencyValues()
        deps.cartRepo = mockRepo

        try await DependencyValues.$current.withValue(deps) {
            let vm = CartViewModel()
            let observe = Task { await vm.startObserving() }
            defer { observe.cancel() }

            try await waitUntil(timeout: .seconds(1)) { vm.items.count == 1 }
            #expect(vm.totalPrice == 999.0.formatted(.currency(code: "USD")))

            vm.remove(productID: mockProduct.id)
            try await waitUntil(timeout: .seconds(1)) { vm.items.isEmpty }
            #expect(vm.totalPrice == 0.0.formatted(.currency(code: "USD")))
        }
    }

    @Test func totalPriceCalculation() async throws {
        let mockRepo = MockCartRepository()
        let p1 = Product(id: 1, title: "Item 1", description: "", price: 10.50, images: [], thumbnail: "")
        let p2 = Product(id: 2, title: "Item 2", description: "", price: 20.00, images: [], thumbnail: "")
        await mockRepo.addToCart(product: p1)
        await mockRepo.addToCart(product: p2)

        var deps = DependencyValues()
        deps.cartRepo = mockRepo

        try await DependencyValues.$current.withValue(deps) {
            let vm = CartViewModel()
            let observe = Task { await vm.startObserving() }
            defer { observe.cancel() }

            try await waitUntil(timeout: .seconds(1)) { vm.items.count == 2 }
            #expect(vm.totalPrice == 30.5.formatted(.currency(code: "USD")))
        }
    }
}
