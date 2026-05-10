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
    private var storage: [ObjectIdentifier: any Sendable] = [:]

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

/// Property wrapper that resolves a dependency lazily on every access via the
/// current `TaskLocal` `DependencyValues`. Storing the keyPath instead of the
/// resolved value lets factory-constructed owners (e.g. struct repositories)
/// honour test/preview overrides applied AFTER their initialisation.
///
/// Marked `@unchecked Sendable` because Swift 6 still types `\.dependency`
/// literals as `WritableKeyPath` when the accessor has a setter, and
/// `WritableKeyPath` is not auto-Sendable. Capturing it here is safe — the
/// keyPath is immutable and only used as a lookup token.
@propertyWrapper
struct Injected<T: Sendable>: @unchecked Sendable {
    private let keyPath: KeyPath<DependencyValues, T>

    init(_ keyPath: KeyPath<DependencyValues, T>) {
        self.keyPath = keyPath
    }

    var wrappedValue: T { DependencyValues.current[keyPath: keyPath] }
}
