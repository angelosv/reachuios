import Foundation
import Combine

class GraphQLIntrospectionService {
    // Singleton para acceso global
    static let shared = GraphQLIntrospectionService()
    
    // URL del endpoint GraphQL (usando la misma que ReachuGraphQLService)
    private let endpoint = URL(string: "https://api.reachu.io/graphql")!
    
    // Token de autenticación (similar a ReachuGraphQLService)
    private var token = "YOUR_AUTH_TOKEN"
    
    // Almacena en caché el schema una vez obtenido
    private var cachedSchema: GraphQLSchema?
    
    // Previene la inicialización externa
    private init() {}
    
    // Método para configurar el token externamente
    func configure(with token: String) {
        self.token = token
        // Al cambiar el token invalidamos la caché
        self.cachedSchema = nil
    }
    
    /// Realiza una consulta de introspección para obtener el schema completo de GraphQL
    /// - Returns: Un publisher que emite el schema o un error
    func fetchSchema() -> AnyPublisher<GraphQLSchema, Error> {
        // Si ya tenemos el schema en caché, lo devolvemos inmediatamente
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
              fields {
                name
                description
                args {
                  name
                  description
                  type {
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
                  defaultValue
                }
                type {
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
                isDeprecated
                deprecationReason
              }
            }
            mutationType {
              name
              fields {
                name
                description
                args {
                  name
                  description
                  type {
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
                  defaultValue
                }
                type {
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
                isDeprecated
                deprecationReason
              }
            }
            subscriptionType {
              name
              fields {
                name
                description
                args {
                  name
                  description
                  type {
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
                  defaultValue
                }
                type {
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
                isDeprecated
                deprecationReason
              }
            }
            types {
              kind
              name
              description
              fields {
                name
                description
                args {
                  name
                  description
                  type {
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
                  defaultValue
                }
                type {
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
                isDeprecated
                deprecationReason
              }
              inputFields {
                name
                description
                type {
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
                defaultValue
              }
              interfaces {
                name
              }
              enumValues {
                name
                description
                isDeprecated
                deprecationReason
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
                defaultValue
              }
            }
          }
        }
        """
        
        // Preparamos la solicitud GraphQL
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Creamos el cuerpo JSON con la consulta
        let body: [String: Any] = [
            "query": introspectionQuery
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        // Realizamos la solicitud
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw NSError(domain: "GraphQLError", code: 0, userInfo: [
                        NSLocalizedDescriptionKey: "Error en la respuesta HTTP"
                    ])
                }
                return data
            }
            .decode(type: IntrospectionResponse.self, decoder: JSONDecoder())
            .map { response -> GraphQLSchema in
                // Guardamos en caché para futuras consultas
                self.cachedSchema = response.data.__schema
                return response.data.__schema
            }
            .eraseToAnyPublisher()
    }
    
    /// Obtiene información sobre un tipo específico del schema
    /// - Parameter typeName: Nombre del tipo a buscar
    /// - Returns: Un publisher que emite el tipo o un error
    func getTypeInfo(typeName: String) -> AnyPublisher<GraphQLType, Error> {
        return fetchSchema()
            .tryMap { schema -> GraphQLType in
                guard let type = schema.findType(name: typeName) else {
                    throw NSError(domain: "GraphQLError", code: 0, userInfo: [
                        NSLocalizedDescriptionKey: "Tipo no encontrado: \(typeName)"
                    ])
                }
                return type
            }
            .eraseToAnyPublisher()
    }
    
    /// Obtiene todos los tipos disponibles en el schema
    /// - Returns: Un publisher que emite la lista de tipos o un error
    func getAllTypes() -> AnyPublisher<[GraphQLType], Error> {
        return fetchSchema()
            .map { schema in
                // Filtramos los tipos internos que comienzan con "__"
                return schema.types.filter { !$0.name.starts(with: "__") }
            }
            .eraseToAnyPublisher()
    }
    
    /// Obtiene todos los tipos objeto (no escalares, no entradas, etc.)
    /// - Returns: Un publisher que emite la lista de tipos objeto o un error
    func getObjectTypes() -> AnyPublisher<[GraphQLType], Error> {
        return fetchSchema()
            .map { schema in
                return schema.objectTypes
            }
            .eraseToAnyPublisher()
    }
    
    /// Obtiene todas las consultas disponibles en el schema
    /// - Returns: Un publisher que emite la lista de campos de consulta o un error
    func getQueries() -> AnyPublisher<[GraphQLField], Error> {
        return fetchSchema()
            .tryMap { schema -> [GraphQLField] in
                guard let queryType = schema.rootQueryType, let fields = queryType.fields else {
                    throw NSError(domain: "GraphQLError", code: 0, userInfo: [
                        NSLocalizedDescriptionKey: "No se encontraron consultas en el schema"
                    ])
                }
                return fields
            }
            .eraseToAnyPublisher()
    }
    
    /// Obtiene todas las mutaciones disponibles en el schema
    /// - Returns: Un publisher que emite la lista de campos de mutación o un error
    func getMutations() -> AnyPublisher<[GraphQLField], Error> {
        return fetchSchema()
            .tryMap { schema -> [GraphQLField] in
                guard let mutationType = schema.mutationRootType, let fields = mutationType.fields else {
                    throw NSError(domain: "GraphQLError", code: 0, userInfo: [
                        NSLocalizedDescriptionKey: "No se encontraron mutaciones en el schema"
                    ])
                }
                return fields
            }
            .eraseToAnyPublisher()
    }
} 