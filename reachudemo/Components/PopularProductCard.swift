import SwiftUI

struct PopularProductCard: View {
    let product: ReachuProduct
    let onTap: () -> Void
    let onAddToCart: () -> Void
    
    let primaryColor = Color(hex: "#7300f9")
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Product image
            if let imageURL = product.mainImageURL {
                RemoteImage(url: imageURL) {
                    Rectangle()
                        .foregroundColor(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.2))
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Rectangle()
                    .foregroundColor(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title)
                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .gray)
                    )
            }
            
            // Product details
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title.toTitleCase())
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                
                Spacer()
                
                // Price and add button
                HStack {
                    if product.price.hasDiscount, let compareAtPrice = product.price.formattedCompareAtPrice {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(compareAtPrice)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .strikethrough()
                            
                            Text(product.formattedPrice)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(primaryColor)
                        }
                    } else {
                        Text(product.formattedPrice)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(primaryColor)
                    }
                    
                    Spacer()
                    
                    Button(action: onAddToCart) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .padding(5)
                            .background(primaryColor)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorScheme == .dark ? Color.black.opacity(0.6) : Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(colorScheme == .dark ? Color.purple.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .onTapGesture(perform: onTap)
    }
}

#Preview {
    let demoProduct = ReachuProduct(
        id: "1", 
        images: [ReachuImage(url: "https://example.com/image.jpg", order: 0)],
        price: ReachuPrice(currency_code: "Rp", amount_incl_taxes: "150000"),
        title: "Stylish Modern Hoodie for All Seasons",
        description: "This is a demo product description",
        supplier: "Fashion World"
    )
    
    Group {
        PopularProductCard(
            product: demoProduct,
            onTap: {},
            onAddToCart: {}
        )
        .frame(height: 120)
        .padding()
        .previewDisplayName("Light Mode")
        
        PopularProductCard(
            product: demoProduct,
            onTap: {},
            onAddToCart: {}
        )
        .frame(height: 120)
        .padding()
        .background(Color.black)
        .environment(\.colorScheme, .dark)
        .previewDisplayName("Dark Mode")
    }
} 