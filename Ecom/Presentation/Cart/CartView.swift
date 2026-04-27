//
//  CartView.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import SwiftUI

@MainActor
struct CartView: View {
    @Environment(ShopRouter.self) private var router
    @State private var vm: CartViewModel
    
    init() {
        _vm = State(wrappedValue: CartViewModel())
    }
    
    var body: some View {
        VStack {
            if vm.items.isEmpty {
                ContentUnavailableView("Корзина пуста", systemImage: "cart")
            } else {
                List {
                    ForEach(vm.items) { product in
                        HStack {
                            AsyncImage(url: URL(string: product.thumbnail)) { img in
                                img.resizable().scaledToFill()
                            } placeholder: { Color.gray.opacity(0.1) }
                            .frame(width: 60, height: 60).clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            VStack(alignment: .leading) {
                                Text(product.title).font(.headline)
                                Text(product.formattedPrice).font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { offsets in
                        offsets.forEach { index in
                            vm.remove(productID: vm.items[index].id)
                        }
                    }
                }
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Итого:").font(.title3).bold()
                        Spacer()
                        Text(vm.totalPrice).font(.title3).bold()
                    }
                    .padding(.horizontal)
                    
                    Button {
                        router.pushCart(.checkout)
                    } label: {
                        Text("Оформить заказ")
                            .font(.headline).frame(maxWidth: .infinity)
                            .padding().background(Color.blue).foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Корзина")
        .task {
            await vm.startObserving()
        }
    }
}

#Preview("Cart") {
    NavigationStack {
        CartView()
    }
    .environment(ShopRouter())
}
