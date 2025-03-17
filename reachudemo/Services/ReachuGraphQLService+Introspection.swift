import Foundation
import Combine

// Extensión del servicio de GraphQL existente para añadir funcionalidad de introspección
extension ReachuGraphQLService {
    
    /// Realiza una consulta de introspección para obtener el esquema GraphQL
    /// - Returns: Un publisher que emite el esquema o un error
    func fetchGraphQLSchema() -> AnyPublisher<GraphQLSchema, Error> {
        // Utilizamos el servicio de introspección dedicado, que ahora usa nuestra instancia
        // de ReachuGraphQLService internamente
        return GraphQLIntrospectionService.shared.fetchSchema()
    }
    
    /// Verifica si el servidor tiene soporte para una consulta específica
    /// - Parameter queryName: Nombre de la consulta a verificar
    /// - Returns: Un publisher que emite true si la consulta existe
    func hasQuery(named queryName: String) -> AnyPublisher<Bool, Error> {
        return getQueries()
            .map { queries in
                return queries.contains { $0.name == queryName }
            }
            .eraseToAnyPublisher()
    }
    
    /// Obtiene todas las consultas disponibles en el esquema
    /// - Returns: Un publisher que emite la lista de consultas
    func getQueries() -> AnyPublisher<[GraphQLField], Error> {
        return GraphQLIntrospectionService.shared.getQueries()
    }
    
    /// Obtiene todas las mutaciones disponibles en el esquema
    /// - Returns: Un publisher que emite la lista de mutaciones
    func getMutations() -> AnyPublisher<[GraphQLField], Error> {
        return GraphQLIntrospectionService.shared.getMutations()
    }
    
    /// Obtiene todos los tipos definidos en el esquema
    /// - Returns: Un publisher que emite la lista de tipos
    func getAllTypes() -> AnyPublisher<[GraphQLType], Error> {
        return GraphQLIntrospectionService.shared.getAllTypes()
    }
    
    /// Obtiene información detallada sobre un tipo específico
    /// - Parameter typeName: Nombre del tipo a buscar
    /// - Returns: Un publisher que emite el tipo si existe
    func getTypeInfo(typeName: String) -> AnyPublisher<GraphQLType?, Error> {
        return GraphQLIntrospectionService.shared.getTypeInfo(typeName: typeName)
    }
    
    /// Valida si un tipo tiene un campo específico
    /// - Parameters:
    ///   - typeName: Nombre del tipo a verificar
    ///   - fieldName: Nombre del campo a buscar
    /// - Returns: Un publisher que emite true si el campo existe
    func typeHasField(typeName: String, fieldName: String) -> AnyPublisher<Bool, Error> {
        return getTypeInfo(typeName: typeName)
            .map { type -> Bool in
                guard let type = type, let fields = type.fields else {
                    return false
                }
                return fields.contains { $0.name == fieldName }
            }
            .eraseToAnyPublisher()
    }
    
    /// Valida si un tipo es una interfaz
    /// - Parameter typeName: Nombre del tipo a verificar
    /// - Returns: Un publisher que emite true si el tipo es una interfaz
    func isInterface(typeName: String) -> AnyPublisher<Bool, Error> {
        return getTypeInfo(typeName: typeName)
            .map { type -> Bool in
                return type?.kind == "INTERFACE"
            }
            .eraseToAnyPublisher()
    }
    
    /// Valida si un tipo es un objeto
    /// - Parameter typeName: Nombre del tipo a verificar
    /// - Returns: Un publisher que emite true si el tipo es un objeto
    func isObject(typeName: String) -> AnyPublisher<Bool, Error> {
        return getTypeInfo(typeName: typeName)
            .map { type -> Bool in
                return type?.kind == "OBJECT"
            }
            .eraseToAnyPublisher()
    }
    
    /// Función de conveniencia para guardar el esquema como JSON
    /// - Returns: Un publisher que emite la URL del archivo guardado
    func saveSchemaToFile() -> AnyPublisher<URL, Error> {
        return GraphQLIntrospectionService.shared.saveSchemaToFile()
    }
}

// Extension para añadir soporte para la vista de exploración
extension ReachuGraphQLService {
    /// Abre la vista de exploración del esquema GraphQL
    func openSchemaExplorer() -> GraphQLSchemaExplorerView {
        return GraphQLSchemaExplorerView()
    }
} 