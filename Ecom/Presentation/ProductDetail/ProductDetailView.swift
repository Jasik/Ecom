//
//  ProductDetailView.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import SwiftUI

@MainActor
struct ProductDetailView: View {
    @State private var vm: ProductDetailViewModel
    
    init(product: Product) {
        _vm = State(wrappedValue: ProductDetailViewModel(product: product))
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Карусель фотографий (Используем TabView)
                TabView {
                    ForEach(vm.product.images, id: \.self) { imageUrl in
                        AsyncImage(url: URL(string: imageUrl)) { phase in
                            if let image = phase.image {
                                image.resizable().scaledToFit()
                            } else { ProgressView() }
                        }
                    }
                }
                .tabViewStyle(.page)
                .frame(height: 300)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Информация о товаре
                VStack(alignment: .leading, spacing: 12) {
                    Text(verbatim: vm.product.title).font(.title).bold()
                    Text(verbatim: "$\(vm.product.price)").font(.title2).foregroundStyle(.blue)
                    Text(verbatim: vm.product.description).font(.body)
                }
                .padding(.horizontal)
                
                // Кнопка добавления в корзину
                Button(action: { vm.addToCart() }) {
                    HStack {
                        Image(systemName: vm.isAddedToCart ? "checkmark" : "cart.badge.plus")
                        Text(vm.isAddedToCart ? "Добавлено" : "не добавлено")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(vm.isAddedToCart ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .animation(.easeInOut, value: vm.isAddedToCart)
                .padding(.horizontal)
                .padding(.top, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
