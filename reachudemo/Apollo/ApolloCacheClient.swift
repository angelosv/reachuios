import Foundation
import Apollo
import ApolloAPI
import ReachuAPI

/// Cliente Apollo con sistema de caché para realizar consultas GraphQL
class ApolloCacheClient {
    // MARK: - Singleton
    
    /// Instancia compartida del cliente Apollo
    static let shared = ApolloCacheClient()
    
    // MARK: - Propiedades
    
    /// Cliente Apollo para realizar consultas GraphQL
    private(set) var apollo: Apollo.ApolloClient
    
    /// Almacén de caché de Apollo
    private let cache: NormalizedCache
    
    /// Proveedor de interceptores para la red
    private let interceptorProvider: NetworkInterceptorProvider
    
    // MARK: - Inicialización
    
    /// Inicializa el cliente Apollo con la URL del servidor GraphQL y sistema de caché
    private init() {
        // Crear la URL del servidor GraphQL
        let url = URL(string: "https://graph-ql.reachu.io/")!
        
        // Configurar el almacén de caché
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsURL = URL(fileURLWithPath: documentsPath)
        let sqliteFileURL = documentsURL.appendingPathComponent("apollo_cache.sqlite")
        
        // Crear el almacén de caché
        do {
            self.cache = try SQLiteNormalizedCache(fileURL: sqliteFileURL)
        } catch {
            print("Error al crear la caché SQLite: \(error)")
            // Fallback a caché en memoria si hay error
            self.cache = InMemoryNormalizedCache()
        }
        
        // Crear el almacén Apollo
        let store = ApolloStore(cache: cache)
        
        // Crear el proveedor de interceptores
        self.interceptorProvider = NetworkInterceptorProvider(store: store)
        
        // Crear el transporte de red
        let networkTransport = RequestChainNetworkTransport(
            interceptorProvider: interceptorProvider,
            endpointURL: url
        )
        
        // Crear el cliente Apollo
        self.apollo = Apollo.ApolloClient(
            networkTransport: networkTransport,
            store: store
        )
        
        print("ApolloCacheClient inicializado con éxito")
    }
    
    // MARK: - Métodos
    
