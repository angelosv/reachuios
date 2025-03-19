import SwiftUI

struct LiveProductCarousel: View {
    let products: [ReachuProduct]
    let onProductTap: (ReachuProduct) -> Void
    let onAddToCart: (ReachuProduct) -> Void
    
    @State private var currentPage = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    // Productos en carrusel horizontal a pantalla completa
                    TabView(selection: $currentPage) {
                        ForEach(0..<products.count, id: \.self) { index in
                            productCard(for: products[index], width: geometry.size.width - 32)
                                .tag(index)
                                .onTapGesture {
                                    onProductTap(products[index])
                                }
                                .padding(.bottom, 20)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Indicadores de página
                    HStack(spacing: 8) {
                        ForEach(0..<products.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color(hex: "#7300f9") : Color.gray.opacity(0.5))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.bottom, 4)
                }
                .frame(height: 160)
                .background(Color.clear) // Carrusel con fondo transparente
                .cornerRadius(16)
                .padding(.horizontal, 16)
            }
        }
        .frame(height: 160)
    }
    
    private func productCard(for product: ReachuProduct, width: CGFloat) -> some View {
        Button(action: {
            onProductTap(product)
        }) {
            HStack(spacing: 12) {
                // Imagen del producto
                if let imageURL = product.mainImageURL {
                    RemoteImage(url: imageURL) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80, height: 80)
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                // Información del producto
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.title)
                        .font(.headline)
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    Text(product.formattedPrice)
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#7300f9"))
                        .fontWeight(.bold)
                    
                    HStack(spacing: 10) {
                        Button(action: {
                            onAddToCart(product)
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "cart.badge.plus")
                                    .font(.system(size: 12))
                                Text("Add")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Color(hex: "#7300f9"))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            onProductTap(product)
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 12))
                                Text("Details")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(Color(hex: "#7300f9"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "#7300f9"), lineWidth: 1)
                            )
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background(Color.white) // Mantener fondo blanco para el producto
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: width)
    }
}

#Preview {
    let products = [
        ReachuProduct(
            id: "1",
            images: [ReachuImage(url: "https://picsum.photos/200", order: 0)],
            price: ReachuPrice(currency_code: "NOK", amount_incl_taxes: "299", compare_at_incl_taxes: "499"),
            title: "Vitamin C Serum",
            description: "Brightening serum for all skin types",
            supplier: "Beauty Lab"
        ),
        ReachuProduct(
            id: "2",
            images: [ReachuImage(url: "https://picsum.photos/201", order: 0)],
            price: ReachuPrice(currency_code: "NOK", amount_incl_taxes: "349", compare_at_incl_taxes: "599"),
            title: "Hyaluronic Acid Moisturizer",
            description: "Deep hydration for dry skin",
            supplier: "DermaCare"
        ),
        ReachuProduct(
            id: "3",
            images: [ReachuImage(url: "https://picsum.photos/202", order: 0)],
            price: ReachuPrice(currency_code: "NOK", amount_incl_taxes: "199", compare_at_incl_taxes: "299"),
            title: "Niacinamide Serum",
            description: "Reduces pores and improves skin texture",
            supplier: "SkinCeuticals"
        )
    ]
    
    ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        LiveProductCarousel(
            products: products,
            onProductTap: { _ in },
            onAddToCart: { _ in }
        )
        .padding(.vertical)
    }
} 