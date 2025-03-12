import SwiftUI

struct ApolloProductCard: View {
    let product: ApolloProduct
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Product Image
            if let imageUrl = product.mainImageUrl {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.3))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 150)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.3))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.3))
                    }
                }
                .cornerRadius(8)
            } else {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.3))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
                    .cornerRadius(8)
            }
            
            // Product Title
            Text(product.title)
                .font(.headline)
                .lineLimit(2)
                .foregroundColor(.primary)
            
            // Product Price
            if let price = product.price {
                HStack {
                    Text(price.formattedPrice)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if price.hasDiscount, let comparePrice = price.compareAtFormattedPrice {
                        Text(comparePrice)
                            .font(.caption)
                            .strikethrough()
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Stock indicator
                    if let inventory = product.inventory, inventory.isInStock {
                        Text("In Stock")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Text("Out of Stock")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ApolloProductCard_Previews: PreviewProvider {
    static var previews: some View {
        let sampleProduct = ApolloProduct(
            id: "1",
            title: "Sample Product with a very long name that might need truncation",
            description: "This is a sample product description",
            images: [
                ApolloImage(url: URL(string: "https://example.com/image.jpg")!, order: 1, id: "img1")
            ],
            price: ApolloPrice(
                currencyCode: "USD",
                amount: "29.99",
                compareAtAmount: "39.99"
            ),
            category: "Sample Category",
            variants: [],
            inventory: ApolloInventory(available: 10, isInStock: true)
        )
        
        return Group {
            ApolloProductCard(product: sampleProduct)
                .frame(width: 180)
                .padding()
                .previewLayout(.sizeThatFits)
            
            ApolloProductCard(product: sampleProduct)
                .preferredColorScheme(.dark)
                .frame(width: 180)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
} 