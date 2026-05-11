//
//  LoadState.swift
//  Ecom
//

import Foundation

public enum LoadState<Value: Sendable, Failure: Error & Sendable>: Sendable {
    case idle
    case loading
    case loaded(Value)
    case failed(Failure)
    case offline(lastKnown: Value?)
    
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
