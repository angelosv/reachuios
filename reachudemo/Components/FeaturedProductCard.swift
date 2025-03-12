import SwiftUI

struct FeaturedProductCard: View {
    let product: ReachuProduct
    let onTap: () -> Void
    let onFavorite: () -> Void
    
    @State private var isFavorite: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image container with favorite button
            ZStack(alignment: .topTrailing) {
                if let imageURL = product.mainImageURL {
                    RemoteImage(url: imageURL) {
                        Rectangle()
                            .foregroundColor(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.2))
                            .aspectRatio(1, contentMode: .fill)
                    }
                    .aspectRatio(1, contentMode: .fill)
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Rectangle()
                        .foregroundColor(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.2))
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.title)
                                .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .gray)
                        )
                }
                
                Button(action: {
                    isFavorite.toggle()
                    onFavorite()
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .white)
                        .padding(8)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                .padding(8)
            }
            
            // Product info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title.toTitleCase())
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                
                Text(product.formattedPrice)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#7300f9"))
            }
            .padding(.top, 8)
        }
        .padding(8)
        .background(colorScheme == .dark ? Color.black.opacity(0.6) : Color.white)
        .cornerRadius(16)
        .shadow(color: colorScheme == .dark ? Color.purple.opacity(0.3) : Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colorScheme == .dark ? Color.purple.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .onTapGesture(perform: onTap)
    }
}

#Preview {
    let demoProduct = ReachuProduct(
        id: "1",
        images: [ReachuImage(url: "https://example.com/image.jpg", order: 0)],
        price: ReachuPrice(currency_code: "Rp", amount: "150000"),
        title: "Demo Product",
        description: "This is a demo product description"
    )
    
    return Group {
        FeaturedProductCard(
            product: demoProduct,
            onTap: {},
            onFavorite: {}
        )
        .frame(width: 160)
        .padding()
        .previewDisplayName("Light Mode")
        
        FeaturedProductCard(
            product: demoProduct,
            onTap: {},
            onFavorite: {}
        )
        .frame(width: 160)
        .padding()
        .background(Color.black)
        .environment(\.colorScheme, .dark)
        .previewDisplayName("Dark Mode")
    }
}

// Extension for default stock images if needed
extension String {
    static func stockImageURL(for index: Int) -> String {
        let stockImages = [
            "https://images.unsplash.com/photo-1434389677669-e08b4cac3105?q=80&w=2940&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?q=80&w=3098&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1560769629-975ec94e6a86?q=80&w=3164&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1560343090-f0409e92791a?q=80&w=3164&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1542272604-787c3835535d?q=80&w=3026&auto=format&fit=crop"
        ]
        return stockImages[index % stockImages.count]
    }
} 