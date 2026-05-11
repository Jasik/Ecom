//
//  DependencyKeys.swift
//  Ecom
//

import Foundation

struct NetworkClientKey: DependencyKey {
    static let liveValue: any NetworkClient = LiveNetworkClient()
}

struct CartRepoKey: DependencyKey {
    static let liveValue: any CartRepository = LiveCartRepository()

    #if DEBUG
    static var previewValue: any CartRepository { PreviewCartRepository() }
    #endif
}

struct ProductRepoKey: DependencyKey {
    static let liveValue: any ProductRepository = LiveProductRepository()
    
    #if DEBUG
    static var previewValue: any ProductRepository { PreviewProductRepository() }
    #endif
}

extension DependencyValues {
    var apiClient: any NetworkClient {
        get { self[NetworkClientKey.self] }
        set { self[NetworkClientKey.self] = newValue }
    }
    
    var cartRepo: any CartRepository {
        get { self[CartRepoKey.self] }
        set { self[CartRepoKey.self] = newValue }
    }
    
    var productRepo: any ProductRepository {
        get { self[ProductRepoKey.self] }
        set { self[ProductRepoKey.self] = newValue }
    }
}