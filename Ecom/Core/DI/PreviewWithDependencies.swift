//
//  PreviewWithDependencies.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/27.
//

import SwiftUI

#if DEBUG
struct PreviewWithDependencies<Content: View>: View {
    private let update: (inout DependencyValues) -> Void
    private let content: () -> Content
    
    init(
        update: @escaping (inout DependencyValues) -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.update = update
        self.content = content
    }
    
    var body: some View {
        var dependencies = DependencyValues()
        update(&dependencies)
        return DependencyValues.$current.withValue(dependencies) {
            content()
        }
    }
}
#endif
