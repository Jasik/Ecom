//
//  CatalogViewModelTests.swift
//  EcomTests
//

import Testing
@testable import Ecom

@Suite("CatalogViewModel Tests")
@MainActor
struct CatalogViewModelTests {
    let mockProducts = [
        Product(id: 1, title: "iPhone 15", description: "Phone", price: 999.0, images: [], thumbnail: ""),
        Product(id: 2, title: "MacBook Pro", description: "Laptop", price: 1999.0, images: [], thumbnail: "")
    ]
    
    @Test
    func testLoadProductsSuccessfully() async throws {
        let mockRepo = MockProductRepository(stubProducts: mockProducts)
        var dependencies = DependencyValues()
        dependencies.productRepo = mockRepo
        
        await DependencyValues.$current.withValue(dependencies) {
            let vm = CatalogViewModel()
            
            #expect(vm.products.isEmpty)
            #expect(vm.loadState.isLoading == false)
            
            await vm.load()
            
            #expect(vm.products.count == 2)
            #expect(vm.loadState.isLoading == false)
            #expect(vm.products.first?.title == "iPhone 15")
        }
    }
    
    @Test
    func testSearchProductsReturnsFilteredList() async throws {
        let mockRepo = MockProductRepository(stubProducts: mockProducts)
        var dependencies = DependencyValues()
        dependencies.productRepo = mockRepo
        
        await DependencyValues.$current.withValue(dependencies) {
            let vm = CatalogViewModel()
            
            vm.searchQuery = "MacBook"
            await vm.performSearch()
            
            #expect(vm.products.count == 1)
            #expect(vm.products.first?.title == "MacBook Pro")
        }
    }
    
    @Test
    func testEmptySearchQueryReloadsFullCatalog() async throws {
        let mockRepo = MockProductRepository(stubProducts: mockProducts)
        var dependencies = DependencyValues()
        dependencies.productRepo = mockRepo
        
        await DependencyValues.$current.withValue(dependencies) {
            let vm = CatalogViewModel()
            
            vm.searchQuery = ""
            await vm.performSearch()
            
            #expect(vm.products.count == 2)
        }
    }
}
