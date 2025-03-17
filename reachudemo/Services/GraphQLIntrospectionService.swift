import Foundation
import Combine

class GraphQLIntrospectionService {
    // Singleton para acceso global
    static let shared = GraphQLIntrospectionService()
    
    // Servicio GraphQL existente que usaremos para realizar las consultas
    private let graphQLService = ReachuGraphQLService()
    
    // Almacena en caché el schema una vez obtenido
    private var cachedSchema: GraphQLSchema?
    
    // Previene la inicialización externa
    private init() {}
    
    /// Método para obtener el esquema GraphQL completo
    /// - Returns: Un publisher que emite el esquema o un error
    func fetchSchema() -> AnyPublisher<GraphQLSchema, Error> {
        // Si ya tenemos el esquema en caché, lo devolvemos inmediatamente
        if let cachedSchema = cachedSchema {
            return Just(cachedSchema)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        // La consulta de introspección estándar
        let introspectionQuery = """
        query IntrospectionQuery {
          __schema {
            queryType {
              name
            }
            mutationType {
              name
            }
            subscriptionType {
              name
            }
            types {
              ...FullType
            }
            directives {
              name
              description
              locations
              args {
                ...InputValue
              }
            }
          }
        }

        fragment FullType on __Type {
          kind
          name
          description
          fields(includeDeprecated: true) {
            name
            description
            args {
              ...InputValue
            }
            type {
              ...TypeRef
            }
            isDeprecated
            deprecationReason
          }
          inputFields {
            ...InputValue
          }
          interfaces {
            ...TypeRef
          }
          enumValues(includeDeprecated: true) {
            name
            description
            isDeprecated
            deprecationReason
          }
          possibleTypes {
            ...TypeRef
          }
        }

        fragment InputValue on __InputValue {
          name
          description
          type {
            ...TypeRef
          }
          defaultValue
        }

        fragment TypeRef on __Type {
          kind
          name
          ofType {
            kind
            name
            ofType {
              kind
              name
              ofType {
                kind
                name
                ofType {
                  kind
                  name
                  ofType {
                    kind
                    name
                    ofType {
                      kind
                      name
                      ofType {
                        kind
                        name
                      }
                    }
                  }
                }
              }
            }
          }
        }
        """
        
        // Utilizamos el servicio GraphQL existente para realizar la consulta
        return graphQLService.performGraphQLRequest(query: introspectionQuery)
            .tryMap { data -> GraphQLSchema in
                let response = try JSONDecoder().decode(IntrospectionResponse.self, from: data)
                return response.data.__schema
            }
            .handleEvents(receiveOutput: { [weak self] schema in
                // Guardamos el esquema en caché
                self?.cachedSchema = schema
                print("✅ Schema GraphQL obtenido con éxito: \(schema.types.count) tipos")
            })
            .catch { error -> AnyPublisher<GraphQLSchema, Error> in
                print("❌ Error obteniendo schema GraphQL: \(error.localizedDescription)")
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// Obtiene la lista de todos los tipos definidos en el esquema
    /// - Returns: Publisher que emite la lista de tipos o un error
    func getAllTypes() -> AnyPublisher<[GraphQLType], Error> {
        return fetchSchema()
            .map { schema in
                return schema.types
                    .filter { !($0.name?.starts(with: "__") ?? false) } // Filtramos tipos internos
                    .sorted { ($0.name ?? "") < ($1.name ?? "") }       // Ordenamos alfabéticamente
            }
            .eraseToAnyPublisher()
    }
    
    /// Obtiene información detallada sobre un tipo específico
    /// - Parameter typeName: Nombre del tipo a buscar
    /// - Returns: Publisher que emite el tipo encontrado o un error
    func getTypeInfo(typeName: String) -> AnyPublisher<GraphQLType?, Error> {
        return fetchSchema()
            .map { schema in
                return schema.types.first { $0.name == typeName }
            }
            .eraseToAnyPublisher()
    }
    
    /// Obtiene la lista de todas las consultas disponibles
    /// - Returns: Publisher que emite la lista de campos de consulta o un error
    func getQueries() -> AnyPublisher<[GraphQLField], Error> {
        return fetchSchema()
            .map { schema -> [GraphQLField] in
                if let rootQueryName = schema.queryType.name,
                   let rootQueryType = schema.types.first(where: { $0.name == rootQueryName }) {
                    return rootQueryType.fields ?? []
                }
                return []
            }
            .eraseToAnyPublisher()
    }
    
    /// Obtiene la lista de todas las mutaciones disponibles
    /// - Returns: Publisher que emite la lista de mutaciones o un error
    func getMutations() -> AnyPublisher<[GraphQLField], Error> {
        return fetchSchema()
            .map { schema -> [GraphQLField] in
                if let mutationType = schema.mutationType,
                   let mutationTypeName = mutationType.name,
                   let mutationType = schema.types.first(where: { $0.name == mutationTypeName }) {
                    return mutationType.fields ?? []
                }
                return []
            }
            .eraseToAnyPublisher()
    }
    
    /// Invalida la caché del esquema para forzar una recarga
    func invalidateCache() {
        cachedSchema = nil
        print("🔄 Caché de schema GraphQL invalidada")
    }
    
    /// Guarda el esquema en un archivo JSON para referencia
    /// - Returns: Publisher que emite la URL del archivo guardado o un error
    func saveSchemaToFile() -> AnyPublisher<URL, Error> {
        return fetchSchema()
            .tryMap { schema -> URL in
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                let data = try encoder.encode(schema)
                
                let fileManager = FileManager.default
                let docsDirectory = try fileManager.url(
                    for: .documentDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true
                )
                
                let fileURL = docsDirectory.appendingPathComponent("graphql-schema.json")
                try data.write(to: fileURL)
                print("📄 Schema GraphQL guardado en: \(fileURL.path)")
                return fileURL
            }
            .eraseToAnyPublisher()
    }
} 