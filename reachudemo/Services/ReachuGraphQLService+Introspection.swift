import Foundation
import Combine

// Extensión del servicio de GraphQL existente para añadir funcionalidad de introspección
extension ReachuGraphQLService {
    
    /// Realiza una consulta de introspección para obtener el esquema GraphQL
    /// - Returns: Un publisher que emite el esquema o un error
    func fetchGraphQLSchema() -> AnyPublisher<GraphQLSchema, Error> {
        // Utilizamos el servicio de introspección dedicado
        let introspectionService = GraphQLIntrospectionService.shared
        
        // Configuramos el servicio con nuestro token de autenticación
        introspectionService.configure(with: self.getAuthToken())
        
        return introspectionService.fetchSchema()
    }
    
    /// Verifica si el servidor tiene soporte para una consulta específica
    /// - Parameter queryName: Nombre de la consulta a verificar
    /// - Returns: Un publisher que emite un booleano indicando si existe la consulta
    func hasQuery(named queryName: String) -> AnyPublisher<Bool, Error> {
        return GraphQLIntrospectionService.shared.getQueries()
            .map { queries in
                return queries.contains { $0.name == queryName }
            }
            .eraseToAnyPublisher()
    }
    
    /// Verifica si el servidor tiene soporte para una mutación específica
    /// - Parameter mutationName: Nombre de la mutación a verificar
    /// - Returns: Un publisher que emite un booleano indicando si existe la mutación
    func hasMutation(named mutationName: String) -> AnyPublisher<Bool, Error> {
        return GraphQLIntrospectionService.shared.getMutations()
            .map { mutations in
                return mutations.contains { $0.name == mutationName }
            }
            .eraseToAnyPublisher()
    }
    
    /// Verifica si el servidor tiene un tipo específico
    /// - Parameter typeName: Nombre del tipo a verificar
    /// - Returns: Un publisher que emite un booleano indicando si existe el tipo
    func hasType(named typeName: String) -> AnyPublisher<Bool, Error> {
        return GraphQLIntrospectionService.shared.getAllTypes()
            .map { types in
                return types.contains { $0.name == typeName }
            }
            .eraseToAnyPublisher()
    }
    
    /// Obtiene una lista de campos disponibles para un tipo específico
    /// - Parameter typeName: Nombre del tipo a consultar
    /// - Returns: Un publisher que emite la lista de nombres de campos o un error
    func getFieldsForType(named typeName: String) -> AnyPublisher<[String], Error> {
        return GraphQLIntrospectionService.shared.getTypeInfo(typeName: typeName)
            .map { type -> [String] in
                guard let fields = type.fields else { return [] }
                return fields.map { $0.name }
            }
            .eraseToAnyPublisher()
    }
    
    /// Genera automáticamente una consulta GraphQL para un tipo específico
    /// - Parameters:
    ///   - typeName: Nombre del tipo para el que generar la consulta
    ///   - fieldNames: Nombres de los campos a incluir (opcional, si no se especifica, incluye todos)
    ///   - depth: Profundidad máxima para tipos anidados (por defecto 2)
    /// - Returns: Un publisher que emite la consulta generada o un error
    func generateQuery(forType typeName: String, includeFields fieldNames: [String]? = nil, maxDepth depth: Int = 2) -> AnyPublisher<String, Error> {
        return GraphQLIntrospectionService.shared.getTypeInfo(typeName: typeName)
            .map { type -> String in
                // Generamos una consulta para este tipo
                var query = "{\n"
                
                if let fields = type.fields {
                    let filteredFields = fieldNames != nil ? fields.filter { fieldNames!.contains($0.name) } : fields
                    
                    for field in filteredFields {
                        query += "  \(field.name)"
                        
                        // Para campos que devuelven tipos complejos, generamos subconsultas
                        if !field.type.fullTypeName.contains("String") && 
                           !field.type.fullTypeName.contains("Int") && 
                           !field.type.fullTypeName.contains("Float") && 
                           !field.type.fullTypeName.contains("Boolean") && 
                           !field.type.fullTypeName.contains("ID") &&
                           depth > 0 {
                            query += " {\n"
                            query += "    # Campos del tipo \(field.type.name ?? "Unknown")\n"
                            query += "    # Profundidad máxima alcanzada\n"
                            query += "  }"
                        }
                        
                        query += "\n"
                    }
                }
                
                query += "}"
                return query
            }
            .eraseToAnyPublisher()
    }
}

// Extension para añadir soporte para la vista de exploración
extension ReachuGraphQLService {
    /// Abre la vista de exploración del esquema GraphQL
    func openSchemaExplorer() -> GraphQLSchemaExplorerView {
        return GraphQLSchemaExplorerView()
    }
} 