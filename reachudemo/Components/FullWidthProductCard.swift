import SwiftUI

struct FullWidthProductCard: View {
    let product: ReachuProduct
    let onAddToCart: () -> Void
    let onTap: () -> Void
    
    // Primary app color
    let primaryColor = Color(hex: "#7300f9")
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Product title
            Text("Recommended for you")
                .font(.headline)
                .fontWeight(.bold)
            
            // Product card
            VStack(alignment: .leading, spacing: 12) {
                // Product image
                if let imageURL = product.mainImageURL {
                    RemoteImage(url: imageURL) {
                        Rectangle()
                            .foregroundColor(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.2))
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            )
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Rectangle()
                        .foregroundColor(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .gray)
                        )
                }
                
                // Product information
                VStack(alignment: .leading, spacing: 8) {
                    Text(product.title.toTitleCase())
                        .font(.title3)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                    
                    if let description = product.description, !description.isEmpty {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .padding(.bottom, 4)
                    }
                    
                    HStack(alignment: .center) {
                        // Price
                        VStack(alignment: .leading, spacing: 4) {
                            if product.price.hasDiscount, let compareAtPrice = product.price.formattedCompareAtPrice {
                                Text(compareAtPrice)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .strikethrough()
                                
                                Text(product.formattedPrice)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(primaryColor)
                            } else {
                                Text(product.formattedPrice)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(primaryColor)
                            }
                        }
                        
                        Spacer()
                        
                        // Add to cart button
                        Button(action: onAddToCart) {
                            Text("Add to cart")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .foregroundColor(.white)
                                .background(primaryColor)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            .padding(16)
            .background(colorScheme == .dark ? Color.black.opacity(0.6) : Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(colorScheme == .dark ? Color.purple.opacity(0.3) : Color.clear, lineWidth: 1)
            )
            .onTapGesture(perform: onTap)
        }
    }
}

#Preview {
    let demoProduct = ReachuProduct(
        id: "1",
        images: [ReachuImage(url: "https://example.com/image.jpg", order: 0)],
        price: ReachuPrice(currency_code: "USD", amount: "39.99", compare_at: "59.99"),
        title: "Nordic Omega-3 Premium Fish Oil Supplement for Pregnancy",
        description: "High-quality omega-3 supplement specially formulated for pregnant women, supporting brain and eye development in babies."
    )
    
    return Group {
        FullWidthProductCard(
            product: demoProduct,
            onAddToCart: {},
            onTap: {}
        )
        .padding()
        .previewDisplayName("Light Mode")
        
        FullWidthProductCard(
            product: demoProduct,
            onAddToCart: {},
            onTap: {}
        )
        .padding()
        .background(Color.black)
        .environment(\.colorScheme, .dark)
        .previewDisplayName("Dark Mode")
    }
} 