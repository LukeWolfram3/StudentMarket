//
//  ProductsView.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 1/16/25.
//

import SwiftUI



@MainActor
struct ProductsView: View {
    
    @State private var viewModel = ProductsViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.products) { product in
                ProductCellView(product: product)
                    .contextMenu(menuItems: {
                        Button("Add to favorite") {
                            viewModel.addUserFavoriteProduct(productId: product.id)
                        }
                    })
                
                if product == viewModel.products.last {
                    ProgressView()
                        .onAppear {
                            viewModel.getProducts()
                        }
                }
            }
        }
                .navigationTitle("Products")
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        Menu("Filter: \(viewModel.selectedFilter?.rawValue ?? "NONE")") {
                            ForEach(ProductsViewModel.FilterOption.allCases, id: \.self) { filterOption in
                                Button(filterOption.rawValue) {
                                    Task {
                                       try? await viewModel.filterSelected(option: filterOption)
                                    }
                                }
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu("Category: \(viewModel.selectedCategory?.rawValue ?? "NONE")") {
                            ForEach(ProductsViewModel.CategoryOption.allCases, id: \.self) { option in
                                Button(option.rawValue) {
                                    Task {
                                       try? await viewModel.categorySelected(option: option)
                                    }
                                }
                            }
                        }
                    }
                })
                .onAppear {
                    //                            viewModel.getProductsCount()
                    viewModel.getProducts()
                }
    }
        
}

#Preview {
    NavigationStack {
        ProductsView()
    }
}
