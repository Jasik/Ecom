//
//  LoadState.swift
//  Ecom
//

import Foundation

/// Represents the state of an asynchronous loading operation, suitable for driving UI.
public enum LoadState<Value: Sendable, Failure: Error & Sendable>: Sendable {
    /// The operation hasn't started yet.
    case idle
    /// The operation is currently in progress.
    case loading
    /// The operation completed successfully with a value.
    case loaded(Value)
    /// The operation failed with an error.
    case failed(Failure)
    /// The application is offline, potentially with a previously known value.
    case offline(lastKnown: Value?)
    
    /// Convenience property to extract the loaded or offline known value.
    public var value: Value? {
        switch self {
        case .loaded(let val), .offline(lastKnown: let val?): return val
        default: return nil
        }
    }
    
    public var error: Failure? {
        if case .failed(let err) = self { return err }
        return nil
    }
    
    public var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}