    /// Obtiene una lista de productos
    /// - Parameters:
    ///   - cachePolicy: Política de caché a utilizar
    ///   - completion: Closure que se ejecuta cuando se completa la consulta
    func fetchProducts(cachePolicy: CachePolicy = .returnCacheDataElseFetch, completion: @escaping (Result<[Product], Error>) -> Void) {
        apollo.fetch(query: GetProductsQuery(), cachePolicy: cachePolicy) { result in
            switch result {
            case .success(let graphQLResult):
                if let products = graphQLResult.data?.channel?.getProducts {
                    let mappedProducts = products.compactMap { self.mapToProduct($0) }
                    completion(.success(mappedProducts))
                } else if let errors = graphQLResult.errors {
                    let error = NSError(
                        domain: "ApolloCacheClient",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: errors.first?.localizedDescription ?? "Error desconocido"]
                    )
                    completion(.failure(error))
                } else {
                    completion(.success([]))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Obtiene un producto por su ID
    /// - Parameters:
    ///   - id: ID del producto
    ///   - cachePolicy: Política de caché a utilizar
    ///   - completion: Closure que se ejecuta cuando se completa la consulta
    func fetchProduct(id: Int, cachePolicy: CachePolicy = .returnCacheDataElseFetch, completion: @escaping (Result<Product?, Error>) -> Void) {
        apollo.fetch(query: GetProductDetailQuery(productId: id), cachePolicy: cachePolicy) { result in
            switch result {
            case .success(let graphQLResult):
                if let products = graphQLResult.data?.channel?.products, let product = products.first {
                    let mappedProduct = self.mapToProduct(product)
                    completion(.success(mappedProduct))
                } else if let errors = graphQLResult.errors {
                    let error = NSError(
                        domain: "ApolloCacheClient",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: errors.first?.localizedDescription ?? "Error desconocido"]
                    )
                    completion(.failure(error))
                } else {
                    completion(.success(nil))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Busca productos
    /// - Parameters:
    ///   - cachePolicy: Política de caché a utilizar
    ///   - completion: Closure que se ejecuta cuando se completa la consulta
    func searchProducts(cachePolicy: CachePolicy = .returnCacheDataElseFetch, completion: @escaping (Result<[Product], Error>) -> Void) {
        apollo.fetch(query: SearchProductsQuery(), cachePolicy: cachePolicy) { result in
            switch result {
            case .success(let graphQLResult):
                if let products = graphQLResult.data?.channel?.getProducts {
                    let mappedProducts = products.compactMap { self.mapToProduct($0) }
                    completion(.success(mappedProducts))
                } else if let errors = graphQLResult.errors {
                    let error = NSError(
                        domain: "ApolloCacheClient",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: errors.first?.localizedDescription ?? "Error desconocido"]
                    )
                    completion(.failure(error))
                } else {
                    completion(.success([]))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Limpia la caché
    func clearCache(completion: ((Result<Void, Error>) -> Void)? = nil) {
        apollo.clearCache { result in
            switch result {
            case .success:
                print("Caché limpiada con éxito")
                completion?(.success(()))
            case .failure(let error):
                print("Error al limpiar la caché: \(error)")
                completion?(.failure(error))
            }
        }
    }
    
    // MARK: - Métodos privados
    
    /// Mapea un producto de GraphQL a un modelo de dominio
    /// - Parameter graphQLProduct: Producto de GraphQL
    /// - Returns: Producto de dominio
    private func mapToProduct(_ graphQLProduct: GetProductsQuery.Data.Channel.GetProduct?) -> Product? {
        guard let graphQLProduct = graphQLProduct else { return nil }
        
        // Mapear imágenes
        let images = graphQLProduct.images?.compactMap { image -> ProductImage? in
            guard let url = image?.url else { return nil }
            return ProductImage(
                id: image?.id ?? "",
                url: url,
                order: image?.order ?? 0
            )
        } ?? []
        
        // Mapear precio
        let price = graphQLProduct.price.map { price -> ProductPrice in
            ProductPrice(
                currencyCode: price.currency_code ?? "USD",
                amount: price.amount ?? 0,
                compareAt: price.compare_at
            )
        }
        
        // Mapear categorías
        let categories = graphQLProduct.categories?.compactMap { category -> ProductCategory? in
            guard let id = category?.id, let name = category?.name else { return nil }
            return ProductCategory(id: id, name: name)
        } ?? []
        
        // Mapear variantes
        let variants = graphQLProduct.variants?.compactMap { variant -> ProductVariant? in
            guard let id = variant?.id, let title = variant?.title else { return nil }
            return ProductVariant(id: id, title: title, options: [])
        } ?? []
        
        // Crear producto
        return Product(
            id: graphQLProduct.id ?? "",
            title: graphQLProduct.title ?? "",
            description: graphQLProduct.description ?? "",
            images: images,
            price: price,
            categories: categories,
            variants: variants,
            inventory: ProductInventory(available: 0, inStock: true)
        )
    }
    
    /// Mapea un producto de GraphQL a un modelo de dominio
    /// - Parameter graphQLProduct: Producto de GraphQL
    /// - Returns: Producto de dominio
    private func mapToProduct(_ graphQLProduct: GetProductDetailQuery.Data.Channel.Product?) -> Product? {
        guard let graphQLProduct = graphQLProduct else { return nil }
        
        // Mapear imágenes
        let images = graphQLProduct.images?.compactMap { image -> ProductImage? in
            guard let url = image?.url else { return nil }
            return ProductImage(
                id: image?.id ?? "",
                url: url,
                order: image?.order ?? 0
            )
        } ?? []
        
        // Mapear precio
        let price = graphQLProduct.price.map { price -> ProductPrice in
            ProductPrice(
                currencyCode: price.currency_code ?? "USD",
                amount: price.amount ?? 0,
                compareAt: price.compare_at
            )
        }
        
        // Mapear categorías
        let categories = graphQLProduct.categories?.compactMap { category -> ProductCategory? in
            guard let id = category?.id, let name = category?.name else { return nil }
            return ProductCategory(id: id, name: name)
        } ?? []
        
        // Mapear variantes
        let variants = graphQLProduct.variants?.compactMap { variant -> ProductVariant? in
            guard let id = variant?.id, let title = variant?.title else { return nil }
            return ProductVariant(id: id, title: title, options: [])
        } ?? []
        
        // Crear producto
        return Product(
            id: graphQLProduct.id ?? "",
            title: graphQLProduct.title ?? "",
            description: graphQLProduct.description ?? "",
            images: images,
            price: price,
            categories: categories,
            variants: variants,
            inventory: ProductInventory(available: 0, inStock: true)
        )
    }
    
    /// Mapea un producto de GraphQL a un modelo de dominio
    /// - Parameter graphQLProduct: Producto de GraphQL
    /// - Returns: Producto de dominio
    private func mapToProduct(_ graphQLProduct: SearchProductsQuery.Data.Channel.GetProduct?) -> Product? {
        guard let graphQLProduct = graphQLProduct else { return nil }
        
        // Mapear imágenes
        let images = graphQLProduct.images?.compactMap { image -> ProductImage? in
            guard let url = image?.url else { return nil }
            return ProductImage(
                id: image?.id ?? "",
                url: url,
                order: image?.order ?? 0
            )
        } ?? []
        
        // Mapear precio
        let price = graphQLProduct.price.map { price -> ProductPrice in
            ProductPrice(
                currencyCode: price.currency_code ?? "USD",
                amount: price.amount ?? 0,
                compareAt: price.compare_at
            )
        }
        
        // Crear producto
        return Product(
            id: graphQLProduct.id ?? "",
            title: graphQLProduct.title ?? "",
            description: graphQLProduct.description ?? "",
            images: images,
            price: price,
            categories: [],
            variants: [],
            inventory: ProductInventory(available: 0, inStock: true)
        )
    }
}

// MARK: - Proveedor de interceptores

/// Proveedor de interceptores para la red
class NetworkInterceptorProvider: DefaultInterceptorProvider {
    override func interceptors<Operation>(for operation: Operation) -> [ApolloInterceptor] where Operation: GraphQLOperation {
        var interceptors = super.interceptors(for: operation)
        
        // Agregar interceptor de autenticación
        interceptors.insert(AuthInterceptor(), at: 0)
        
        return interceptors
    }
}

// MARK: - Interceptor de autenticación

/// Interceptor para agregar encabezados de autenticación a las solicitudes
class AuthInterceptor: ApolloInterceptor {
    func interceptAsync<Operation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) where Operation: GraphQLOperation {
        // Agregar encabezados de autenticación
        request.addHeader(name: "Authorization", value: "ZN7EYWW-ZVX4PD9-Q74031G-MXTHK3R")
        
        // Continuar con la cadena de interceptores
        chain.proceedAsync(request: request, response: response, completion: completion)
    }
} 