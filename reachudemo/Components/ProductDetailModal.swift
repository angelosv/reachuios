import SwiftUI

struct ProductDetailModal: View {
    let product: ReachuProduct
    @Binding var isPresented: Bool
    @State private var selectedSize: String?
    @State private var selectedColor: String?
    @State private var quantity: Int = 1
    let onAddToCart: (ReachuProduct) -> Void
    
    // Tamaños posibles
    let sizes = ["S", "M", "L", "XL"]
    
    // Colores posibles (estos son ejemplos, se podría adaptar para usar los colores reales del producto)
    let colors = ["Broken White", "Charcoal Black", "Jade Green"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Sección de imagen del producto con numeración
                ZStack(alignment: .bottom) {
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
                        .frame(maxWidth: .infinity)
                        .frame(height: 400)
                        .clipped()
                    }
                    
                    // Indicador de página
                    HStack {
                        Text("1")
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white)
                            .cornerRadius(4)
                        
                        Text("/")
                        
                        Text("10")
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                    }
                    .font(.caption)
                    .padding(.bottom, 12)
                }
                
                // Categoría y título
                VStack(alignment: .leading, spacing: 8) {
                    Text("EXECUTIVELY")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(product.title.toTitleCase())
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Precio con descuento
                    HStack(alignment: .center, spacing: 12) {
                        Text(product.formattedPrice)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#7300f9"))
                        
                        // Precio original tachado (simulado)
                        let originalPrice = (Double(product.price.amount) ?? 0) * 1.25
                        Text("\(product.price.currency_code) \(String(format: "%.0f", originalPrice))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .strikethrough()
                        
                        Text("20%")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(4)
                    }
                }
                .padding(.horizontal)
                
                // Selector de tamaño
                VStack(alignment: .leading, spacing: 12) {
                    Text("SIZE")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 10) {
                        ForEach(sizes, id: \.self) { size in
                            Button(action: {
                                selectedSize = size
                            }) {
                                Text(size)
                                    .frame(width: 40, height: 40)
                                    .background(selectedSize == size ? Color(hex: "#7300f9") : Color.gray.opacity(0.1))
                                    .foregroundColor(selectedSize == size ? .white : .black)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Selector de color
                VStack(alignment: .leading, spacing: 12) {
                    Text("COLOR")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 10) {
                        ForEach(colors, id: \.self) { color in
                            Button(action: {
                                selectedColor = color
                            }) {
                                Text(color)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(selectedColor == color ? Color(hex: "#7300f9") : Color.gray.opacity(0.1))
                                    .foregroundColor(selectedColor == color ? .white : .black)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Selector de cantidad
                VStack(alignment: .leading, spacing: 12) {
                    Text("QUANTITY")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        Button(action: {
                            if quantity > 1 {
                                quantity -= 1
                            }
                        }) {
                            Image(systemName: "minus")
                                .frame(width: 30, height: 30)
                                .foregroundColor(.black)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(4)
                        }
                        
                        Text("\(quantity)")
                            .font(.body)
                            .frame(width: 40, height: 30)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            quantity += 1
                        }) {
                            Image(systemName: "plus")
                                .frame(width: 30, height: 30)
                                .foregroundColor(.black)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Descripción del producto
                VStack(alignment: .leading, spacing: 12) {
                    Text("PRODUCT DESCRIPTION")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(product.description ?? "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Id et a mus massa pellentesque arcu turpis amet. Vestibulum a eu nunc orci massa, erat gravida egestas. Pretium dictumst nisi, scelerisque blandit elementum arcu. Tincidunt eget in justo tellus. Netus mauris...")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(4)
                    
                    Button(action: {}) {
                        Text("Read more")
                            .font(.caption)
                            .foregroundColor(Color(hex: "#7300f9"))
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Botón de añadir al carrito
                Button(action: {
                    onAddToCart(product)
                    isPresented = false
                }) {
                    Text("Add to Cart")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#7300f9"))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
        .overlay(
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.black)
                    .font(.title3)
                    .padding(8)
                    .background(Color.white.opacity(0.8))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
            }
            .padding(.top, 16)
            .padding(.trailing, 16),
            alignment: .topTrailing
        )
    }
}

// Extensión para soportar color hexadecimal
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 