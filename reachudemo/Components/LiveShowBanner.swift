import SwiftUI

struct LiveShowBanner: View {
    let liveStream: LiveStream
    let action: () -> Void
    var currentProduct: ReachuProduct?
    var onAddToCart: (ReachuProduct) -> Void
    var onNextProduct: () -> Void
    var onPreviousProduct: () -> Void
    
    // Main app color
    let primaryColor = Color(hex: "#7300f9")
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            // Live Stream Banner
            Button(action: action) {
                HStack(spacing: 15) {
                    // Image on the left
                    AsyncImage(url: URL(string: liveStream.thumbnail)) { phase in
                        switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3))
                                    .frame(width: 120, height: 90)
                                    .cornerRadius(10)
                                    .overlay(
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                            .tint(primaryColor)
                                    )
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 90)
                                    .clipped()
                                    .cornerRadius(10)
                                    .overlay(
                                        VStack {
                                            HStack {
                                                Image(systemName: "dot.radiowaves.left.and.right")
                                                    .foregroundColor(primaryColor)
                                                Text("LIVE")
                                                    .font(.caption2)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                            }
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.black.opacity(0.6))
                                            .cornerRadius(4)
                                            .padding(6)
                                            
                                            Spacer()
                                        },
                                        alignment: .topLeading
                                    )
                            case .failure:
                                Rectangle()
                                    .fill(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3))
                                    .frame(width: 120, height: 90)
                                    .cornerRadius(10)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
                                    )
                            @unknown default:
                                Rectangle()
                                    .fill(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3))
                                    .frame(width: 120, height: 90)
                                    .cornerRadius(10)
                        }
                    }
                    
                    // Content on the right
                    VStack(alignment: .leading, spacing: 4) {
                        Text("COMING LIVE SOON")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(primaryColor)
                        
                        Text(liveStream.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(colorScheme == .dark ? .white : .primary)
                        
                        HStack {
                            if let hostName = liveStream.hostName {
                                Image(systemName: "person.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .secondary)
                                Text(hostName)
                                    .font(.caption)
                                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "clock.fill")
                                .font(.caption)
                                .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .secondary)
                            Text(DateFormatter.livestreamTimeFormatter.string(from: liveStream.createdAt))
                                .font(.caption)
                                .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .secondary)
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(colorScheme == .dark ? Color.black.opacity(0.6) : Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(colorScheme == .dark ? Color.purple.opacity(0.3) : Color.clear, lineWidth: 1)
                )
            }
            
            // Products Section
            if let product = currentProduct {
                VStack(spacing: 10) {
                    Text("Featured Products")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                    
                    ZStack {
                        // Producto Actual
                        LiveShowProductCard(
                            product: product,
                            onAddToCart: { onAddToCart(product) }
                        )
                        
                        // Botones de navegación
                        HStack {
                            Button(action: onPreviousProduct) {
                                Image(systemName: "chevron.left")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(primaryColor)
                                    .clipShape(Circle())
                            }
                            .padding(.leading, -10)
                            
                            Spacer()
                            
                            Button(action: onNextProduct) {
                                Image(systemName: "chevron.right")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(primaryColor)
                                    .clipShape(Circle())
                            }
                            .padding(.trailing, -10)
                        }
                        .padding(.horizontal, 25)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

// DateFormatter extension
extension DateFormatter {
    static let livestreamTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

#Preview {
    let demoLiveStream = LiveStream(
        id: 1,
        title: "Demo Live Stream",
        slug: "demo-stream",
        thumbnail: "https://example.com/thumbnail.jpg",
        broadcasting: true,
        createdAt: Date(),
        updatedAt: Date(),
        hostName: "Demo Host",
        description: "Demo Description",
        duration: 3600,
        viewerCount: 100,
        category: "Health"
    )
    
    let demoProduct = ReachuProduct(
        id: "1",
        images: [ReachuImage(url: "https://example.com/image.jpg", order: 0)],
        price: ReachuPrice(currency_code: "NOK", amount: "299", compare_at: "499"),
        title: "Beauty Cream With Vitamin E and Hyaluronic Acid",
        description: "Hydrating face cream with natural ingredients"
    )
    
    return Group {
        LiveShowBanner(
            liveStream: demoLiveStream,
            action: {},
            currentProduct: demoProduct,
            onAddToCart: { _ in },
            onNextProduct: {},
            onPreviousProduct: {}
        )
        .padding()
        .background(Color.gray.opacity(0.1))
        .previewDisplayName("Light Mode")
        
        LiveShowBanner(
            liveStream: demoLiveStream,
            action: {},
            currentProduct: demoProduct,
            onAddToCart: { _ in },
            onNextProduct: {},
            onPreviousProduct: {}
        )
        .padding()
        .background(Color.black)
        .environment(\.colorScheme, .dark)
        .previewDisplayName("Dark Mode")
    }
} 