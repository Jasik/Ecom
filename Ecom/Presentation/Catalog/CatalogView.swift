//
//  CatalogView.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import SwiftUI

@MainActor
struct CatalogView: View {
    @Environment(ShopRouter.self) private var router
    @State private var vm: CatalogViewModel
    
    init() {
        _vm = State(wrappedValue: CatalogViewModel())
    }
    
    var body: some View {
        List(vm.products) { product in
            ProductRowView(product: product)
                .contentShape(Rectangle())
                .onTapGesture {
                    router.push(.productDetail(product: product))
                }
        }
        .listStyle(.plain)
        .navigationTitle("Catalog")
        .searchable(text: $vm.searchQuery, prompt: "search")
        .onSubmit(of: .search) { Task { await vm.preformSearch() } }
        .onChange(of: vm.searchQuery) { _, newValue in
            if newValue.isEmpty { Task { await vm.load() } }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.presentSheet(.cart)
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "cart")
                        if vm.cartCount > 0 {
                            Text("\(vm.cartCount)")
                                .font(.caption2).bold()
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.red, in: Circle())
                                .offset(x: 0, y: -3)
                        }
                    }
                }
            }
        }
        .overlay { if vm.isLoading { ProgressView() } }
        .task {
            async let fetchProducts: () = vm.load()
            async let listenCart: () = vm.observeCart()
            _ = await (fetchProducts, listenCart)
        }
    }
}

#Preview("Catalog") {
    PreviewWithDependencies { _ in
    } content: {
        NavigationStack {
            CatalogView()
        }
        .environment(ShopRouter())
    }
}

@MainActor
struct ProductRowView: View {
    let product: Product
    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: product.thumbnail)) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else { Color.gray.opacity(0.2) }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: product.title).font(.headline).lineLimit(2)
                Text(verbatim: product.formattedPrice).font(.subheadline).bold().foregroundStyle(.blue)
                Text(verbatim: product.description).font(.caption).foregroundStyle(.secondary).lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}
