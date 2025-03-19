import SwiftUI
import Combine

// Extensión para String para eliminar etiquetas HTML
extension String {
    var stripHTML: String {
        let processed = self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        return processed.replacingOccurrences(of: "&[^;]+;", with: " ", options: .regularExpression)
    }
}

struct ArticleDetailView: View {
    let article: Article
    @State private var product: ReachuProduct?
    @State private var recommendedProduct: ReachuProduct?
    @State private var isLoadingProduct = true
    @State private var isLoadingRecommended = true
    @State private var cancellables = Set<AnyCancellable>()
    @State private var showBookmark = false
    @Environment(\.presentationMode) var presentationMode
    
    // Demo product ID
    let productId = 1904016 // Updated product ID
    // Specific product ID for recommended section
    let omegaProductId = 1904019 // Updated recommended product ID
    
    @State private var selectedProduct: ReachuProduct? = nil
    @State private var showProductDetail = false
    @State private var showOrderSuccess = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header and Image
                ZStack(alignment: .top) {
                    if let imageUrl = article.imageURL {
                        RemoteImage(url: imageUrl) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 240)
                        }
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 240)
                        .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 240)
                    }
                    
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding(.top, 8)
                        
                        Spacer()
                        
                        Button(action: {
                            showBookmark.toggle()
                        }) {
                            Image(systemName: showBookmark ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .padding(.top, 30)
                }
                
                // Article Title
                Text(article.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // Tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(["Pregnancy", "Omega-3", "Health", "Baby Development"], id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: "#F5F5F5"))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // First paragraph - Apply stripHTML to article content
                Text(article.content.stripHTML)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Embedded Product (after first paragraph)
                if isLoadingProduct {
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Spacer()
                    }
                    .padding()
                    .background(Color(hex: "#F5F5F5").opacity(0.5))
                    .cornerRadius(12)
                    .padding(.horizontal)
                } else if let product = product {
                    Button(action: {
                        selectedProduct = product
                        showProductDetail = true
                    }) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                if let mainImageURL = product.mainImageURL {
                                    RemoteImage(url: mainImageURL) {
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
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(product.title)
                                        .font(.headline)
                                        .lineLimit(1)
                                    
                                    Text(product.formattedPrice)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(hex: "#7300f9"))
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    addToCart(product: product)
                                }) {
                                    Text("Add")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color(hex: "#7300f9"))
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding()
                        .background(Color(hex: "#F5F5F5").opacity(0.5))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                }
                
                // Recommended product component
                VStack(alignment: .leading, spacing: 20) {
                    Divider()
                        .padding(.horizontal)
                    
                    if isLoadingRecommended {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Spacer()
                        }
                        .padding()
                    } else if let recommendedProduct = recommendedProduct {
                        FullWidthProductCard(
                            product: recommendedProduct,
                            onAddToCart: {
                                addToCart(product: recommendedProduct)
                            },
                            onTap: {
                                selectedProduct = recommendedProduct
                                showProductDetail = true
                            }
                        )
                        .padding(.horizontal)
                    }
                }
                
                // Tags section at the bottom
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tags")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack {
                        ForEach(["Pregnancy", "Omega-3", "Health", "Baby Development"], id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: "#F5F5F5"))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            fetchProduct()
            fetchRecommendedProduct()
        }
        .sheet(isPresented: $showProductDetail) {
            if let product = selectedProduct {
                // Usar el componente ProductDetailModal existente
                ZStack {
                    Color.white.edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        // Header con botón de cierre
                        HStack {
                            Button(action: {
                                showProductDetail = false
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            
                            Spacer()
                            
                            Text("Product Details")
                                .font(.headline)
                            
                            Spacer()
                        }
                        .padding()
                        
                        // Usar el ProductDetailModal pero sin el binding isPresented
                        // y con una acción personalizada para añadir al carrito
                        ProductDetailModal(
                            product: product,
                            isPresented: $showProductDetail,
                            onAddToCart: { product, size, color, quantity in
                                // Simular proceso de añadir al carrito y mostrar confirmación
                                // En una aplicación real, esto añadiría el producto al carrito
                                // y podría navegar a la vista de carrito o mostrar una confirmación
                                simulatePlaceOrder()
                            }
                        )
                    }
                }
            }
        }
        .alert(isPresented: $showOrderSuccess) {
            Alert(
                title: Text("Order Successful"),
                message: Text("Your order has been placed successfully."),
                dismissButton: .default(Text("Continue Shopping"))
            )
        }
    }
    
    private func fetchProduct() {
        let service = ReachuGraphQLService()
        print("🔍 Attempting to fetch product with ID: \(productId)")
        
        // Mostrar producto demo en el entretanto
        isLoadingProduct = true
        createDemoProduct()
        
        service.fetchProductById(productId: productId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoadingProduct = false
                    if case .failure(let error) = completion {
                        print("❌ Error fetching product: \(error)")
                        // No necesitamos llamar a createDemoProduct() aquí ya que lo hicimos arriba
                    }
                },
                receiveValue: { fetchedProduct in
                    isLoadingProduct = false
                    print("✅ Successfully fetched product: \(fetchedProduct.id), title: \(fetchedProduct.title), supplier: \(fetchedProduct.supplier)")
                    // Solo actualizar si es un producto real (no demo)
                    if !fetchedProduct.id.starts(with: "demo-") {
                        self.product = fetchedProduct
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func fetchRecommendedProduct() {
        let service = ReachuGraphQLService()
        print("🔍 Attempting to fetch recommended product with ID: \(omegaProductId)")
        
        // Mostrar producto demo en el entretanto
        isLoadingRecommended = true
        createDemoRecommendedProduct()
        
        service.fetchProductById(productId: omegaProductId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoadingRecommended = false
                    if case .failure(let error) = completion {
                        print("❌ Error fetching recommended product: \(error)")
                        // No necesitamos llamar a createDemoRecommendedProduct() aquí ya que lo hicimos arriba
                    }
                },
                receiveValue: { fetchedProduct in
                    isLoadingRecommended = false
                    print("✅ Successfully fetched recommended product: \(fetchedProduct.id), title: \(fetchedProduct.title), supplier: \(fetchedProduct.supplier)")
                    // Solo actualizar si es un producto real (no demo)
                    if !fetchedProduct.id.starts(with: "demo-") {
                        self.recommendedProduct = fetchedProduct
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func createDemoProduct() {
        print("📦 Creating demo product with supplier: Healthy Life")
        // Create a demo product for the first section
        let demoProduct = ReachuProduct(
            id: "demo-1",
            images: [ReachuImage(url: "https://picsum.photos/200/200", order: 0)],
            price: ReachuPrice(currency_code: "NOK", amount_incl_taxes: "249", compare_at_incl_taxes: "349"),
            title: "Multivitamin Daily Complex",
            description: "Complete daily multivitamin formula with essential nutrients for overall health and wellbeing.",
            supplier: "Healthy Life"
        )
        print("✅ Demo product created: \(demoProduct.id), title: \(demoProduct.title), supplier: \(demoProduct.supplier)")
        self.product = demoProduct
    }
    
    private func createDemoRecommendedProduct() {
        print("📦 Creating demo recommended product with supplier: Mother's Choice")
        // Create a demo product for the recommended section (not specific to Omega-3)
        let demoProduct = ReachuProduct(
            id: "demo-2",
            images: [ReachuImage(url: "https://picsum.photos/400/400", order: 0)],
            price: ReachuPrice(currency_code: "NOK", amount_incl_taxes: "399", compare_at_incl_taxes: "599"),
            title: "Premium Prenatal Multivitamin Complex",
            description: "Specially formulated prenatal multivitamin with essential nutrients for maternal health and baby development during pregnancy.",
            supplier: "Mother's Choice"
        )
        print("✅ Demo recommended product created: \(demoProduct.id), title: \(demoProduct.title), supplier: \(demoProduct.supplier)")
        self.recommendedProduct = demoProduct
    }
    
    private func createDemoOmega3Product() {
        print("📦 Creating demo Omega-3 product with supplier: Nordic Essentials")
        // Create a demo product related to Omega-3 (keeping this for backward compatibility)
        let demoProduct = ReachuProduct(
            id: "omega3-1",
            images: [ReachuImage(url: "https://picsum.photos/400/400", order: 0)],
            price: ReachuPrice(currency_code: "USD", amount_incl_taxes: "39.99", compare_at_incl_taxes: "59.99"),
            title: "Nordic Omega-3 Premium Fish Oil Supplement",
            description: "High-quality omega-3 supplement specially formulated for pregnant women. Supports brain and eye development in babies.",
            supplier: "Nordic Essentials"
        )
        print("✅ Demo Omega-3 product created: \(demoProduct.id), title: \(demoProduct.title), supplier: \(demoProduct.supplier)")
        self.recommendedProduct = demoProduct
    }
    
    private func addToCart(product: ReachuProduct) {
        print("Product added to cart: \(product.title)")
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func simulatePlaceOrder() {
        showProductDetail = false
        
        // Simular una breve demora y luego mostrar el mensaje de éxito
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            showOrderSuccess = true
        }
    }
}

#Preview {
    ArticleDetailView(article: Article(
        id: "1",
        title: "Why is Omega-3 important during pregnancy and for baby's health?",
        content: "Omega-3 fatty acids play a crucial role during pregnancy and for baby's development...",
        imageURL: URL(string: "https://picsum.photos/800/600"),
        category: "Health"
    ))
} 