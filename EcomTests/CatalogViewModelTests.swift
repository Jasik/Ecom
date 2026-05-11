//
//  CatalogViewModelTests.swift
//  EcomTests
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import XCTest
@testable import Ecom

@MainActor
final class CatalogViewModelTests: XCTestCase {
    let mockProducts = [
        Product(id: 1, title: "iPhone 15", description: "Phone", price: 999.0, images: [], thumbnail: ""),
        Product(id: 2, title: "MacBook Pro", description: "Laptop", price: 1999.0, images: [], thumbnail: "")
    ]
    
    func testLoadProductsSuccessfully() async throws {
        let mockRepo = MockProductRepository(stubProducts: mockProducts)
        var dependencies = DependencyValues()
        dependencies.productRepo = mockRepo
        
        await DependencyValues.$current.withValue(dependencies) {
            let vm = CatalogViewModel()
            
            XCTAssertTrue(vm.products.isEmpty)
            XCTAssertFalse(vm.isLoading)
            
            await vm.load()
            
            XCTAssertEqual(vm.products.count, 2)
            XCTAssertFalse(vm.isLoading)
            XCTAssertEqual(vm.products.first?.title, "iPhone 15")
        }
    }
    
    func testSearchProductsReturnsFilteredList() async throws {
        let mockRepo = MockProductRepository(stubProducts: mockProducts)
        var dependencies = DependencyValues()
        dependencies.productRepo = mockRepo
        
        await DependencyValues.$current.withValue(dependencies) {
            let vm = CatalogViewModel()
            
            vm.searchQuery = "MacBook"
            await vm.preformSearch()
            
            XCTAssertEqual(vm.products.count, 1)
            XCTAssertEqual(vm.products.first?.title, "MacBook Pro")
        }
    }
    
    func testEmptySearchQueryReloadsFullCatalog() async throws {
        let mockRepo = MockProductRepository(stubProducts: mockProducts)
        var dependencies = DependencyValues()
        dependencies.productRepo = mockRepo
        
        await DependencyValues.$current.withValue(dependencies) {
            let vm = CatalogViewModel()
            
            vm.searchQuery = ""
            await vm.preformSearch()
            
            XCTAssertEqual(vm.products.count, 2)
        }
    }
}
