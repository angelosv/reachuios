import SwiftUI

struct ReachuProductCard: View {
    let product: ReachuProduct
    let onTap: () -> Void
    let onAddToCart: () -> Void
    
    // Primary app color
    let primaryColor = Color(hex: "#7300f9")
    @State private var isFavorite: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image with favorite button
            ZStack(alignment: .topTrailing) {
                if let imageURL = product.mainImageURL {
                    RemoteImage(url: imageURL) {
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.2))
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            )
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 150)
                    .clipped()
                    .cornerRadius(12)
                } else {
                    // Fallback image if no URL is available
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.2))
                        .frame(height: 150)
                        .cornerRadius(12)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
                
                // Favorite button
                Button(action: {
                    isFavorite.toggle()
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .white)
                        .padding(6)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                .padding(8)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title.toTitleCase())
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Spacer()
                    .frame(height: 4)
                
                HStack(alignment: .center) {
                    // Price on the left
                    if product.price.hasDiscount, let compareAtPrice = product.price.formattedCompareAtPrice {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(compareAtPrice)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .strikethrough()
                            
                            Text(product.formattedPrice)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(primaryColor)
                        }
                    } else {
                        Text(product.formattedPrice)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(primaryColor)
                    }
                    
                    Spacer()
                    
                    // Add to cart button (simplified)
                    Button(action: onAddToCart) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(primaryColor)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 4)
            .padding(.bottom, 8)
        }
        .padding(8)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        .onTapGesture(perform: onTap)
    }
} 