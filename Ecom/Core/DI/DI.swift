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
}

struct DependencyValues: Sendable {
    @TaskLocal static var current = DependencyValues()
    private var storage: [ObjectIdentifier: Any] = [:]
    init() {}
    subscript<K: DependencyKey>(key: K.Type) -> K.Value {
        get { storage[ObjectIdentifier(key)] as? K.Value ?? K.liveValue }
        set { storage[ObjectIdentifier(key)] = newValue }
    }
}

@propertyWrapper
struct Injected<T: Sendable>: Sendable {
    private let keyPath: KeyPath<DependencyValues, T>
    init(_ keyPath: KeyPath<DependencyValues, T>) {
        self.keyPath = keyPath
    }
    var wrappedValue: T { DependencyValues.current[keyPath: keyPath] }
}

