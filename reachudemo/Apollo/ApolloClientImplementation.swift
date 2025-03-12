import Foundation
import Combine

// MARK: - Apollo Client Implementation
/// Este archivo contiene la implementación completa de Apollo Client
/// Cuando se añada la dependencia de Apollo, este código reemplazará la implementación actual

/*
 
 // NOTA: Este código está comentado porque requiere la dependencia de Apollo Client
 // Descomenta este código después de añadir la dependencia de Apollo Client
 
import Apollo
import ApolloSQLite

class ApolloClientManager {
    // Singleton instance
    static let shared = ApolloClientManager()
    
    // MARK: - Properties
    private let endpointURL = URL(string: "https://graph-ql.reachu.io/")!
    private let authToken = "ZN7EYWW-ZVX4PD9-Q74031G-MXTHK3R"
    
    // MARK: - Apollo Client
    private(set) lazy var client: ApolloClient = {
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
        let provider = NetworkInterceptorProvider(store: store, authToken: authToken)
        
        // Configurar el transporte de red
        let transport = RequestChainNetworkTransport(
            interceptorProvider: provider,
            endpointURL: endpointURL
        )
        
        // Crear el cliente Apollo
        return ApolloClient(networkTransport: transport, store: store)
    }()
    
    // MARK: - Initialization
    private init() {
        print("🚀 Apollo Client Manager initialized")
    }
    
    // MARK: - Cache Management
    
    /// Clears all cached data
    func clearCache() {
        client.clearCache { result in
            switch result {
            case .success:
                print("🧹 Apollo cache cleared successfully")
            case .failure(let error):
                print("❌ Failed to clear Apollo cache: \(error)")
            }
        }
    }
    
    /// Clears cached data for a specific type
    func clearCache(type: CacheableObject.Type) {
        client.clearCache(type: type) { result in
            switch result {
            case .success:
                print("🧹 Apollo cache cleared for type: \(type)")
            case .failure(let error):
                print("❌ Failed to clear Apollo cache for type: \(error)")
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

// MARK: - Combine Extensions
extension ApolloClient {
    /// Fetch query with Combine support
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
    
    /// Perform mutation with Combine support
    func performPublisher<Mutation: GraphQLMutation>(
        mutation: Mutation,
        publishResultToStore: Bool = true,
        queue: DispatchQueue = .main
    ) -> AnyPublisher<GraphQLResult<Mutation.Data>, Error> {
        return Future { promise in
            self.perform(
                mutation: mutation,
                publishResultToStore: publishResultToStore,
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
    
    /// Subscribe to subscription with Combine support
    func subscribePublisher<Subscription: GraphQLSubscription>(
        subscription: Subscription,
        queue: DispatchQueue = .main
    ) -> AnyPublisher<GraphQLResult<Subscription.Data>, Error> {
        let subject = PassthroughSubject<GraphQLResult<Subscription.Data>, Error>()
        
        let cancellable = self.subscribe(
            subscription: subscription,
            queue: queue,
            resultHandler: { result in
                switch result {
                case .success(let graphQLResult):
                    subject.send(graphQLResult)
                case .failure(let error):
                    subject.send(completion: .failure(error))
                }
            }
        )
        
        return subject
            .handleEvents(receiveCancel: {
                cancellable.cancel()
            })
            .eraseToAnyPublisher()
    }
}

// MARK: - Example Usage
class ApolloExampleUsage {
    static func fetchProductsExample() {
        // Ejemplo de uso con una consulta generada
        /*
        let productsQuery = GetProductsQuery(limit: 20, offset: 0)
        
        ApolloClientManager.shared.client.fetchPublisher(
            query: productsQuery,
            cachePolicy: .returnCacheDataElseFetch
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error: \(error)")
                }
            },
            receiveValue: { result in
                if let products = result.data?.products {
                    print("Received \(products.count) products")
                }
                
                if let errors = result.errors {
                    print("GraphQL errors: \(errors)")
                }
            }
        )
        .store(in: &cancellables)
        */
    }
}

*/

// MARK: - Pasos para implementar Apollo Client
struct ApolloClientSteps {
    static let steps = [
        "1. Añadir dependencia de Apollo Client usando Swift Package Manager",
        "2. Descargar el esquema GraphQL del servidor",
        "3. Configurar la generación de código Apollo",
        "4. Generar código Swift a partir de consultas GraphQL",
        "5. Implementar ApolloClientManager con soporte de caché",
        "6. Actualizar ViewModels para usar el cliente Apollo",
        "7. Implementar políticas de caché según necesidades"
    ]
    
    static let schemaDownloadCommand = """
    npx apollo schema:download --endpoint=https://graph-ql.reachu.io/ --header="Authorization: ZN7EYWW-ZVX4PD9-Q74031G-MXTHK3R" schema.graphqls
    """
    
    static let codegenConfigExample = """
    {
      "schemaName": "ReachuAPI",
      "input": {
        "operationSearchPaths": ["**/*.graphql"],
        "schemaSearchPaths": ["**/schema.graphqls"]
      },
      "output": {
        "testMocks": {
          "none": {}
        },
        "schemaTypes": {
          "path": "./ApolloCodegen",
          "moduleType": {
            "swiftPackageManager": {}
          }
        },
        "operations": {
          "inSchemaModule": {}
        }
      }
    }
    """
    
    static let codegenCommand = """
    npx apollo codegen:generate --target=swift --includes=**/*.graphql --localSchemaFile=schema.graphqls --output=./ApolloCodegen
    """
    
    static let queryFileExample = """
    # products.graphql
    query GetProducts($limit: Int!, $offset: Int!, $category: String) {
      products(limit: $limit, offset: $offset, category: $category) {
        id
        title
        description
        images {
          id
          url
          order
        }
        price {
          currencyCode
          amount
          compareAtAmount
        }
        category
        variants {
          id
          title
          options {
            name
            value
          }
        }
        inventory {
          available
          isInStock
        }
      }
    }
    """
} 