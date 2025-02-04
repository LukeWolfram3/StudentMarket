//
//  ProductCellView.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 1/19/25.
//

import SwiftUI

struct ProductCellView: View {
    
    let product: Product
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: URL(string: product.thumbnail)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 75, height: 75)
                    .cornerRadius(10)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 75, height: 75)
            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("Price: $" + String(product.price))
                Text("Rating: " + String(product.rating))
                Text("Category: " + product.category)
                Text("Brand: " + (product.brand ?? "n/a"))
            }
            .font(.callout)
            .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ProductCellView(product: Product(id: 1, title: "Test", description: "Test", category: "Test", price: 20, discountPercentage: 20, rating: 20, stock: 20, tags: ["test"], brand: "Test", sku: "Test", weight: 1, dimensions: Dimensions(width: 20, height: 20, depth: 20), warrantyInformation: "Test", shippingInformation: "Test", availabilityStatus: "Test", reviews: [Review(rating: 1, comment: "Test", date: "Test", reviewerName: "Test", reviewerEmail: "Test")], returnPolicy: "Test", minimumOrderQuantity: 1, meta: Meta(createdAt: "Test", updatedAt: "Test", barcode: "Test", qrCode: "Test"), images: ["Test"], thumbnail: "Test"))
}
