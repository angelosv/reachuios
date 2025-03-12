import SwiftUI

// MARK: - Apollo Example View
/// This view demonstrates the use of Apollo GraphQL
/// It is separate from the existing Reachu views to avoid conflicts
struct ApolloExampleView: View {
    @StateObject private var viewModel = ApolloViewModel()
    @State private var selectedCachePolicy: ApolloManager.CachePolicy = .returnCacheDataElseFetch
    @State private var showCachePolicyPicker = false
    @State private var selectedCategory: String?
    @State private var showCategoryPicker = false
    
    // Available categories
    private let categories = ["Ropa", "Accesorios", "Belleza", "Hogar", "Tecnología"]
    
    // Grid layout configuration
    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.products.isEmpty {
                // Initial loading state
                ProgressView("Cargando productos vía Apollo...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let errorMessage = viewModel.errorMessage, viewModel.products.isEmpty {
                // Error state
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    
                    Text("Error de Apollo")
                        .font(.headline)
                    
                    Text(errorMessage)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        viewModel.refreshProducts()
                    }) {
                        Text("Intentar de nuevo")
                            .fontWeight(.semibold)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                            .background(Color(hex: "#7300f9"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
            } else if viewModel.products.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "cart.badge.questionmark")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No se encontraron productos vía Apollo")
                        .font(.headline)
                    
                    Button(action: {
                        viewModel.refreshProducts()
                    }) {
                        Text("Actualizar")
                            .fontWeight(.semibold)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                            .background(Color(hex: "#7300f9"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
            } else {
                // Products grid
                VStack {
                    // Cache policy and category selectors
                    HStack {
                        Button(action: {
                            showCachePolicyPicker.toggle()
                        }) {
                            HStack {
                                Text("Política de caché")
                                    .font(.subheadline)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "#7300f9").opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        Button(action: {
                            showCategoryPicker.toggle()
                        }) {
                            HStack {
                                Text(selectedCategory ?? "Todas las categorías")
                                    .font(.subheadline)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "#7300f9").opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.clearProductsCache()
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .padding(8)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Cache policy picker
                    if showCachePolicyPicker {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Selecciona una política de caché:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal)
                            
                            Button(action: {
                                selectedCachePolicy = .returnCacheDataElseFetch
                                showCachePolicyPicker = false
                                loadProductsWithSelectedPolicy()
                            }) {
                                HStack {
                                    Text("Caché si está disponible, sino red")
                                    Spacer()
                                    if selectedCachePolicy == .returnCacheDataElseFetch {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(Color(hex: "#7300f9"))
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(selectedCachePolicy == .returnCacheDataElseFetch ? Color(hex: "#7300f9").opacity(0.1) : Color.clear)
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                selectedCachePolicy = .returnCacheDataAndFetch
                                showCachePolicyPicker = false
                                loadProductsWithSelectedPolicy()
                            }) {
                                HStack {
                                    Text("Caché y actualizar en segundo plano")
                                    Spacer()
                                    if selectedCachePolicy == .returnCacheDataAndFetch {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(Color(hex: "#7300f9"))
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(selectedCachePolicy == .returnCacheDataAndFetch ? Color(hex: "#7300f9").opacity(0.1) : Color.clear)
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                selectedCachePolicy = .returnCacheDataDontFetch
                                showCachePolicyPicker = false
                                loadProductsWithSelectedPolicy()
                            }) {
                                HStack {
                                    Text("Solo caché, no actualizar")
                                    Spacer()
                                    if selectedCachePolicy == .returnCacheDataDontFetch {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(Color(hex: "#7300f9"))
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(selectedCachePolicy == .returnCacheDataDontFetch ? Color(hex: "#7300f9").opacity(0.1) : Color.clear)
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                selectedCachePolicy = .fetchIgnoringCache
                                showCachePolicyPicker = false
                                loadProductsWithSelectedPolicy()
                            }) {
                                HStack {
                                    Text("Ignorar caché, solo red")
                                    Spacer()
                                    if selectedCachePolicy == .fetchIgnoringCache {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(Color(hex: "#7300f9"))
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(selectedCachePolicy == .fetchIgnoringCache ? Color(hex: "#7300f9").opacity(0.1) : Color.clear)
                                .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    // Category picker
                    if showCategoryPicker {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Selecciona una categoría:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal)
                            
                            Button(action: {
                                selectedCategory = nil
                                showCategoryPicker = false
                                viewModel.fetchProducts(
                                    category: nil,
                                    resetResults: true,
                                    cachePolicy: selectedCachePolicy
                                )
                            }) {
                                HStack {
                                    Text("Todas las categorías")
                                    Spacer()
                                    if selectedCategory == nil {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(Color(hex: "#7300f9"))
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(selectedCategory == nil ? Color(hex: "#7300f9").opacity(0.1) : Color.clear)
                                .cornerRadius(8)
                            }
                            
                            ForEach(categories, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                    showCategoryPicker = false
                                    viewModel.fetchProductsByCategory(category)
                                }) {
                                    HStack {
                                        Text(category)
                                        Spacer()
                                        if selectedCategory == category {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(Color(hex: "#7300f9"))
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == category ? Color(hex: "#7300f9").opacity(0.1) : Color.clear)
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text("Demo de Apollo GraphQL con Caché")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Text("Esta vista usa Apollo para obtener productos con soporte de caché")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                            
                            if viewModel.isRefreshing {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                    Text("Actualizando...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                            }
                            
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.products) { product in
                                    ApolloProductCard(product: product)
                                        .onAppear {
                                            // Load more products when reaching the end
                                            if product.id == viewModel.products.last?.id {
                                                viewModel.loadMoreProducts()
                                            }
                                        }
                                }
                            }
                            .padding()
                        }
                        .padding(.top)
                    }
                    .refreshable {
                        await withCheckedContinuation { continuation in
                            viewModel.refreshProducts()
                            // Wait a bit to give a better UX for the refresh
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                continuation.resume()
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Apollo con Caché")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.refreshProducts()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onTapGesture {
            // Close pickers when tapping outside
            showCachePolicyPicker = false
            showCategoryPicker = false
        }
        .onAppear {
            if viewModel.products.isEmpty {
                loadProductsWithSelectedPolicy()
            }
        }
    }
    
    private func loadProductsWithSelectedPolicy() {
        viewModel.fetchProducts(
            category: selectedCategory,
            resetResults: true,
            cachePolicy: selectedCachePolicy
        )
    }
}

// MARK: - Apollo Product Card
struct ApolloProductCard: View {
    let product: ApolloProduct
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Product Image
            if let imageURL = product.mainImageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(8)
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .cornerRadius(8)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(8)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(8)
                    }
                }
                .frame(height: 180)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
                    .frame(height: 180)
            }
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Apollo: \(product.title)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text(product.formattedPrice)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "#7300f9"))
            }
            .padding(.horizontal, 4)
            
            Spacer()
        }
        .frame(height: 250)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Preview
struct ApolloExampleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ApolloExampleView()
        }
    }
} 