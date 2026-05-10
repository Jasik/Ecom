//
//  CatalogViewModelTests.swift
//  EcomTests
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Testing
import Foundation
@testable import Ecom

@MainActor
@Suite struct CatalogViewModelTests {
    let mockProducts = [
        Product(id: 1, title: "iPhone 15", description: "Phone", price: 999.0, images: [], thumbnail: ""),
        Product(id: 2, title: "MacBook Pro", description: "Laptop", price: 1999.0, images: [], thumbnail: "")
    ]

    @Test func loadProductsSuccessfully() async {
        let mockRepo = MockProductRepository(stubProducts: mockProducts)
        var deps = DependencyValues()
        deps.productRepo = mockRepo

        await DependencyValues.$current.withValue(deps) {
            let vm = CatalogViewModel()
            #expect(vm.loadState.isLoading)

            await vm.load()

            #expect(vm.loadState.value?.count == 2)
            #expect(vm.loadState.value?.first?.title == "iPhone 15")
            #expect(!vm.loadState.isLoading)
        }
    }

    @Test func searchProductsReturnsFilteredList() async {
        let mockRepo = MockProductRepository(stubProducts: mockProducts)
        var deps = DependencyValues()
        deps.productRepo = mockRepo

        await DependencyValues.$current.withValue(deps) {
            let vm = CatalogViewModel()
            vm.searchQuery = "MacBook"
            await vm.performSearch()

            #expect(vm.loadState.value?.count == 1)
            #expect(vm.loadState.value?.first?.title == "MacBook Pro")
        }
    }

    @Test func emptySearchQueryReloadsFullCatalog() async {
        let mockRepo = MockProductRepository(stubProducts: mockProducts)
        var deps = DependencyValues()
        deps.productRepo = mockRepo

        await DependencyValues.$current.withValue(deps) {
            let vm = CatalogViewModel()
            vm.searchQuery = ""
            await vm.performSearch()

            #expect(vm.loadState.value?.count == 2)
        }
    }

    @Test func loadFailurePreservesLastKnownValue() async {
        let mockRepo = MockProductRepository(stubProducts: mockProducts)
        var deps = DependencyValues()
        deps.productRepo = mockRepo

        await DependencyValues.$current.withValue(deps) {
            let vm = CatalogViewModel()
            await vm.load()
            #expect(vm.loadState.value?.count == 2)

            var deps2 = DependencyValues()
            deps2.productRepo = MockProductRepository(stubProducts: [], shouldThrowError: true)
            await DependencyValues.$current.withValue(deps2) {
                await vm.load()
            }
            #expect(vm.loadState.error != nil)
            #expect(vm.loadState.value?.count == 2, "lastKnown should survive a failed reload")
        }
    }
}
