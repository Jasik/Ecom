//
//  TaskBag.swift
//  Ecom
//

import Foundation

/// A container that manages the lifecycle of un-awaited `Task`s, cancelling them automatically upon deallocation
/// or when explicitly requested. Useful for ViewModels to tie background work to their own lifecycle.
@MainActor
public final class TaskBag {
    private var tasks: [Task<Void, Never>] = []
    
    /// Initializes an empty task bag.
    public init() {}
    
    /// Adds a task to the bag for lifecycle management.
    public func add(_ task: Task<Void, Never>) {
        tasks.append(task)
    }
    
    /// Cancels all tasks currently in the bag and empties it.
    public func cancelAll() {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }
    
    deinit {
        let currentTasks = tasks
        Task.detached {
            currentTasks.forEach { $0.cancel() }
        }
    }
}
