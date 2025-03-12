import SwiftUI

struct LiveShowProductCard: View {
    let product: ReachuProduct
    let onAddToCart: () -> Void
    let primaryColor = Color(hex: "#7300f9")
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 15) {
            // Imagen a la izquierda
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
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Rectangle()
                    .foregroundColor(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title)
                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .gray)
                    )
            }
            
            // Detalles a la derecha
            VStack(alignment: .leading, spacing: 8) {
                Text(product.title.toTitleCase())
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                
                Spacer()
                
                if product.price.hasDiscount, let compareAtPrice = product.price.formattedCompareAtPrice {
                    HStack(spacing: 4) {
                        Text(compareAtPrice)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .strikethrough()
                        
                        Text(product.formattedPrice)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(primaryColor)
                    }
                } else {
                    Text(product.formattedPrice)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(primaryColor)
                }
                
                Button(action: onAddToCart) {
                    HStack {
                        Text("Add to Cart")
                            .fontWeight(.medium)
                        
                        Image(systemName: "cart.badge.plus")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(primaryColor)
                    .cornerRadius(8)
                }
            }
            .padding(.vertical, 12)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorScheme == .dark ? Color.black.opacity(0.6) : Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colorScheme == .dark ? Color.purple.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

#Preview {
    let demoProduct = ReachuProduct(
        id: "1",
        images: [ReachuImage(url: "https://example.com/image.jpg", order: 0)],
        price: ReachuPrice(currency_code: "NOK", amount: "299", compare_at: "499"),
        title: "Beauty Cream With Vitamin E and Hyaluronic Acid",
        description: "Hydrating face cream with natural ingredients"
    )
    
    return Group {
        LiveShowProductCard(
            product: demoProduct,
            onAddToCart: {}
        )
        .padding()
        .previewDisplayName("Light Mode")
        
        LiveShowProductCard(
            product: demoProduct,
            onAddToCart: {}
        )
        .padding()
        .background(Color.black)
        .environment(\.colorScheme, .dark)
        .previewDisplayName("Dark Mode")
    }
} 