import Foundation
import Combine
// Importar estos módulos cuando el código sea generado
// import Apollo
// import ReachuAPI

/// Este archivo muestra cómo usar el código generado por Apollo con el ApolloManager
/// Descomenta el código cuando hayas generado el código y añadido la dependencia de Apollo

/*
class ApolloClientWithCodegen {
    // MARK: - Properties
    static let shared = ApolloClientWithCodegen()
    private let apolloClient: ApolloClient
    
    // MARK: - Initialization
    private init() {
        // Configuración de caché SQLite
        let documentsPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        ).first!
        
        let documentsURL = URL(fileURLWithPath: documentsPath)
        let sqliteFileURL = documentsURL.appendingPathComponent("apollo_cache.sqlite")
        
        // Crear el store de caché SQLite
        let sqliteCache = try! SQLiteNormalizedCache(fileURL: sqliteFileURL)
        let normalizedCache = DefaultNormalizedCache(records: [:])
        let store = ApolloStore(cache: normalizedCache)
        
        // Configurar interceptores para autenticación y caché
        let provider = NetworkInterceptorProvider(store: store, authToken: "ZN7EYWW-ZVX4PD9-Q74031G-MXTHK3R")
        
        // Configurar el transporte de red
        let transport = RequestChainNetworkTransport(
            interceptorProvider: provider,
            endpointURL: URL(string: "https://graph-ql.reachu.io/")!
        )
        
        // Crear el cliente Apollo
        apolloClient = ApolloClient(networkTransport: transport, store: store)
        
        print("🚀 Apollo Client con codegen inicializado")
    }
    
    // MARK: - Fetch Products
    func fetchProducts(
        limit: Int = 20,
        offset: Int = 0,
        category: String? = nil,
        cachePolicy: CachePolicy = .returnCacheDataElseFetch
    ) -> AnyPublisher<[Product], Error> {
        let query = GetProductsQuery(limit: limit, offset: offset, category: category)
        
        return apolloClient.fetchPublisher(query: query, cachePolicy: cachePolicy)
            .map { result -> [Product] in
                guard let products = result.data?.channel?.getProducts else {
                    return []
                }
                
                // Convertir los productos de GraphQL a tu modelo de datos
                return products.compactMap { graphQLProduct -> Product? in
                    guard let id = graphQLProduct?.id else { return nil }
                    
                    return Product(
                        id: id,
                        title: graphQLProduct?.title ?? "",
                        description: graphQLProduct?.description ?? "",
                        // Mapear el resto de propiedades
                        // ...
                    )
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Fetch Product Detail
    func fetchProductDetail(
        id: String,
        cachePolicy: CachePolicy = .returnCacheDataElseFetch
    ) -> AnyPublisher<Product?, Error> {
        let query = GetProductDetailQuery(id: id)
        
        return apolloClient.fetchPublisher(query: query, cachePolicy: cachePolicy)
            .map { result -> Product? in
                guard let graphQLProduct = result.data?.channel?.getProduct else {
                    return nil
                }
                
                return Product(
                    id: graphQLProduct.id,
                    title: graphQLProduct.title,
                    description: graphQLProduct.description ?? "",
                    // Mapear el resto de propiedades
                    // ...
                )
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Search Products
    func searchProducts(
        searchTerm: String,
        limit: Int = 20,
        offset: Int = 0,
        cachePolicy: CachePolicy = .returnCacheDataElseFetch
    ) -> AnyPublisher<[Product], Error> {
        let query = SearchProductsQuery(searchTerm: searchTerm, limit: limit, offset: offset)
        
        return apolloClient.fetchPublisher(query: query, cachePolicy: cachePolicy)
            .map { result -> [Product] in
                guard let products = result.data?.channel?.searchProducts else {
                    return []
                }
                
                return products.compactMap { graphQLProduct -> Product? in
                    guard let id = graphQLProduct?.id else { return nil }
                    
                    return Product(
                        id: id,
                        title: graphQLProduct?.title ?? "",
                        description: graphQLProduct?.description ?? "",
                        // Mapear el resto de propiedades
                        // ...
                    )
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Clear Cache
    func clearCache() {
        apolloClient.clearCache { result in
            switch result {
            case .success:
                print("🧹 Apollo cache cleared successfully")
            case .failure(let error):
                print("❌ Failed to clear Apollo cache: \(error)")
            }
        }
    }
}

// MARK: - Network Interceptor Provider
class NetworkInterceptorProvider: InterceptorProvider {
    let store: ApolloStore
    let client: URLSessionClient
    let authToken: String
    
    init(store: ApolloStore, client: URLSessionClient = URLSessionClient(), authToken: String) {
        self.store = store
        self.client = client
        self.authToken = authToken
    }
    
    func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        return [
            MaxRetryInterceptor(maxRetriesAllowed: 3),
            CacheReadInterceptor(store: self.store),
            TokenAddingInterceptor(token: authToken),
            NetworkFetchInterceptor(client: self.client),
            ResponseCodeInterceptor(),
            JSONResponseParsingInterceptor(cacheKeyForObject: self.store.cacheKeyForObject),
            AutomaticPersistedQueryInterceptor(),
            CacheWriteInterceptor(store: self.store)
        ]
    }
}

// MARK: - Token Adding Interceptor
class TokenAddingInterceptor: ApolloInterceptor {
    let token: String
    
    init(token: String) {
        self.token = token
    }
    
    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        request.addHeader(name: "Authorization", value: token)
        chain.proceedAsync(request: request, response: response, completion: completion)
    }
}

// MARK: - Apollo Client Extensions
extension ApolloClient {
    func fetchPublisher<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .returnCacheDataElseFetch,
        contextIdentifier: UUID? = nil,
        queue: DispatchQueue = .main
    ) -> AnyPublisher<GraphQLResult<Query.Data>, Error> {
        return Future { promise in
            self.fetch(
                query: query,
                cachePolicy: cachePolicy,
                contextIdentifier: contextIdentifier,
                queue: queue
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    promise(.success(graphQLResult))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}

// MARK: - Product Model
struct Product: Identifiable {
    let id: String
    let title: String
    let description: String
    // Añade el resto de propiedades según necesites
}
*/

// MARK: - Instrucciones para usar el código generado
struct ApolloCodegenInstructions {
    static let steps = """
    Para usar el código generado por Apollo, sigue estos pasos:
    
    1. Añade la dependencia de Apollo a tu proyecto:
       - File > Swift Packages > Add Package Dependency
       - URL: https://github.com/apollographql/apollo-ios.git
       - Versión: 1.0.0 o superior
    
    2. Genera el código Swift a partir de tus consultas GraphQL:
       - Ejecuta el script: ./reachudemo/Apollo/generate-apollo-code.sh
    
    3. Añade el código generado a tu proyecto:
       - Arrastra la carpeta ApolloCodegen a tu proyecto en Xcode
       - Asegúrate de seleccionar "Create groups" y "Add to target: reachudemo"
    
    4. Descomenta el código en este archivo y en ApolloManager.swift
    
    5. Actualiza tus ViewModels para usar el cliente Apollo con el código generado
    
    6. Disfruta de las ventajas de Apollo GraphQL con caché!
    """
} 