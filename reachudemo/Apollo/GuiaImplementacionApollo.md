# Guía de Implementación de Apollo Client con Caché

Esta guía te ayudará a implementar Apollo Client en tu aplicación Reachu iOS, aprovechando las capacidades de caché para mejorar el rendimiento y la experiencia del usuario.

## Paso 1: Añadir Apollo Client como dependencia

1. Abre tu proyecto en Xcode
2. Selecciona File > Swift Packages > Add Package Dependency
3. Ingresa la URL del repositorio de Apollo iOS: `https://github.com/apollographql/apollo-ios.git`
4. Selecciona la versión más reciente (recomendado: 1.0.0 o superior)
5. Añade el paquete al target principal de la aplicación

## Paso 2: Descargar el esquema GraphQL

Para generar código Swift a partir de tus consultas GraphQL, primero necesitas descargar el esquema del servidor:

```bash
# Instala Apollo CLI si aún no lo tienes
npm install -g apollo

# Descarga el esquema
npx apollo schema:download --endpoint=https://graph-ql.reachu.io/ --header="Authorization: ZN7EYWW-ZVX4PD9-Q74031G-MXTHK3R" schema.graphqls
```

## Paso 3: Crear archivos de consultas GraphQL

Crea un directorio para tus consultas GraphQL y añade archivos `.graphql` para cada consulta:

```graphql
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
```

## Paso 4: Configurar la generación de código

Crea un archivo `apollo-codegen-config.json` en la raíz de tu proyecto:

```json
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
```

## Paso 5: Generar código Swift

Ejecuta el siguiente comando para generar código Swift a partir de tus consultas GraphQL:

```bash
npx apollo codegen:generate --target=swift --includes=**/*.graphql --localSchemaFile=schema.graphqls --output=./ApolloCodegen
```

## Paso 6: Implementar ApolloClientManager

Crea una clase `ApolloClientManager` para gestionar la conexión con el servidor GraphQL y la caché:

```swift
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
}
```

## Paso 7: Implementar NetworkInterceptorProvider

Crea una clase `NetworkInterceptorProvider` para gestionar los interceptores de red:

```swift
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
```

## Paso 8: Añadir extensiones de Combine

Para facilitar el uso de Apollo con Combine, añade estas extensiones:

```swift
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
```

## Paso 9: Actualizar ViewModel para usar Apollo Client

Actualiza tu ViewModel para usar el cliente Apollo con soporte de caché:

```swift
import Foundation
import Combine
import Apollo

class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let apolloClient = ApolloClientManager.shared.client
    private var cancellables = Set<AnyCancellable>()
    
    func fetchProducts(cachePolicy: CachePolicy = .returnCacheDataElseFetch) {
        isLoading = true
        
        let query = GetProductsQuery(limit: 20, offset: 0)
        
        apolloClient.fetchPublisher(query: query, cachePolicy: cachePolicy)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] result in
                    if let products = result.data?.products {
                        // Convertir los productos de GraphQL a tu modelo de datos
                        self?.products = products.compactMap { product in
                            // Mapeo de datos
                            return Product(
                                id: product.id,
                                title: product.title,
                                // ... otros campos
                            )
                        }
                    }
                    
                    if let errors = result.errors, !errors.isEmpty {
                        self?.errorMessage = errors.map { $0.localizedDescription }.joined(separator: "\n")
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func refreshProducts() {
        fetchProducts(cachePolicy: .fetchIgnoringCacheData)
    }
    
    func loadCachedProducts() {
        fetchProducts(cachePolicy: .returnCacheDataDontFetch)
    }
}
```

## Paso 10: Implementar políticas de caché

Apollo Client ofrece varias políticas de caché que puedes utilizar según tus necesidades:

1. **returnCacheDataElseFetch**: Retorna datos de caché si están disponibles y no son muy viejos, de lo contrario hace fetch desde la red.
2. **returnCacheDataAndFetch**: Retorna datos de caché inmediatamente si están disponibles, pero también hace fetch en segundo plano para actualizar la caché.
3. **returnCacheDataDontFetch**: Retorna datos de caché si están disponibles, sin importar su edad, y no hace fetch desde la red.
4. **fetchIgnoringCacheData**: Ignora la caché y siempre hace fetch desde la red, pero guarda el resultado en caché.
5. **fetchIgnoringCacheCompletely**: Ignora la caché, hace fetch desde la red, y no guarda el resultado en caché.

## Paso 11: Implementar vistas con soporte de caché

Actualiza tus vistas para aprovechar las capacidades de caché:

```swift
struct ProductListView: View {
    @StateObject private var viewModel = ProductViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.products) { product in
                ProductRow(product: product)
            }
        }
        .refreshable {
            viewModel.refreshProducts()
        }
        .onAppear {
            // Primero intenta cargar desde caché
            viewModel.loadCachedProducts()
            
            // Luego actualiza en segundo plano
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                viewModel.fetchProducts(cachePolicy: .returnCacheDataAndFetch)
            }
        }
    }
}
```

## Beneficios de la caché de Apollo

1. **Mejor rendimiento**: Los datos se cargan instantáneamente desde la caché local.
2. **Experiencia offline**: Los usuarios pueden ver datos incluso sin conexión a internet.
3. **Reducción de tráfico de red**: Se realizan menos peticiones al servidor.
4. **Actualización en segundo plano**: Los datos se pueden mostrar inmediatamente desde la caché mientras se actualizan en segundo plano.
5. **Normalización de datos**: Apollo normaliza automáticamente los datos en caché, evitando duplicados.

## Consideraciones adicionales

1. **Tiempo de expiración**: Considera implementar un tiempo de expiración para los datos en caché.
2. **Invalidación de caché**: Implementa mecanismos para invalidar la caché cuando sea necesario.
3. **Tamaño de caché**: Monitorea el tamaño de la caché y limpia datos antiguos si es necesario.
4. **Sincronización**: Implementa estrategias para sincronizar datos modificados localmente con el servidor.

## Recursos adicionales

- [Documentación oficial de Apollo iOS](https://www.apollographql.com/docs/ios/)
- [Guía de caché de Apollo](https://www.apollographql.com/docs/ios/caching/)
- [Ejemplos de código de Apollo iOS](https://github.com/apollographql/apollo-ios/tree/main/Examples) 