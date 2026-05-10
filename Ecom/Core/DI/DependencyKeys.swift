//
//  DependencyKeys.swift
//  Ecom
//
//  Single source of truth for all DependencyKey declarations and the
//  corresponding `DependencyValues` accessors. Feature files MUST NOT
//  declare their own keys.
//

import Foundation

// MARK: - Network

private struct NetworkClientKey: DependencyKey {
    static let liveValue: any NetworkClient = LiveNetworkClient()
}

extension DependencyValues {
    var apiClient: any NetworkClient {
        get { self[NetworkClientKey.self] }
        set { self[NetworkClientKey.self] = newValue }
    }
}

// MARK: - Product

private struct ProductRepoKey: DependencyKey {
    static let liveValue: any ProductRepository = LiveProductRepository()

    #if DEBUG
    static var previewValue: any ProductRepository { PreviewProductRepository() }
    #endif
}

extension DependencyValues {
    var productRepo: any ProductRepository {
        get { self[ProductRepoKey.self] }
        set { self[ProductRepoKey.self] = newValue }
    }
}

// MARK: - Cart

private struct CartRepoKey: DependencyKey {
    static let liveValue: any CartRepository = LiveCartRepository()

    #if DEBUG
    static var previewValue: any CartRepository { PreviewCartRepository() }
    #endif
}

extension DependencyValues {
    var cartRepo: any CartRepository {
        get { self[CartRepoKey.self] }
        set { self[CartRepoKey.self] = newValue }
    }
}
