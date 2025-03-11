import SwiftUI

struct ReachuProductCard: View {
    let product: ReachuProduct
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image using RemoteImage for remote image loading
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
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Spacer()
                    .frame(height: 8)
                
                HStack {
                    Spacer()
                    
                    // Price
                    Text(product.formattedPrice)
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                
                Button(action: action) {
                    Text("Add to Cart")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
        }
        .padding(12)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
} 