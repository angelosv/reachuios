import Foundation
import Combine
import SwiftUI

/// Explorador de esquema GraphQL que puede obtener y presentar la información del esquema sin modificar el código existente
class GraphQLSchemaExplorer {
    // Singleton para acceso fácil
    static let shared = GraphQLSchemaExplorer()
    
    // Servicio GraphQL existente que usaremos para realizar consultas
    private let graphQLService = ReachuGraphQLService()
    
    // Almacenamiento en caché del esquema para no tener que cargarlo repetidamente
    private var cachedSchema: GraphQLSchema?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Métodos Públicos
    
    /// Obtiene el esquema completo del servidor GraphQL usando introspección
    /// - Returns: Un publisher que emite el esquema o un error
    func fetchSchema() -> AnyPublisher<GraphQLSchema, Error> {
        // Si ya tenemos el esquema en caché, lo devolvemos inmediatamente
        if let cachedSchema = cachedSchema {
            return Just(cachedSchema)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        // La consulta de introspección estándar que obtiene todo el esquema
        let introspectionQuery = """
        query IntrospectionQuery {
          __schema {
            queryType {
              name
              fields {
                name
                description
                type {
                  name
                  kind
                  ofType {
                    name
                    kind
                  }
                }
                args {
                  name
                  description
                  type {
                    name
                    kind
                    ofType {
                      name
                      kind
                    }
                  }
                  defaultValue
                }
              }
            }
            mutationType {
              name
              fields {
                name
                description
                type {
                  name
                  kind
                  ofType {
                    name
                    kind
                  }
                }
                args {
                  name
                  description
                  type {
                    name
                    kind
                    ofType {
                      name
                      kind
                    }
                  }
                  defaultValue
                }
              }
            }
            types {
              kind
              name
              description
              fields {
                name
                description
                type {
                  name
                  kind
                  ofType {
                    name
                    kind
                    ofType {
                      name
                      kind
                    }
                  }
                }
                args {
                  name
                  description
                  type {
                    name
                    kind
                    ofType {
                      name
                      kind
                    }
                  }
                  defaultValue
                }
              }
              inputFields {
                name
                description
                type {
                  name
                  kind
                  ofType {
                    name
                    kind
                  }
                }
                defaultValue
              }
              interfaces {
                name
              }
              enumValues {
                name
                description
              }
              possibleTypes {
                name
              }
            }
            directives {
              name
              description
              locations
              args {
                name
                description
                type {
                  name
                  kind
                  ofType {
                    name
                    kind
                  }
                }
                defaultValue
              }
            }
          }
        }
        """
        
        return graphQLService.performIntrospectionQuery(query: introspectionQuery)
            .tryMap { data -> GraphQLSchema in
                let decoder = JSONDecoder()
                let response = try decoder.decode(IntrospectionResponse.self, from: data)
                return response.data.__schema
            }
            .handleEvents(receiveOutput: { [weak self] schema in
                // Guardamos el esquema en caché para futura referencia
                self?.cachedSchema = schema
            })
            .eraseToAnyPublisher()
    }
    
    /// Busca un tipo específico en el esquema por nombre
    /// - Parameter name: Nombre del tipo a buscar
    /// - Returns: Publisher que emite el tipo encontrado o error
    func findType(name: String) -> AnyPublisher<GraphQLType?, Error> {
        return fetchSchema()
            .map { schema -> GraphQLType? in
                return schema.types.first { $0.name == name }
            }
            .eraseToAnyPublisher()
    }
    
    /// Obtiene todos los tipos de nivel superior (queries)
    /// - Returns: Publisher que emite la lista de campos de query disponibles
    func listQueries() -> AnyPublisher<[GraphQLField], Error> {
        return fetchSchema()
            .map { schema -> [GraphQLField] in
                if let queryTypeName = schema.queryType.name,
                   let queryType = schema.types.first(where: { $0.name == queryTypeName }) {
                    return queryType.fields ?? []
                }
                return []
            }
            .eraseToAnyPublisher()
    }
    
    /// Obtiene todas las mutaciones disponibles
    /// - Returns: Publisher que emite la lista de mutaciones disponibles
    func listMutations() -> AnyPublisher<[GraphQLField], Error> {
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
    
    /// Valida una consulta GraphQL contra el esquema
    /// Esta es una validación básica que solo verifica que los campos principales existan
    /// - Parameter query: La consulta GraphQL a validar
    /// - Returns: Publisher que emite true si la consulta parece válida
    func validateQuery(query: String) -> AnyPublisher<Bool, Error> {
        // Esta es una implementación simplificada que verifica los campos de nivel superior
        // Una validación completa requeriría un parser GraphQL completo
        
        return listQueries()
            .map { queryFields -> Bool in
                // Extrae los nombres de campo de la consulta (muy simplificado)
                let fieldPattern = try? NSRegularExpression(pattern: "\\{\\s*([a-zA-Z_][a-zA-Z0-9_]*)\\s*[({]")
                let queryRange = NSRange(query.startIndex..<query.endIndex, in: query)
                let matches = fieldPattern?.matches(in: query, range: queryRange) ?? []
                
                let requestedFields = matches.compactMap { match -> String? in
                    if match.numberOfRanges > 1,
                       let range = Range(match.range(at: 1), in: query) {
                        return String(query[range])
                    }
                    return nil
                }
                
                // Verifica que cada campo solicitado exista en el esquema
                let availableFieldNames = queryFields.map { $0.name }
                return requestedFields.allSatisfy { field in
                    availableFieldNames.contains(field)
                }
            }
            .eraseToAnyPublisher()
    }
    
    /// Guarda el esquema en un archivo JSON
    /// - Returns: URL del archivo guardado
    func saveSchemaToFile() -> AnyPublisher<URL, Error> {
        return fetchSchema()
            .tryMap { schema -> URL in
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                let data = try encoder.encode(schema)
                
                let docsDirectory = try FileManager.default.url(
                    for: .documentDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true
                )
                
                let fileURL = docsDirectory.appendingPathComponent("graphql-schema.json")
                try data.write(to: fileURL)
                return fileURL
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Extensión de ReachuGraphQLService

extension ReachuGraphQLService {
    /// Realiza una consulta de introspección GraphQL
    /// - Parameter query: La consulta de introspección
    /// - Returns: Publisher que emite los datos de respuesta o un error
    func performIntrospectionQuery(query: String) -> AnyPublisher<Data, Error> {
        return performGraphQLRequest(query: query)
    }
}

// MARK: - Vista de exploración del esquema

/// Vista SwiftUI para explorar el esquema GraphQL
struct SchemaExplorerView: View {
    @StateObject private var viewModel = SchemaExplorerViewModel()
    @State private var searchText = ""
    @State private var selectedTypeID: String?
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Queries")) {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        ForEach(viewModel.queries.filter {
                            searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
                        }) { query in
                            NavigationLink(
                                destination: ExplorerFieldDetailView(field: query),
                                tag: query.id,
                                selection: $selectedTypeID
                            ) {
                                VStack(alignment: .leading) {
                                    Text(query.name)
                                        .font(.headline)
                                    if let desc = query.description, !desc.isEmpty {
                                        Text(desc)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Tipos")) {
                    ForEach(viewModel.filterTypes(searchText)) { type in
                        NavigationLink(
                            destination: ExplorerTypeDetailView(type: type),
                            tag: type.id,
                            selection: $selectedTypeID
                        ) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(type.name ?? "Unknown")
                                        .font(.headline)
                                    Spacer()
                                    Text(type.kind)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                }
                                if let desc = type.description, !desc.isEmpty {
                                    Text(desc)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                            }
                        }
                    }
                }
                
                if !viewModel.schemaURL.isEmpty {
                    Section(header: Text("Exportación")) {
                        HStack {
                            Text("Esquema guardado en:")
                                .font(.caption)
                            Spacer()
                            Button(action: {
                                UIPasteboard.general.string = viewModel.schemaURL
                            }) {
                                Image(systemName: "doc.on.doc")
                            }
                        }
                        Text(viewModel.schemaURL)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if !viewModel.error.isEmpty {
                    Section(header: Text("Error")) {
                        Text(viewModel.error)
                            .foregroundColor(.red)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Buscar tipos o campos")
            .navigationTitle("Explorador GraphQL")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.refreshSchema()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.saveSchema()
                    }) {
                        Image(systemName: "square.and.arrow.down")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .onAppear {
                viewModel.loadSchema()
            }
            
            // Vista por defecto cuando no hay nada seleccionado
            Text("Selecciona un tipo o campo para ver sus detalles")
                .foregroundColor(.secondary)
        }
    }
}

/// Vista de detalle para un campo GraphQL
struct ExplorerFieldDetailView: View {
    let field: GraphQLField
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Encabezado
                VStack(alignment: .leading, spacing: 8) {
                    Text(field.name)
                        .font(.title)
                        .bold()
                    
                    if let desc = field.description, !desc.isEmpty {
                        Text(desc)
                            .foregroundColor(.secondary)
                    }
                    
                    TypeInfoView(type: field.type)
                }
                .padding(.bottom)
                
                // Argumentos
                if let args = field.args, !args.isEmpty {
                    Section(header: Text("Argumentos").font(.headline)) {
                        ForEach(args) { arg in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(arg.name)
                                        .font(.subheadline)
                                        .bold()
                                    
                                    Spacer()
                                    
                                    TypeInfoView(type: arg.type)
                                }
                                
                                if let desc = arg.description, !desc.isEmpty {
                                    Text(desc)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                if let defaultValue = arg.defaultValue {
                                    Text("Default: \(defaultValue)")
                                        .font(.caption)
                                        .italic()
                                }
                            }
                            .padding(.vertical, 4)
                            
                            Divider()
                        }
                    }
                }
                
                // Ejemplo de uso
                Section(header: Text("Ejemplo de uso").font(.headline)) {
                    VStack(alignment: .leading) {
                        Text("Query:")
                            .font(.subheadline)
                        
                        Text(generateExampleQuery())
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Campo: \(field.name)")
    }
    
    // Genera un ejemplo de consulta para este campo
    private func generateExampleQuery() -> String {
        var query = "query {\n"
        
        var indent = "  "
        query += "\(indent)\(field.name)"
        
        // Añadir argumentos si los hay
        if let args = field.args, !args.isEmpty {
            query += "("
            let argsText = args.map { arg -> String in
                let typeName = getTypeName(arg.type)
                // Generar un valor de ejemplo basado en el tipo
                let exampleValue: String
                if let typeName = typeName, typeName.contains("Int") {
                    exampleValue = "1"
                } else if let typeName = typeName, typeName.contains("Float") {
                    exampleValue = "1.0"
                } else if let typeName = typeName, typeName.contains("Boolean") {
                    exampleValue = "true"
                } else if let typeName = typeName, typeName.contains("ID") {
                    exampleValue = "\"id123\""
                } else {
                    exampleValue = "\"example\""
                }
                return "\(arg.name): \(exampleValue)"
            }.joined(separator: ", ")
            query += argsText
            query += ")"
        }
        
        // Añadir cuerpo basado en el tipo de retorno
        let typeName = getTypeName(field.type)
        if let typeName = typeName {
            // Si el tipo de retorno es un objeto, añadir subcampos
            if !isScalarType(typeName) {
                query += " {\n"
                indent += "  "
                query += "\(indent)# Añadir campos aquí\n"
                indent = "  "
                query += "\(indent)}"
            }
        }
        
        query += "\n}"
        return query
    }
    
    // Determina si un tipo es escalar
    private func isScalarType(_ typeName: String) -> Bool {
        let scalarTypes = ["String", "Int", "Float", "Boolean", "ID"]
        return scalarTypes.contains(typeName)
    }
    
    // Obtiene el nombre de un tipo recursivamente
    private func getTypeName(_ type: GraphQLTypeRef) -> String? {
        if let name = type.name {
            return name
        } else if let ofType = type.ofType {
            return getTypeName(ofType)
        }
        return nil
    }
}

/// Vista de detalle para un tipo GraphQL
struct ExplorerTypeDetailView: View {
    let type: GraphQLType
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Encabezado
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(type.name ?? "Unknown Type")
                            .font(.title)
                            .bold()
                        
                        Spacer()
                        
                        Text(type.kind)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    if let desc = type.description, !desc.isEmpty {
                        Text(desc)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom)
                
                // Campos
                if let fields = type.fields, !fields.isEmpty {
                    Section(header: Text("Campos").font(.headline)) {
                        ForEach(fields) { field in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(field.name)
                                        .font(.subheadline)
                                        .bold()
                                    
                                    Spacer()
                                    
                                    TypeInfoView(type: field.type)
                                }
                                
                                if let desc = field.description, !desc.isEmpty {
                                    Text(desc)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                // Argumentos en formato compacto
                                if let args = field.args, !args.isEmpty {
                                    Text("Args: \(args.map { $0.name }.joined(separator: ", "))")
                                        .font(.caption)
                                        .italic()
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                            
                            Divider()
                        }
                    }
                }
                
                // Campos de entrada (para tipos INPUT_OBJECT)
                if let inputFields = type.inputFields, !inputFields.isEmpty {
                    Section(header: Text("Campos de entrada").font(.headline)) {
                        ForEach(inputFields) { field in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(field.name)
                                        .font(.subheadline)
                                        .bold()
                                    
                                    Spacer()
                                    
                                    TypeInfoView(type: field.type)
                                }
                                
                                if let desc = field.description, !desc.isEmpty {
                                    Text(desc)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                if let defaultValue = field.defaultValue {
                                    Text("Default: \(defaultValue)")
                                        .font(.caption)
                                        .italic()
                                }
                            }
                            .padding(.vertical, 4)
                            
                            Divider()
                        }
                    }
                }
                
                // Valores de enumeración (para tipos ENUM)
                if let enumValues = type.enumValues, !enumValues.isEmpty {
                    Section(header: Text("Valores de enum").font(.headline)) {
                        ForEach(enumValues) { enumValue in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(enumValue.name)
                                    .font(.subheadline)
                                
                                if let desc = enumValue.description, !desc.isEmpty {
                                    Text(desc)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                            
                            Divider()
                        }
                    }
                }
                
                // Interfaces implementadas
                if let interfaces = type.interfaces, !interfaces.isEmpty {
                    Section(header: Text("Implementa interfaces").font(.headline)) {
                        ForEach(interfaces, id: \.name) { interface in
                            if let name = interface.name {
                                Text(name)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Tipo: \(type.name ?? "Unknown")")
    }
}

/// Vista para mostrar información de tipo (con ofType recursivo)
struct TypeInfoView: View {
    let type: GraphQLTypeRef
    
    var body: some View {
        Text(formatType(type))
            .font(.caption)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(4)
    }
    
    // Formatea el tipo recursivamente
    private func formatType(_ type: GraphQLTypeRef) -> String {
        let kind = type.kind
        
        switch kind {
        case "NON_NULL":
            if let ofType = type.ofType {
                return formatType(ofType) + "!"
            }
        case "LIST":
            if let ofType = type.ofType {
                return "[" + formatType(ofType) + "]"
            }
        default:
            if let name = type.name {
                return name
            }
        }
        
        return "Unknown"
    }
}

/// ViewModel para la vista de exploración del esquema
class SchemaExplorerViewModel: ObservableObject {
    @Published var queries: [GraphQLField] = []
    @Published var types: [GraphQLType] = []
    @Published var isLoading = false
    @Published var error = ""
    @Published var schemaURL = ""
    
    private let explorer = GraphQLSchemaExplorer.shared
    private var cancellables = Set<AnyCancellable>()
    
    func loadSchema() {
        isLoading = true
        error = ""
        
        explorer.fetchSchema()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let err) = completion {
                    self?.error = "Error cargando esquema: \(err.localizedDescription)"
                }
            }, receiveValue: { [weak self] schema in
                self?.processSchema(schema)
            })
            .store(in: &cancellables)
    }
    
    func refreshSchema() {
        // Forzar recarga del esquema invalidando la caché del servicio de introspección
        GraphQLIntrospectionService.shared.invalidateCache()
        loadSchema()
    }
    
    func saveSchema() {
        isLoading = true
        
        explorer.saveSchemaToFile()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let err) = completion {
                    self?.error = "Error guardando esquema: \(err.localizedDescription)"
                }
            }, receiveValue: { [weak self] url in
                self?.schemaURL = url.path
            })
            .store(in: &cancellables)
    }
    
    func filterTypes(_ searchText: String) -> [GraphQLType] {
        if searchText.isEmpty {
            return types.filter { $0.name != nil && !($0.name?.starts(with: "__") ?? false) }
        } else {
            return types.filter { type in
                guard let name = type.name else { return false }
                return !name.starts(with: "__") && name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func processSchema(_ schema: GraphQLSchema) {
        // Extraer queries
        explorer.listQueries()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] queries in
                self?.queries = queries
            })
            .store(in: &cancellables)
        
        // Guardar todos los tipos para la búsqueda
        self.types = schema.types.filter { $0.name != nil }
    }
} 