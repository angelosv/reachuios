import Foundation
import Combine

/// ViewModel para productos de Apollo
class ApolloProductsViewModel: ObservableObject {
    // MARK: - Propiedades publicadas
    
    /// Lista de productos
    @Published var products: [Product] = []
    
    /// Indica si se está cargando
    @Published var isLoading = false
    
    /// Mensaje de error
    @Published var errorMessage: String?
    
    /// Indica si hay más productos para cargar
    @Published var hasMoreProducts = false
    
    // MARK: - Propiedades privadas
    
    /// Cliente Apollo
    private let apolloClient = ApolloClient.shared
    
    /// Set de cancelables
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Inicialización
    
    /// Inicializa el ViewModel
    init() {
        print("ApolloProductsViewModel inicializado")
    }
    
    // MARK: - Métodos
    
    /// Obtiene una lista de productos
    func fetchProducts() {
        isLoading = true
        errorMessage = nil
        
        apolloClient.fetchProducts { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let products):
                    self?.products = products
                    self?.hasMoreProducts = !products.isEmpty
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    /// Obtiene un producto por su ID
    /// - Parameter id: ID del producto
    func fetchProduct(id: Int) -> AnyPublisher<Product?, Error> {
        Future<Product?, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "ApolloProductsViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "ViewModel deallocated"])))
                return
            }
            
            self.apolloClient.fetchProduct(id: id) { result in
                switch result {
                case .success(let product):
                    promise(.success(product))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    /// Busca productos por término de búsqueda
    func searchProducts() {
        isLoading = true
        errorMessage = nil
        
        apolloClient.searchProducts { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let products):
                    self?.products = products
                    self?.hasMoreProducts = !products.isEmpty
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    /// Refresca la lista de productos
    func refreshProducts() {
        products = []
        fetchProducts()
    }
    
    /// Deinicialización
    deinit {
        cancellables.forEach { $0.cancel() }
    }
} 