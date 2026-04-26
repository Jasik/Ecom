//
//  CartViewModelTests.swift
//  EcomTests
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import XCTest
@testable import Ecom

@MainActor
final class CartViewModelTests: XCTestCase {
    let mockProduct = Product(id: 1, title: "iPhone", description: "Phone", price: 999.0, images: [], thumbnail: "")
    
    func testRemoveItemFromCartUpdatesList() async throws {
        let mockRepo = MockCartRepository()
        await mockRepo.addToCart(product: mockProduct)
        
        var testDependencies = DependencyValues()
        testDependencies.cartRepo = mockRepo
        
        await DependencyValues.$current.withValue(testDependencies) {
            let vm = CartViewModel()
            let task = Task { await vm.startObserving() }
            try? await Task.sleep(for: .milliseconds(10))
            
            XCTAssertEqual(vm.items.count, 1)
            XCTAssertEqual(vm.totalPrice, "$999.00")
            
            vm.remove(productID: mockProduct.id)
            
            try? await Task.sleep(for: .milliseconds(10))
            
            XCTAssertEqual(vm.items.count, 0)
            XCTAssertEqual(vm.totalPrice, "$0.00")
            
            task.cancel()
        }
    }
}
