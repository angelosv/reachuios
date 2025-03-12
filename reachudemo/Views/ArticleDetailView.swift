import SwiftUI
import Combine

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
    let productId = 123 // Replace with an actual product ID
    // Specific Omega-3 product ID
    let omegaProductId = 12071 // ID for the specific Omega-3 product
    
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
                        ForEach(["Graviditet", "Omega-3", "Helse", "Babyutvikling"], id: \.self) { tag in
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
                
                // First paragraph
                Text(article.content)
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
                                // Add to cart action
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
                    .padding(.horizontal)
                }
                
                // Añadir el componente de producto recomendado a todo ancho
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
                                // Acción para añadir al carrito
                                print("Producto añadido al carrito: \(recommendedProduct.title)")
                            },
                            onTap: {
                                // Acción para navegar al detalle del producto
                                print("Navegando al detalle del producto: \(recommendedProduct.title)")
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
                        ForEach(["Graviditet", "Omega-3", "Helse", "Babyutvikling"], id: \.self) { tag in
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
    }
    
    private func fetchProduct() {
        let service = ReachuGraphQLService()
        
        // Use a valid product ID from the Reachu API
        // For demo purposes, we'll use a hardcoded ID
        service.fetchProductById(productId: 1234)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoadingProduct = false
                    if case .failure(let error) = completion {
                        print("Error fetching product: \(error)")
                        // Si no podemos cargar el producto, usamos uno de demostración
                        createDemoProduct()
                    }
                },
                receiveValue: { fetchedProduct in
                    self.product = fetchedProduct
                }
            )
            .store(in: &cancellables)
    }
    
    private func fetchRecommendedProduct() {
        let service = ReachuGraphQLService()
        
        // Use the fetchProductById method instead of the private performGraphQLRequest method
        service.fetchProductById(productId: omegaProductId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoadingRecommended = false
                    if case .failure(let error) = completion {
                        print("Error fetching recommended product: \(error)")
                        // If we can't load the product, use a demo one
                        createDemoRecommendedProduct()
                    }
                },
                receiveValue: { fetchedProduct in
                    self.recommendedProduct = fetchedProduct
                }
            )
            .store(in: &cancellables)
    }
    
    private func createDemoProduct() {
        // Create a demo product for the first section
        let demoProduct = ReachuProduct(
            id: "demo-1",
            images: [ReachuImage(url: "https://picsum.photos/200/200", order: 0)],
            price: ReachuPrice(currency_code: "NOK", amount: "249", compare_at: "349"),
            title: "Multivitamin Daily Complex",
            description: "Complete daily multivitamin formula with essential nutrients for overall health and wellbeing."
        )
        self.product = demoProduct
    }
    
    private func createDemoRecommendedProduct() {
        // Create a demo product for the recommended section (not specific to Omega-3)
        let demoProduct = ReachuProduct(
            id: "demo-2",
            images: [ReachuImage(url: "https://picsum.photos/400/400", order: 0)],
            price: ReachuPrice(currency_code: "NOK", amount: "399", compare_at: "599"),
            title: "Premium Prenatal Multivitamin Complex",
            description: "Specially formulated prenatal multivitamin with essential nutrients for maternal health and baby development during pregnancy."
        )
        self.recommendedProduct = demoProduct
    }
    
    private func createDemoOmega3Product() {
        // Create a demo product related to Omega-3 (keeping this for backward compatibility)
        let demoProduct = ReachuProduct(
            id: "omega3-1",
            images: [ReachuImage(url: "https://picsum.photos/400/400", order: 0)],
            price: ReachuPrice(currency_code: "USD", amount: "39.99", compare_at: "59.99"),
            title: "Nordic Omega-3 Premium Fish Oil Supplement",
            description: "High-quality omega-3 supplement specially formulated for pregnant women. Supports brain and eye development in babies."
        )
        self.recommendedProduct = demoProduct
    }
}

#Preview {
    ArticleDetailView(article: Article(
        id: "1",
        title: "Hvorfor er Omega-3 viktig under graviditet og for babyens helse?",
        content: "Omega-3-fettsyrer spiller en avgjørende rolle under graviditeten og for babyens utvikling...",
        imageURL: URL(string: "https://picsum.photos/800/600"),
        category: "Health"
    ))
} 