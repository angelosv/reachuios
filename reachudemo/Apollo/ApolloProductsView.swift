import SwiftUI

/// Vista de ejemplo para mostrar productos de Apollo
struct ApolloProductsView: View {
    // MARK: - Propiedades
    
    /// ViewModel para productos de Apollo
    @StateObject private var viewModel = ApolloProductsViewModel()
    
    /// Configuración de la cuadrícula
    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ZStack {
                // Contenido principal
                if viewModel.isLoading && viewModel.products.isEmpty {
                    // Vista de carga
                    ProgressView("Cargando productos...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let errorMessage = viewModel.errorMessage {
                    // Vista de error
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        
                        Text("Error: \(errorMessage)")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Reintentar") {
                            viewModel.fetchProducts()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                } else if viewModel.products.isEmpty {
                    // Vista vacía
                    VStack(spacing: 16) {
                        Image(systemName: "cart")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        
                        Text("No se encontraron productos")
                            .font(.headline)
                        
                        Button("Refrescar") {
                            viewModel.fetchProducts()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                } else {
                    // Lista de productos
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.products, id: \.id) { product in
                                ApolloProductCard(product: product)
                                    .frame(height: 240)
                            }
                        }
                        .padding()
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        }
                    }
                    .refreshable {
                        viewModel.refreshProducts()
                    }
                }
            }
            .navigationTitle("Productos Apollo")
            .onAppear {
                if viewModel.products.isEmpty {
                    viewModel.fetchProducts()
                }
            }
        }
    }
}

/// Tarjeta de producto
struct ApolloProductCard: View {
    // MARK: - Propiedades
    
    /// Producto a mostrar
    let product: Product
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Imagen del producto
            if let imageURL = product.mainImageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 120)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: 120)
                            .clipped()
                    case .failure:
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, maxHeight: 120)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 120)
                .cornerRadius(8)
            } else {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: 120)
                    .cornerRadius(8)
            }
            
            // Título del producto
            Text(product.title)
                .font(.headline)
                .lineLimit(2)
            
            // Precio del producto
            Text(product.formattedPrice)
                .font(.subheadline)
                .foregroundColor(.blue)
            
            // Categorías del producto
            if !product.categories.isEmpty {
                Text(product.categories.map { $0.name }.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Preview

struct ApolloProductsView_Previews: PreviewProvider {
    static var previews: some View {
        ApolloProductsView()
    }
} 