import SwiftUI

struct ReachuProductCard: View {
    let product: ReachuProduct
    let onTap: () -> Void
    let onAddToCart: () -> Void
    
    // Primary app color
    let primaryColor = Color(hex: "#7300f9")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // Changed spacing to 0 for image to edge
            // Image using RemoteImage for remote image loading
            Button(action: onTap) {
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
                    // Removed corner radius from image
                } else {
                    // Fallback image if no URL is available
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.2))
                        .frame(height: 150)
                        // Removed corner radius from fallback
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Button(action: onTap) {
                    Text(product.title.toTitleCase())
                        .font(.headline)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 50) // Fixed height for title
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                    .frame(height: 8)
                
                HStack {
                    // Price on the left
                    Text(product.formattedPrice)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(primaryColor)
                    
                    Spacer()
                    
                    // Cart icon button on the right
                    Button(action: onAddToCart) {
                        Image(systemName: "cart.fill.badge.plus")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(primaryColor)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(12)
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12) // Keep corner radius on whole card
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        // Apply clipShape after the whole styling to ensure image extends to edge but card has corners
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
} 