//
//  TaskBag.swift
//  Ecom
//

import Foundation

@MainActor
public final class TaskBag {
    private var tasks: [Task<Void, Never>] = []
    
    public init() {}
    
    public func add(_ task: Task<Void, Never>) {
        tasks.append(task)
    }
    
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
