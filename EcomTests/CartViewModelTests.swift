//
//  CartViewModelTests.swift
//  EcomTests
//

import Testing
@testable import Ecom

@Suite("CartViewModel Tests")
@MainActor
struct CartViewModelTests {
    let mockProduct = Product(id: 1, title: "iPhone", description: "Phone", price: 999.0, images: [], thumbnail: "")

    @Test
    func testRemoveItemFromCartUpdatesList() async throws {
        let mockRepo = MockCartRepository()
        await mockRepo.addToCart(product: mockProduct)

        var testDependencies = DependencyValues()
        testDependencies.cartRepo = mockRepo

        await DependencyValues.$current.withValue(testDependencies) {
            let vm = CartViewModel()
            let task = Task { await vm.startObserving() }

            await Self.waitUntil { vm.items.count == 1 }
            #expect(vm.items.count == 1)
            #expect(vm.totalPrice == "$999.00")

            vm.remove(productID: mockProduct.id)

            await Self.waitUntil { vm.items.isEmpty }
            #expect(vm.items.count == 0)
            #expect(vm.totalPrice == "$0.00")

            task.cancel()
        }
    }

    @Test
    func testTotalPriceCalculation() async throws {
        let mockRepo = MockCartRepository()
        let product1 = Product(id: 1, title: "Item 1", description: "", price: 10.50, images: [], thumbnail: "")
        let product2 = Product(id: 2, title: "Item 2", description: "", price: 20.00, images: [], thumbnail: "")

        await mockRepo.addToCart(product: product1)
        await mockRepo.addToCart(product: product2)

        var testDependencies = DependencyValues()
        testDependencies.cartRepo = mockRepo

        await DependencyValues.$current.withValue(testDependencies) {
            let vm = CartViewModel()
            let task = Task { await vm.startObserving() }

            await Self.waitUntil { vm.items.count == 2 }
            #expect(vm.items.count == 2)
            #expect(vm.totalPrice == "$30.50")

            task.cancel()
        }
    }

    @MainActor
    static func waitUntil(
        attempts: Int = 1000,
        predicate: @MainActor () -> Bool,
        sourceLocation: SourceLocation = #_sourceLocation
    ) async {
        for _ in 0..<attempts where !predicate() {
            await Task.yield()
        }
        if !predicate() {
            Issue.record("waitUntil exhausted \(attempts) yields", sourceLocation: sourceLocation)
        }
    }
}
