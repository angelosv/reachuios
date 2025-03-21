import Foundation

// Respuesta principal de una consulta de introspección
struct IntrospectionResponse: Codable {
    let data: SchemaData
}

// Datos del schema
struct SchemaData: Codable {
    let __schema: GraphQLSchema
}

// Estructura del schema completo
struct GraphQLSchema: Codable {
    let queryType: TypeRef
    let mutationType: TypeRef?
    let subscriptionType: TypeRef?
    let types: [GraphQLType]
    let directives: [GraphQLDirective]
}

// Referencia a un tipo
struct TypeRef: Codable {
    let name: String?
    let fields: [GraphQLField]?
}

// Definición completa de un tipo GraphQL
struct GraphQLType: Codable, Identifiable {
    var id: String { name ?? "unknown" }
    
    let name: String?
    let kind: String
    let description: String?
    let fields: [GraphQLField]?
    let inputFields: [GraphQLInputField]?
    let interfaces: [TypeRef]?
    let enumValues: [GraphQLEnumValue]?
    let possibleTypes: [TypeRef]?
    
    // Indica si es un tipo escalar (String, Int, Boolean, etc.)
    var isScalar: Bool {
        kind == "SCALAR"
    }
    
    // Indica si es un tipo objeto (con campos)
    var isObject: Bool {
        kind == "OBJECT"
    }
    
    // Indica si es un tipo entrada (para argumentos)
    var isInputObject: Bool {
        kind == "INPUT_OBJECT"
    }
    
    // Indica si es una enumeración
    var isEnum: Bool {
        kind == "ENUM"
    }
    
    // Indica si es una interfaz
    var isInterface: Bool {
        kind == "INTERFACE"
    }
    
    // Indica si es un tipo unión
    var isUnion: Bool {
        kind == "UNION"
    }
}

// Campo de un tipo GraphQL - Convertido a class para evitar recursividad infinita
class GraphQLField: Codable, Identifiable {
    var id: String { name }
    
    let name: String
    let description: String?
    let args: [GraphQLInputField]?
    let type: GraphQLTypeRef
    let isDeprecated: Bool?
    let deprecationReason: String?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        args = try container.decodeIfPresent([GraphQLInputField].self, forKey: .args)
        type = try container.decode(GraphQLTypeRef.self, forKey: .type)
        isDeprecated = try container.decodeIfPresent(Bool.self, forKey: .isDeprecated)
        deprecationReason = try container.decodeIfPresent(String.self, forKey: .deprecationReason)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(args, forKey: .args)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(isDeprecated, forKey: .isDeprecated)
        try container.encodeIfPresent(deprecationReason, forKey: .deprecationReason)
    }
    
    enum CodingKeys: String, CodingKey {
        case name, description, args, type, isDeprecated, deprecationReason
    }
}

// Campo de entrada (para argumentos) - Convertido a class para evitar recursividad infinita
class GraphQLInputField: Codable, Identifiable {
    var id: String { name }
    
    let name: String
    let description: String?
    let type: GraphQLTypeRef
    let defaultValue: String?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        type = try container.decode(GraphQLTypeRef.self, forKey: .type)
        defaultValue = try container.decodeIfPresent(String.self, forKey: .defaultValue)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(defaultValue, forKey: .defaultValue)
    }
    
    enum CodingKeys: String, CodingKey {
        case name, description, type, defaultValue
    }
}

// Referencia a un tipo, puede ser anidada - Convertido a class para evitar recursividad infinita
class GraphQLTypeRef: Codable {
    let kind: String
    let name: String?
    let ofType: GraphQLTypeRef?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        kind = try container.decode(String.self, forKey: .kind)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        ofType = try container.decodeIfPresent(GraphQLTypeRef.self, forKey: .ofType)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kind, forKey: .kind)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(ofType, forKey: .ofType)
    }
    
    enum CodingKeys: String, CodingKey {
        case kind, name, ofType
    }
    
    // Obtiene el nombre completo del tipo, incluyendo modificadores
    var fullTypeName: String {
        switch kind {
        case "NON_NULL":
            return "\(ofType?.fullTypeName ?? "Unknown")!"
        case "LIST":
            return "[\(ofType?.fullTypeName ?? "Unknown")]"
        default:
            return name ?? "Unknown"
        }
    }
}

// Valor de una enumeración
struct GraphQLEnumValue: Codable, Identifiable {
    var id: String { name }
    
    let name: String
    let description: String?
    let isDeprecated: Bool?
    let deprecationReason: String?
}

// Directiva GraphQL
struct GraphQLDirective: Codable, Identifiable {
    var id: String { name }
    
    let name: String
    let description: String?
    let locations: [String]
    let args: [GraphQLInputField]
}

// Extensión para hacer más fácil el análisis del schema
extension GraphQLSchema {
    // Busca un tipo por nombre
    func findType(name: String) -> GraphQLType? {
        return types.first(where: { $0.name == name })
    }
    
    // Obtiene todos los tipos objeto (no escalares, no entradas, etc.)
    var objectTypes: [GraphQLType] {
        return types.filter { $0.isObject && !($0.name?.starts(with: "__") ?? false) }
    }
    
    // Obtiene todos los tipos de entrada
    var inputTypes: [GraphQLType] {
        return types.filter { $0.isInputObject }
    }
    
    // Obtiene todos los tipos escalares
    var scalarTypes: [GraphQLType] {
        return types.filter { $0.isScalar }
    }
    
    // Obtiene todas las enumeraciones
    var enumTypes: [GraphQLType] {
        return types.filter { $0.isEnum }
    }
    
    // Obtiene el tipo raíz para consultas
    var rootQueryType: GraphQLType? {
        guard let name = self.queryType.name else { return nil }
        return findType(name: name)
    }
    
    // Obtiene el tipo raíz para mutaciones (si existe)
    var mutationRootType: GraphQLType? {
        guard let mutationType = self.mutationType, 
              let name = mutationType.name else { return nil }
        return findType(name: name)
    }
}
