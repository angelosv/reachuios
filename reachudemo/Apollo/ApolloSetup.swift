import Foundation
import Combine

// MARK: - Apollo Setup Guide
/// Este archivo contiene instrucciones paso a paso para configurar Apollo Client con caché

struct ApolloSetupGuide {
    
    // MARK: - Pasos de instalación
    static let installationSteps = [
        "1. Abre Xcode y selecciona tu proyecto",
        "2. Selecciona File > Swift Packages > Add Package Dependency",
        "3. Ingresa la URL: https://github.com/apollographql/apollo-ios.git",
        "4. Selecciona la versión 1.0.0 o superior",
        "5. Añade el paquete al target principal de la aplicación"
    ]
    
    // MARK: - Pasos de configuración
    static let configurationSteps = [
        "1. Crea un archivo schema.graphqls con tu esquema GraphQL",
        "2. Crea un archivo apollo-codegen-config.json para configurar la generación de código",
        "3. Ejecuta el script de generación de código",
        "4. Configura ApolloClient con soporte de caché"
    ]
    
    // MARK: - Ejemplo de archivo de configuración
    static let configFileExample = """
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
    
    // MARK: - Ejemplo de configuración de cliente con caché
    static let clientSetupExample = """
    import Apollo
    
    class ApolloClientManager {
        static let shared = ApolloClientManager()
        
        // Cliente Apollo con caché persistente
        private(set) lazy var client: ApolloClient = {
            // URL del servidor GraphQL
            let url = URL(string: "https://graph-ql.reachu.io/")!
            
            // Configuración de caché
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
            let provider = NetworkInterceptorProvider(store: store)
            
            // Configurar el transporte de red
            let transport = RequestChainNetworkTransport(
                interceptorProvider: provider,
                endpointURL: url
            )
            
            // Crear el cliente Apollo
            return ApolloClient(networkTransport: transport, store: store)
        }()
        
        private init() {}
    }
    
    // Proveedor de interceptores para manejar autenticación y caché
    class NetworkInterceptorProvider: InterceptorProvider {
        let store: ApolloStore
        let client: URLSessionClient
        
        init(store: ApolloStore, client: URLSessionClient = URLSessionClient()) {
            self.store = store
            self.client = client
        }
        
        func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
            return [
                MaxRetryInterceptor(maxRetriesAllowed: 3),
                CacheReadInterceptor(store: self.store),
                NetworkFetchInterceptor(client: self.client),
                ResponseCodeInterceptor(),
                JSONResponseParsingInterceptor(cacheKeyForObject: self.store.cacheKeyForObject),
                AutomaticPersistedQueryInterceptor(),
                CacheWriteInterceptor(store: self.store)
            ]
        }
    }
    """
    
    // MARK: - Ejemplo de política de caché
    static let cachePolicyExample = """
    // Ejemplo de uso con diferentes políticas de caché
    
    // 1. Retornar datos de caché si están disponibles, sin importar su edad
    apolloClient.fetch(query: MyQuery(), cachePolicy: .returnCacheDataDontFetch)
    
    // 2. Retornar datos de caché si están disponibles, pero también hacer fetch en background
    apolloClient.fetch(query: MyQuery(), cachePolicy: .returnCacheDataAndFetch)
    
    // 3. Retornar datos de caché si no son muy viejos, de lo contrario hacer fetch
    apolloClient.fetch(query: MyQuery(), cachePolicy: .returnCacheDataElseFetch)
    
    // 4. Ignorar caché y siempre hacer fetch desde la red
    apolloClient.fetch(query: MyQuery(), cachePolicy: .fetchIgnoringCacheData)
    
    // 5. Ignorar caché, hacer fetch, y no guardar el resultado en caché
    apolloClient.fetch(query: MyQuery(), cachePolicy: .fetchIgnoringCacheCompletely)
    """
    
    // MARK: - Ejemplo de uso con Combine
    static let combineExample = """
    // Extensión para usar Apollo con Combine
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
    """
} 