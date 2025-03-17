import SwiftUI
import Combine

struct GraphQLSchemaExplorerView: View {
    @StateObject private var viewModel = GraphQLSchemaExplorerViewModel()
    @State private var selectedTypeIndex: Int?
    @State private var selectedSection: SchemaSection = .types
    
    enum SchemaSection {
        case types, queries, mutations
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Selector de sección
                Picker("Sección", selection: $selectedSection) {
                    Text("Tipos").tag(SchemaSection.types)
                    Text("Consultas").tag(SchemaSection.queries)
                    Text("Mutaciones").tag(SchemaSection.mutations)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Estado de carga
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                        Text("Cargando schema GraphQL...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                // Estado de error
                else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                            .padding()
                        
                        Text("Error al cargar el schema:")
                            .fontWeight(.bold)
                        
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button(action: {
                            viewModel.loadSchema()
                        }) {
                            Text("Reintentar")
                                .fontWeight(.bold)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                // Contenido principal
                else {
                    // Mostrar la lista correspondiente según la sección seleccionada
                    switch selectedSection {
                    case .types:
                        typesList
                    case .queries:
                        queriesList
                    case .mutations:
                        mutationsList
                    }
                }
            }
            .navigationTitle("Explorador GraphQL")
            .onAppear {
                viewModel.loadSchema()
            }
        }
    }
    
