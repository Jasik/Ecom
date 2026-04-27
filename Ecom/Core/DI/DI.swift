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
