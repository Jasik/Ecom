//
//  TaskBag.swift
//  Ecom
//
//  Owns a set of tasks with the lifetime of its holder. Cancels them on
//  `cancelAll()` or deinit. Intended for ViewModels that spawn long-lived
//  subscriptions or replaceable per-action tasks.
//

import Foundation

@MainActor
public final class TaskBag {
    private var tasks: [Task<Void, Never>] = []

    public init() {}

    public func add(_ task: Task<Void, Never>) {
        tasks.append(task)
    }

    /// Convenience overload — wraps the operation in a `Task` automatically.
    /// Returns the spawned task so callers can cancel/await it individually.
    @discardableResult
    public func add(
        priority: TaskPriority? = nil,
        _ operation: @escaping @MainActor () async -> Void
    ) -> Task<Void, Never> {
        let task = Task(priority: priority) { @MainActor in
            await operation()
        }
        tasks.append(task)
        return task
    }

    public func cancelAll() {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }

    deinit {
        tasks.forEach { $0.cancel() }
    }
}
