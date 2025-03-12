import SwiftUI
import Apollo

/// Vista de ejemplo para mostrar productos de Apollo con caché
struct ApolloCacheExampleView: View {
    // MARK: - Propiedades
    
    /// ViewModel para productos de Apollo con caché
    @StateObject private var viewModel = ApolloCacheViewModel()
    
    /// Configuración de la cuadrícula
    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]
    
    /// Indica si se muestra el selector de política de caché
    @State private var showingCachePolicyPicker = false
    
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
                            viewModel.refreshProducts()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                } else {
                    // Lista de productos
                    ScrollView {
                        VStack(spacing: 16) {
                            // Información de caché
                            HStack {
                                Text("Política de caché: \(cachePolicyName(viewModel.currentCachePolicy))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Button("Cambiar") {
                                    showingCachePolicyPicker = true
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                            .padding(.horizontal)
                            
                            // Productos
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.products, id: \.id) { product in
                                    ApolloProductCard(product: product)
                                        .frame(height: 240)
                                }
                            }
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .padding()
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        viewModel.refreshProducts()
                    }
                }
            }
            .navigationTitle("Apollo con Caché")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.clearCache()
                    }) {
                        Image(systemName: "trash")
                    }
                }
            }
            .actionSheet(isPresented: $showingCachePolicyPicker) {
                ActionSheet(
                    title: Text("Seleccionar política de caché"),
                    message: Text("Elige cómo se cargarán los datos"),
                    buttons: [
                        .default(Text("Caché o Red")) {
                            viewModel.setCachePolicy(.returnCacheDataElseFetch)
                            viewModel.fetchProducts()
                        },
                        .default(Text("Solo Red")) {
                            viewModel.setCachePolicy(.fetchIgnoringCacheData)
                            viewModel.fetchProducts()
                        },
                        .default(Text("Red sin actualizar Caché")) {
                            viewModel.setCachePolicy(.fetchIgnoringCacheCompletely)
                            viewModel.fetchProducts()
                        },
                        .default(Text("Solo Caché")) {
                            viewModel.setCachePolicy(.returnCacheDataDontFetch)
                            viewModel.fetchProducts()
                        },
                        .default(Text("Caché y luego Red")) {
                            viewModel.setCachePolicy(.returnCacheDataAndFetch)
                            viewModel.fetchProducts()
                        },
                        .cancel()
                    ]
                )
            }
            .onAppear {
                if viewModel.products.isEmpty {
                    viewModel.fetchProducts()
                }
            }
        }
    }
    
    // MARK: - Métodos privados
    
    /// Obtiene el nombre de la política de caché
    /// - Parameter cachePolicy: Política de caché
    /// - Returns: Nombre de la política de caché
    private func cachePolicyName(_ cachePolicy: CachePolicy) -> String {
        switch cachePolicy {
        case .returnCacheDataElseFetch:
            return "Caché o Red"
        case .fetchIgnoringCacheData:
            return "Solo Red"
        case .fetchIgnoringCacheCompletely:
            return "Red sin actualizar Caché"
        case .returnCacheDataDontFetch:
            return "Solo Caché"
        case .returnCacheDataAndFetch:
            return "Caché y luego Red"
        @unknown default:
            return "Desconocida"
        }
    }
}

// MARK: - Preview

struct ApolloCacheExampleView_Previews: PreviewProvider {
    static var previews: some View {
        ApolloCacheExampleView()
    }
} 