    // Vista de la lista de tipos
    private var typesList: some View {
        List {
            ForEach(viewModel.types.indices, id: \.self) { index in
                NavigationLink(
                    destination: TypeDetailView(type: viewModel.types[index]),
                    tag: index,
                    selection: $selectedTypeIndex
                ) {
                    HStack {
                        Text(viewModel.types[index].name ?? "Unknown")
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        // Indicador del tipo de tipo (Objeto, Escalar, etc.)
                        Text(viewModel.types[index].kind)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.systemGray6))
                            )
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    // Vista de la lista de consultas
    private var queriesList: some View {
        List {
            if viewModel.queries.isEmpty {
                Text("No se encontraron consultas disponibles")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(viewModel.queries) { query in
                    NavigationLink(
                        destination: FieldDetailView(field: query)
                    ) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(query.name)
                                .fontWeight(.medium)
                            
                            if let description = query.description, !description.isEmpty {
                                Text(description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            
                            // Tipo de retorno
                            Text("Retorna: \(query.type.fullTypeName)")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    // Vista de la lista de mutaciones
    private var mutationsList: some View {
        List {
            if viewModel.mutations.isEmpty {
                Text("No se encontraron mutaciones disponibles")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(viewModel.mutations) { mutation in
                    NavigationLink(
                        destination: FieldDetailView(field: mutation)
                    ) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mutation.name)
                                .fontWeight(.medium)
                            
                            if let description = mutation.description, !description.isEmpty {
                                Text(description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            
                            // Tipo de retorno
                            Text("Retorna: \(mutation.type.fullTypeName)")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

// Vista detallada de un tipo
struct TypeDetailView: View {
    let type: GraphQLType
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Encabezado
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(type.name ?? "Unknown Type")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text(type.kind)
                            .font(.subheadline)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(.systemGray6))
                            )
                    }
                    
                    if let description = type.description, !description.isEmpty {
                        Text(description)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 8)
                
                Divider()
                
                // Campos (para objetos)
                if type.isObject, let fields = type.fields, !fields.isEmpty {
                    fieldsSection(title: "Campos", fields: fields)
                }
                
                // Campos de entrada (para tipos de entrada)
                if type.isInputObject, let inputFields = type.inputFields, !inputFields.isEmpty {
                    inputFieldsSection(title: "Campos de entrada", fields: inputFields)
                }
                
                // Valores de enumeración
                if type.isEnum, let enumValues = type.enumValues, !enumValues.isEmpty {
                    enumValuesSection(title: "Valores de enumeración", values: enumValues)
                }
                
                // Interfaces implementadas
                if let interfaces = type.interfaces, !interfaces.isEmpty {
                    interfacesSection(title: "Interfaces implementadas", interfaces: interfaces)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(type.name ?? "Type Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Sección para mostrar campos
    private func fieldsSection(title: String, fields: [GraphQLField]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            ForEach(fields) { field in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(field.name)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text(field.type.fullTypeName)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    if let description = field.description, !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Argumentos
                    if let args = field.args, !args.isEmpty {
                        Text("Argumentos:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.top, 2)
                        
                        ForEach(args) { arg in
                            HStack {
                                Text("• \(arg.name):")
                                    .font(.caption)
                                
                                Text(arg.type.fullTypeName)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                
                                if let defaultValue = arg.defaultValue {
                                    Text("= \(defaultValue)")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
            }
        }
    }
    
    // Sección para mostrar campos de entrada
    private func inputFieldsSection(title: String, fields: [GraphQLInputField]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            ForEach(fields) { field in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(field.name)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text(field.type.fullTypeName)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    if let description = field.description, !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let defaultValue = field.defaultValue {
                        Text("Valor predeterminado: \(defaultValue)")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
            }
        }
    }
    
    // Sección para mostrar valores de enumeración
    private func enumValuesSection(title: String, values: [GraphQLEnumValue]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            ForEach(values) { value in
                VStack(alignment: .leading, spacing: 4) {
                    Text(value.name)
                        .fontWeight(.semibold)
                    
                    if let description = value.description, !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let isDeprecated = value.isDeprecated, isDeprecated {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            
                            Text("Obsoleto")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                            if let reason = value.deprecationReason {
                                Text(reason)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
            }
        }
    }
    
    // Sección para mostrar interfaces
    private func interfacesSection(title: String, interfaces: [TypeRef]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            ForEach(interfaces, id: \.name) { interface in
                Text(interface.name ?? "Unknown Interface")
                    .fontWeight(.semibold)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                    )
            }
        }
    }
}

// Vista detallada de un campo
struct FieldDetailView: View {
    let field: GraphQLField
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Encabezado
                VStack(alignment: .leading, spacing: 8) {
                    Text(field.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let description = field.description, !description.isEmpty {
                        Text(description)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Retorna:")
                            .fontWeight(.medium)
                        
                        Text(field.type.fullTypeName)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 4)
                    
                    if let isDeprecated = field.isDeprecated, isDeprecated {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            
                            Text("Obsoleto")
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                            
                            if let reason = field.deprecationReason {
                                Text(reason)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.bottom, 8)
                
                Divider()
                
                // Argumentos
                if let args = field.args, !args.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Argumentos")
                            .font(.headline)
                        
                        ForEach(args) { arg in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(arg.name)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                    
                                    Text(arg.type.fullTypeName)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                
                                if let description = arg.description, !description.isEmpty {
                                    Text(description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                if let defaultValue = arg.defaultValue {
                                    Text("Valor predeterminado: \(defaultValue)")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                            )
                        }
                    }
                } else {
                    Text("Esta operación no requiere argumentos")
                        .foregroundColor(.secondary)
                        .italic()
                }
                
                Divider()
                
                // Ejemplo de cómo usar esta consulta/mutación
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ejemplo de uso")
                        .font(.headline)
                    
                    Text(generateQueryExample())
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = generateQueryExample()
                            }) {
                                Label("Copiar al portapapeles", systemImage: "doc.on.doc")
                            }
                        }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(field.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Genera un ejemplo de consulta GraphQL para este campo
    private func generateQueryExample() -> String {
        var query = ""
        
        // Determinar si es una consulta o mutación
        if field.name.starts(with: "get") || field.name.starts(with: "list") || field.name.starts(with: "search") {
            query = "query {\n"
        } else {
            query = "mutation {\n"
        }
        
        // Nombre del campo
        query += "  \(field.name)"
        
        // Agregar argumentos si existen
        if let args = field.args, !args.isEmpty {
            query += "("
            let argsStrings = args.map { arg in
                let valueExample = getExampleValueForType(arg.type)
                return "\(arg.name): \(valueExample)"
            }
            query += argsStrings.joined(separator: ", ")
            query += ")"
        }
        
        // Cuerpo de la consulta (campos que podrían retornarse)
        query += " {\n"
        query += "    # Campos de respuesta\n"
        query += "    # Por ejemplo: id, name, etc.\n"
        query += "  }\n"
        query += "}"
        
        return query
    }
    
    // Genera un valor de ejemplo para un tipo
    private func getExampleValueForType(_ type: GraphQLTypeRef) -> String {
        switch type.kind {
        case "SCALAR":
            if let name = type.name {
                switch name {
                case "ID", "String":
                    return "\"example\""
                case "Int":
                    return "123"
                case "Float":
                    return "123.45"
                case "Boolean":
                    return "true"
                default:
                    return "\"...\""
                }
            }
            return "\"...\""
        case "NON_NULL":
            return getExampleValueForType(type.ofType!)
        case "LIST":
            return "[\(getExampleValueForType(type.ofType!))]"
        case "ENUM":
            return "ENUM_VALUE"
        case "INPUT_OBJECT":
            return "{ ... }"
        default:
            return "..."
        }
    }
}

// ViewModel para el explorador de schema
class GraphQLSchemaExplorerViewModel: ObservableObject {
    @Published var types: [GraphQLType] = []
    @Published var queries: [GraphQLField] = []
    @Published var mutations: [GraphQLField] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadSchema() {
        isLoading = true
        errorMessage = nil
        
        // Cargamos el schema
        GraphQLIntrospectionService.shared.fetchSchema()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] schema in
                    // Tipos
                    self?.types = schema.types
                        .filter { !($0.name?.starts(with: "__") ?? false) }
                        .sorted { ($0.name ?? "") < ($1.name ?? "") }
                    
                    // Consultas
                    if let queryType = schema.rootQueryType, let fields = queryType.fields {
                        self?.queries = fields.sorted { $0.name < $1.name }
                    } else {
                        self?.queries = []
                    }
                    
                    // Mutaciones
                    if let mutationType = schema.mutationRootType, let fields = mutationType.fields {
                        self?.mutations = fields.sorted { $0.name < $1.name }
                    } else {
                        self?.mutations = []
                    }
                }
            )
            .store(in: &cancellables)
    }
} 