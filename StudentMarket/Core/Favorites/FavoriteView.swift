//
//  FavoriteView.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 1/23/25.
//

import SwiftUI


@MainActor
struct FavoriteView: View {
    
    @State private var viewModel = FavoriteViewModel()
    @State private var didAppear: Bool = false
    
    var body: some View {
        List {
            ForEach(viewModel.userFavoriteProducts, id: \.id.self) { item in
                ProductCellViewBuilder(productId: String(item.productId))
                    .contextMenu {
                        Button("Remove from favorites") {
                            viewModel.removeFromFavorites(favoriteProductId: item.id)
                        }
                    }
            }
        }
        .navigationTitle("Favorites")
        .onFirstAppear {
            viewModel.addListenerForFavorites()
        }
    }
}

#Preview {
    FavoriteView()
}


