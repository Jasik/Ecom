//
//  ObserveCartCountUseCase.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

struct ObserveCartCountUseCase: Sendable {
    @Injected(\.cartRepo) private var repo
    
    func execute() async -> AsyncStream<Int> {
        return await repo.observeCartCount()
    }
}
