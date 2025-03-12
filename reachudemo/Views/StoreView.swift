import SwiftUI

struct StoreView: View {
    @StateObject private var viewModel = StoreViewModel()
    @State private var searchText = ""
    @State private var selectedProduct: ReachuProduct? = nil
    @State private var showProductDetail = false
    @State private var showShoppingCart = false
    @State private var showingAddedAlert = false
    @State private var lastAddedProduct: String = ""
    
    // Main app color
    let primaryColor = Color(hex: "#7300f9")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Promotional Banner
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(primaryColor)
                            .cornerRadius(12)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Get Winter Discount")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("20% Off")
                                    .font(.title)
                                    .fontWeight(.black)
                                    .foregroundColor(.white)
                                
                                Text("For Children")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding(.leading)
                            
                            Spacer()
                            
                            Image(systemName: "person.crop.rectangle.badge.plus")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.trailing)
                        }
                    }
                    .frame(height: 120)
                    .padding(.horizontal)
                    
                    if viewModel.isLoading {
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                            Text("Loading products...")
                                .font(.caption)
                                .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(primaryColor)
                            Text(errorMessage)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                    } else if viewModel.reachuProducts.isEmpty {
                        VStack {
                            Image(systemName: "tray")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("No products found")
                                .font(.headline)
                                .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                    } else {
                        // Featured Products Section
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Featured")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Button(action: {}) {
                                    Text("See All")
                                        .font(.subheadline)
                                        .foregroundColor(primaryColor)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Featured products in a horizontal scrollview
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    // Display first 5 products as featured - agregando print para depuración
                                    ForEach(Array(viewModel.reachuProducts.prefix(5).enumerated()), id: \.element.id) { index, product in
                                        let productIndex = index
                                        
                                        // Imprimir información para depuración
                                        let _ = print("Mostrando producto featured \(productIndex): id=\(product.id), title=\(product.title), tiene imagen=\(product.mainImageURL != nil)")
                                        
                                        FeaturedProductCard(
                                            product: product,
                                            onTap: {
                                                selectedProduct = product
                                                showProductDetail = true
                                            },
                                            onFavorite: {}
                                        )
                                        .frame(width: 160)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 5)
                            }
                        }
                        
                        // Most Popular Section
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Most Popular")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Button(action: {}) {
                                    Text("See All")
                                        .font(.subheadline)
                                        .foregroundColor(primaryColor)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Most popular products in a horizontal scrollview
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    // Display next 5 products as most popular - agregando print para depuración
                                    ForEach(Array(viewModel.reachuProducts.dropFirst(5).prefix(5).enumerated()), id: \.element.id) { index, product in
                                        let productIndex = index + 5
                                        
                                        // Imprimir información para depuración
                                        let _ = print("Mostrando producto popular \(productIndex): id=\(product.id), title=\(product.title), tiene imagen=\(product.mainImageURL != nil)")
                                        
                                        PopularProductCard(
                                            product: product,
                                            onTap: {
                                                selectedProduct = product
                                                showProductDetail = true
                                            },
                                            onAddToCart: {
                                                addToCart(product: product, size: "M", color: "Default", quantity: 1)
                                            }
                                        )
                                        .frame(height: 120)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 5)
                            }
                        }
                        
                        // All Products Section
                        VStack(alignment: .leading) {
                            Text("All Products")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 16) {
                                ForEach(viewModel.reachuProducts) { product in
                                    ReachuProductCard(
                                        product: product,
                                        onTap: {
                                            selectedProduct = product
                                            showProductDetail = true
                                        },
                                        onAddToCart: {
                                            addToCart(product: product, size: "M", color: "Broken White", quantity: 1)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Store")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showShoppingCart = true
                    }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "cart")
                                .foregroundColor(primaryColor)
                            
                            if viewModel.cartItemCount > 0 {
                                Text("\(viewModel.cartItemCount)")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(primaryColor)
                                    .clipShape(Circle())
                                    .offset(x: 10, y: -10)
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(primaryColor)
                    }
                }
            }
        }
        .sheet(isPresented: $showProductDetail) {
            if let product = selectedProduct {
                ProductDetailModal(
                    product: product,
                    isPresented: $showProductDetail,
                    onAddToCart: { product, size, color, quantity in
                        addToCart(product: product, size: size, color: color, quantity: quantity)
                    }
                )
            }
        }
        .sheet(isPresented: $showShoppingCart) {
            ShoppingCartView(viewModel: viewModel)
        }
        .alert(isPresented: $showingAddedAlert) {
            Alert(
                title: Text("Product Added"),
                message: Text("\(lastAddedProduct) has been added to your cart."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // Centralized function to add products to cart
    private func addToCart(product: ReachuProduct, size: String?, color: String?, quantity: Int) {
        print("Adding to cart: \(product.title), Size: \(size ?? "N/A"), Color: \(color ?? "N/A"), Quantity: \(quantity)")
        
        // Create a new cart item
        let newItem = CartItem(
            product: product,
            quantity: quantity,
            isSelected: true,
            size: size,
            color: color
        )
        
        // Add the item to the cart
        viewModel.cartItems.append(newItem)
        
        // Update the message and show the alert
        lastAddedProduct = product.title.toTitleCase()
        showingAddedAlert = true
    }
}

struct ProductCard: View {
    let product: Product
    let action: () -> Void
    
    // Main app color
    let primaryColor = Color(hex: "#7300f9")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            Image(product.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .clipped()
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(2)
                    .frame(height: 50) // Fixed height for title
                
                Text(product.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    // Price left
                    Text(product.formattedPrice)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(primaryColor)
                    
                    Spacer()
                    
                    // Icon button right
                    Button(action: action) {
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
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    StoreView()
} 