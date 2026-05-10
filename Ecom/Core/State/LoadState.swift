//
//  LoadState.swift
//  Ecom
//
//  Single explicit state for any "load value of type T" scenario.
//  Replaces ad-hoc combinations of `isLoading: Bool` / `error: Error?` /
//  `value: T?` that produce illegal intermediate states.
//

import Foundation

/// State machine for loadable values.
///
/// `loaded` carries `Freshness` so the View can render a stale-data badge
/// (e.g. "no signal" for a camera feed) without needing a separate case.
/// `failed` carries the last successful value so offline UI can keep showing
/// it. This collapses the `loaded`/`offline(lastKnown:)` pair into a single
/// rendering branch.
public nonisolated enum LoadState<Value: Sendable, Failure: Error & Sendable>: Sendable {
    case loading
    case loaded(Value, freshness: Freshness)
    case failed(Failure, lastKnown: Value?)

    public nonisolated enum Freshness: Sendable, Equatable {
        case live
        case stale(since: Date)
    }
}

public extension LoadState {
    /// The freshest value available, including the cached one carried in `failed`.
    var value: Value? {
        switch self {
        case .loading: nil
        case .loaded(let v, _): v
        case .failed(_, let last): last
        }
    }

    var error: Failure? {
        if case .failed(let e, _) = self { return e } else { return nil }
    }

    var isLoading: Bool {
        if case .loading = self { return true } else { return false }
    }

    /// Convenience builder for the common "fresh load just succeeded" case.
    static func fresh(_ value: Value) -> Self { .loaded(value, freshness: .live) }
}
