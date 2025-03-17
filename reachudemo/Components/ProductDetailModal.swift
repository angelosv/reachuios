import SwiftUI

// Class to store selections by product ID
class ProductSelections {
    static private var selectedSizeMap: [String: String] = [:]
    static private var selectedColorMap: [String: String] = [:]
    static private var quantityMap: [String: Int] = [:]
    
    static func getSelectedSize(for productId: String) -> String? {
        return selectedSizeMap[productId]
    }
    
    static func setSelectedSize(for productId: String, size: String?) {
        selectedSizeMap[productId] = size
    }
    
    static func getSelectedColor(for productId: String) -> String? {
        return selectedColorMap[productId]
    }
    
    static func setSelectedColor(for productId: String, color: String?) {
        selectedColorMap[productId] = color
    }
    
    static func getQuantity(for productId: String) -> Int {
        return quantityMap[productId] ?? 1
    }
    
    static func setQuantity(for productId: String, quantity: Int) {
        quantityMap[productId] = quantity
    }
}

struct ProductDetailModal: View {
    let product: ReachuProduct
    @Binding var isPresented: Bool
    @State private var selectedSize: String?
    @State private var selectedColor: String?
    @State private var quantity: Int = 1
    let onAddToCart: (ReachuProduct, String?, String?, Int) -> Void
    
    // Main app color
    let primaryColor = Color(hex: "#7300f9")
    
    // Possible sizes
    let sizes = ["S", "M", "L", "XL"]
    
    // Possible colors
    let colors = ["Broken White", "Charcoal Black", "Jade Green"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Product image section with pagination
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
                    
                    // Page indicator
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
                
                // Category and title
                VStack(alignment: .leading, spacing: 8) {
                    Text("EXECUTIVELY")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(product.title.toTitleCase())
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Price with discount
                    HStack(alignment: .center, spacing: 12) {
                        Text(product.formattedPrice)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(primaryColor)
                        
                        // Original price (simulated)
                        let originalPrice = (Double(product.price.amount) ?? 0) * 1.25
                        Text("\(product.price.currency_code) \(String(format: "%.0f", originalPrice))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .strikethrough()
                        
                        Text("20%")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(primaryColor.opacity(0.2))
                            .foregroundColor(primaryColor)
                            .cornerRadius(4)
                    }
                }
                .padding(.horizontal)
                
                // Size selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("SIZE")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 10) {
                        ForEach(sizes, id: \.self) { size in
                            Button(action: {
                                selectedSize = size
                                // Save selection using helper class
                                ProductSelections.setSelectedSize(for: product.id, size: size)
                                print("Size selected: \(size)")
                            }) {
                                Text(size)
                                    .frame(width: 40, height: 40)
                                    .background(selectedSize == size ? primaryColor : Color.gray.opacity(0.1))
                                    .foregroundColor(selectedSize == size ? .white : .black)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Color selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("COLOR")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 10) {
                        ForEach(colors, id: \.self) { color in
                            Button(action: {
                                selectedColor = color
                                // Save selection using helper class
                                ProductSelections.setSelectedColor(for: product.id, color: color)
                                print("Color selected: \(color)")
                            }) {
                                Text(color)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(selectedColor == color ? primaryColor : Color.gray.opacity(0.1))
                                    .foregroundColor(selectedColor == color ? .white : .black)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Quantity selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("QUANTITY")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        Button(action: {
                            if quantity > 1 {
                                quantity -= 1
                                // Save quantity using helper class
                                ProductSelections.setQuantity(for: product.id, quantity: quantity)
                                print("Quantity decreased: \(quantity)")
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
                            // Save quantity using helper class
                            ProductSelections.setQuantity(for: product.id, quantity: quantity)
                            print("Quantity increased: \(quantity)")
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
                
                // Product description
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
                            .foregroundColor(primaryColor)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Add to cart button
                Button(action: {
                    // Debug log
                    print("Add to Cart pressed - Size: \(selectedSize ?? "nil"), Color: \(selectedColor ?? "nil"), Quantity: \(quantity)")
                    
                    // Directly call the callback with current values
                    onAddToCart(product, selectedSize, selectedColor, quantity)
                    isPresented = false
                }) {
                    Text("Add to Cart")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedSize != nil && selectedColor != nil ? primaryColor : Color.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedSize != nil && selectedColor != nil ? primaryColor : Color.gray, lineWidth: 1.5)
                        )
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
                .disabled(selectedSize == nil || selectedColor == nil)
            }
        }
        .onAppear {
            // Initialize with previous selections if they exist
            selectedSize = ProductSelections.getSelectedSize(for: product.id) ?? "M"  // Default to M size
            selectedColor = ProductSelections.getSelectedColor(for: product.id) ?? "Broken White" // Default color
            quantity = ProductSelections.getQuantity(for: product.id)
            
            // Debug log on start
            print("ProductDetailModal onAppear - Product ID: \(product.id), Title: \(product.title)")
            print("Initial selections - Size: \(selectedSize ?? "nil"), Color: \(selectedColor ?? "nil"), Quantity: \(quantity)")
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
            }
            .padding(.top, 16)
            .padding(.trailing, 16),
            alignment: .topTrailing
        )
    }
    
    private func adjustParallax() {
        // ...existing code...
    }
}

// Extensión para soportar color hexadecimal
// Movida a AppTheme.swift para centralizar su uso
// extension Color {
//     init(hex: String) { ... }
// } 