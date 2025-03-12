import Foundation
import Combine
import Apollo

/// ViewModel para productos de Apollo con caché
class ApolloCacheViewModel: ObservableObject {
    // MARK: - Propiedades publicadas
    
    /// Lista de productos
    @Published var products: [Product] = []
    
    /// Indica si se está cargando
    @Published var isLoading = false
    
    /// Mensaje de error
    @Published var errorMessage: String?
    
    /// Indica si hay más productos para cargar
    @Published var hasMoreProducts = false
    
    /// Política de caché actual
    @Published var currentCachePolicy: CachePolicy = .returnCacheDataElseFetch
    
    // MARK: - Propiedades privadas
    
    /// Cliente Apollo con caché
    private let apolloClient = ApolloCacheClient.shared
    
    /// Set de cancelables
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Inicialización
    
    /// Inicializa el ViewModel
    init() {
        print("ApolloCacheViewModel inicializado")
    }
    
    // MARK: - Métodos
    
    /// Obtiene una lista de productos
    /// - Parameter cachePolicy: Política de caché a utilizar
    func fetchProducts(cachePolicy: CachePolicy? = nil) {
        isLoading = true
        errorMessage = nil
        
        let policy = cachePolicy ?? currentCachePolicy
        
        apolloClient.fetchProducts(cachePolicy: policy) { [weak self] result in
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
    /// - Parameters:
    ///   - id: ID del producto
    ///   - cachePolicy: Política de caché a utilizar
    func fetchProduct(id: Int, cachePolicy: CachePolicy? = nil) -> AnyPublisher<Product?, Error> {
        let policy = cachePolicy ?? currentCachePolicy
        
        return Future<Product?, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "ApolloCacheViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "ViewModel deallocated"])))
                return
            }
            
            self.apolloClient.fetchProduct(id: id, cachePolicy: policy) { result in
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
    
    /// Busca productos
    /// - Parameter cachePolicy: Política de caché a utilizar
    func searchProducts(cachePolicy: CachePolicy? = nil) {
        isLoading = true
        errorMessage = nil
        
        let policy = cachePolicy ?? currentCachePolicy
        
        apolloClient.searchProducts(cachePolicy: policy) { [weak self] result in
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
    
    /// Refresca la lista de productos ignorando la caché
    func refreshProducts() {
        products = []
        fetchProducts(cachePolicy: .fetchIgnoringCacheData)
    }
    
    /// Cambia la política de caché
    /// - Parameter cachePolicy: Nueva política de caché
    func setCachePolicy(_ cachePolicy: CachePolicy) {
        currentCachePolicy = cachePolicy
    }
    
    /// Limpia la caché
    func clearCache(completion: ((Result<Void, Error>) -> Void)? = nil) {
        apolloClient.clearCache { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.products = []
                    completion?(.success(()))
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion?(.failure(error))
                }
            }
        }
    }
    
    /// Deinicialización
    deinit {
        cancellables.forEach { $0.cancel() }
    }
} 