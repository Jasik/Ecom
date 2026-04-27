//
//  DI.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

protocol DependencyKey: Sendable {
    associatedtype Value: Sendable
    static var liveValue: Value { get }
    
    #if DEBUG
    static var previewValue: Value { get }
    #endif
}

#if DEBUG
extension DependencyKey {
    static var previewValue: Value { liveValue }
}
#endif

struct DependencyValues: Sendable {
    @TaskLocal static var current = DependencyValues()
    private var storage: [ObjectIdentifier: Any] = [:]
    
    #if DEBUG
    private let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    #endif
    
    subscript<K: DependencyKey>(key: K.Type) -> K.Value {
        get {
            #if DEBUG
            if let mock = storage[ObjectIdentifier(key)] as? K.Value {
                return mock
            }
            
            if isPreview {
                return K.previewValue
            }
            #endif
            return K.liveValue
        }
        set { storage[ObjectIdentifier(key)] = newValue }
    }
}

@propertyWrapper
struct Injected<T: Sendable>: Sendable {
    private let resolvedValue: T
    
    init(_ keyPath: KeyPath<DependencyValues, T>) {
        self.resolvedValue = DependencyValues.current[keyPath: keyPath]
    }
    var wrappedValue: T { resolvedValue }
}

private struct GetProductsKey: DependencyKey { static let liveValue = GetProductsUseCase() }
private struct SearchProductsKey: DependencyKey { static let liveValue = SearchProductsUseCase() }
private struct AddToCartKey: DependencyKey { static let liveValue = AddToCartUseCase() }
private struct RemoveFromCartKey: DependencyKey { static let liveValue = RemoveFromCartUseCase() }
private struct ObserveCartItemsKey: DependencyKey { static let liveValue = ObserveCartItemsUseCase() }
private struct ObserveCartCountKey: DependencyKey { static let liveValue = ObserveCartCountUseCase() }

extension DependencyValues {
    var getProductsUseCase: GetProductsUseCase {
        get { self[GetProductsKey.self] }
        set { self[GetProductsKey.self] = newValue }
    }
    
    var searchProductsUseCase: SearchProductsUseCase {
        get { self[SearchProductsKey.self] }
        set { self[SearchProductsKey.self] = newValue }
    }
    
    var addToCartUseCase: AddToCartUseCase {
        get { self[AddToCartKey.self] }
        set { self[AddToCartKey.self] = newValue }
    }
    
    var removeFromCartUseCase: RemoveFromCartUseCase {
        get { self[RemoveFromCartKey.self] }
        set { self[RemoveFromCartKey.self] = newValue }
    }
    
    var observeCartItemsUseCase: ObserveCartItemsUseCase {
        get { self[ObserveCartItemsKey.self] }
        set { self[ObserveCartItemsKey.self] = newValue }
    }
    
    var observeCartCountUseCase: ObserveCartCountUseCase {
        get { self[ObserveCartCountKey.self] }
        set { self[ObserveCartCountKey.self] = newValue }
    }
}
