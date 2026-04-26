//
//  ObserveCartItemsUseCase.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

struct ObserveCartItemsUseCase: Sendable {
    @Injected(\.cartRepo) private var repo
    
    func execute() async -> AsyncStream<[Product]> {
        await repo.observeCartItems()
    }
}
