import Foundation
import SwiftUI
import Combine

/// Utilidad para proporcionar acceso rápido a la introspección de GraphQL
class GraphQLIntrospectionUtil {
    
    /// Singleton para acceso global
    static let shared = GraphQLIntrospectionUtil()
    
    /// Servicio de introspección
    private let service = GraphQLIntrospectionService.shared
    
    /// Private initializer
    private init() {}
    
    /// Muestra el explorador de schema GraphQL
    /// - Parameter presentingViewController: El ViewController que presentará el explorador
    func showSchemaExplorer(from presentingViewController: UIViewController) {
        let hostingController = UIHostingController(rootView: GraphQLSchemaExplorerView())
        hostingController.modalPresentationStyle = .formSheet
        presentingViewController.present(hostingController, animated: true)
    }
    
    /// Verifica si una consulta existe en el schema
    /// - Parameter queryName: Nombre de la consulta
    /// - Returns: Un booleano que indica si la consulta existe
    func queryExists(_ queryName: String) -> Future<Bool, Error> {
        return Future { promise in
            self.service.getQueries()
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            promise(.failure(error))
                        }
                    },
                    receiveValue: { queries in
                        let exists = queries.contains { $0.name == queryName }
                        promise(.success(exists))
                    }
                )
                .store(in: &self.cancellables)
        }
    }
    
    /// Obtiene todos los nombres de tipos disponibles
    /// - Returns: Una lista de nombres de tipos
    func getTypeNames() -> Future<[String], Error> {
        return Future { promise in
            self.service.getAllTypes()
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            promise(.failure(error))
                        }
                    },
                    receiveValue: { types in
                        let typeNames = types.map { $0.name }
                        promise(.success(typeNames))
                    }
                )
                .store(in: &self.cancellables)
        }
    }
    
    /// Obtiene información detallada sobre un tipo
    /// - Parameter typeName: Nombre del tipo
    /// - Returns: Información del tipo
    func getTypeInfo(_ typeName: String) -> Future<GraphQLType, Error> {
        return Future { promise in
            self.service.getTypeInfo(typeName: typeName)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            promise(.failure(error))
                        }
                    },
                    receiveValue: { type in
                        promise(.success(type))
                    }
                )
                .store(in: &self.cancellables)
        }
    }
    
    /// Genera una consulta GraphQL para un tipo dado
    /// - Parameters:
    ///   - typeName: Nombre del tipo
    ///   - includeSubfields: Si se deben incluir subcampos para tipos complejos
    /// - Returns: Una cadena con la consulta GraphQL
    func generateQuery(for typeName: String, includeSubfields: Bool = true) -> Future<String, Error> {
        return Future { promise in
            self.getTypeInfo(typeName)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            promise(.failure(error))
                        }
                    },
                    receiveValue: { type in
                        var query = "{\n"
                        
                        if let fields = type.fields {
                            for field in fields {
                                query += "  \(field.name)"
                                
                                if includeSubfields && field.type.kind != "SCALAR" && !field.type.fullTypeName.contains("String") {
                                    query += " {\n    # Campos del tipo \(field.type.name ?? "Unknown")\n  }"
                                }
                                
                                query += "\n"
                            }
                        }
                        
                        query += "}"
                        promise(.success(query))
                    }
                )
                .store(in: &self.cancellables)
        }
    }
    
    /// Almacena las suscripciones activas
    private var cancellables = Set<AnyCancellable>()
} 