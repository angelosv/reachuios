import SwiftUI

struct FeaturedProductCard: View {
    let product: Product
    let action: () -> Void
    
    // Main app color
    let primaryColor = Color(hex: "#7300f9")
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                // Background image
                Image(product.imageName)
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(12)
                
                // Overlay content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("FEATURED")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(primaryColor)
                            .cornerRadius(4)
                        
                        Spacer()
                        
                        if product.isAvailable {
                            Text("In Stock")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(4)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(product.description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(2)
                        
                        HStack {
                            // Rating
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", product.rating))
                                    .foregroundColor(.white)
                                Text("(\(product.reviewCount))")
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .font(.caption)
                            
                            Spacer()
                            
                            // Price
                            Text(product.formattedPrice)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
            }
        }
        .padding(.horizontal)
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

#Preview {
    FeaturedProductCard(
        product: Product.sampleFeaturedProducts[0],
        action: {}
    )
} 