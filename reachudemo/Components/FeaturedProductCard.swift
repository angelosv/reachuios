import SwiftUI

struct FeaturedProductCard: View {
    let product: Product
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                // Imagen de fondo
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
                
                // Contenido superpuesto
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("FEATURED")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
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

#Preview {
    FeaturedProductCard(
        product: Product.sampleFeaturedProducts[0],
        action: {}
    )
} 