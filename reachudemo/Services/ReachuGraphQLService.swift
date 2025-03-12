import Foundation
import Combine

// Modelo de respuesta para la API de Reachu
struct ReachuResponse: Codable {
    let data: ReachuData
}

struct ReachuData: Codable {
    let Channel: ReachuChannel
}

struct ReachuChannel: Codable {
    let GetProducts: [ReachuProduct]
}

// Modelo de producto para Reachu
struct ReachuProduct: Codable, Identifiable {
    let id: String
    let images: [ReachuImage]
    let price: ReachuPrice
    let title: String
    let description: String?
    
    var mainImageURL: URL? {
        // Obtener la imagen principal (orden = 0) o la primera disponible
        if let mainImage = images.first(where: { $0.order == 0 }) {
            return URL(string: mainImage.url)
        }
        return images.first.flatMap { URL(string: $0.url) }
    }
    
    var formattedPrice: String {
        return price.formattedPrice
    }
    
    // Custom init para manejar el id como Int o String
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Intentar decodificar id como Int o String
        if let idInt = try? container.decode(Int.self, forKey: .id) {
            id = String(idInt)
        } else {
            id = try container.decode(String.self, forKey: .id)
        }
        
        images = try container.decode([ReachuImage].self, forKey: .images)
        price = try container.decode(ReachuPrice.self, forKey: .price)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
    }
    
    // Custom init para parseProductsManually
    init(id: String, images: [ReachuImage], price: ReachuPrice, title: String, description: String? = nil) {
        self.id = id
        self.images = images
        self.price = price
        self.title = title
        self.description = description
    }
    
    enum CodingKeys: String, CodingKey {
        case id, images, price, title, description
    }
}

struct ReachuImage: Codable {
    let url: String
    let order: Int
    let id: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        url = try container.decode(String.self, forKey: .url)
        order = try container.decode(Int.self, forKey: .order)
        
        // Intentar decodificar id como opcional (Int o String)
        if let idInt = try? container.decode(Int.self, forKey: .id) {
            id = String(idInt)
        } else {
            id = try? container.decode(String.self, forKey: .id)
        }
    }
    
    // Constructor para mantener compatibilidad con el código existente
    init(url: String, order: Int, id: String? = nil) {
        self.url = url
        self.order = order
        self.id = id
    }
    
    enum CodingKeys: String, CodingKey {
        case url, order, id
    }
}

struct ReachuPrice: Codable {
    let currency_code: String
    let amount: String
    let compare_at: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decodificar currency_code
        currency_code = try container.decode(String.self, forKey: .currency_code)
        
        // Manejar amount como Int o String
        if let amountInt = try? container.decode(Int.self, forKey: .amount) {
            amount = String(amountInt)
        } else {
            amount = try container.decode(String.self, forKey: .amount)
        }
        
        // Manejar compare_at como Int, String o nil
        if let compareAtInt = try? container.decode(Int.self, forKey: .compare_at) {
            compare_at = String(compareAtInt)
        } else {
            compare_at = try? container.decode(String.self, forKey: .compare_at)
        }
    }
    
    // Constructor para mantener compatibilidad con el código existente
    init(currency_code: String, amount: String, compare_at: String? = nil) {
        self.currency_code = currency_code
        self.amount = amount
        self.compare_at = compare_at
    }
    
    enum CodingKeys: String, CodingKey {
        case currency_code, amount, compare_at
    }
    
    var formattedPrice: String {
        // Intentar convertir el monto a Double para formatear correctamente
        if let amountDouble = Double(amount) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currency_code
            formatter.maximumFractionDigits = 0
            formatter.minimumFractionDigits = 0  // No decimal places shown
            
            if let formattedAmount = formatter.string(from: NSNumber(value: amountDouble)) {
                return formattedAmount
            }
        }
        
        // Fallback al formato básico si no se puede convertir
        return "\(currency_code) \(amount)"
    }
    
    var hasDiscount: Bool {
        guard let compareAtStr = compare_at, !compareAtStr.isEmpty else { return false }
        
        if let compareDouble = Double(compareAtStr), let amountDouble = Double(amount) {
            return compareDouble > amountDouble
        }
        
        return false
    }
    
    var formattedCompareAtPrice: String? {
        guard let compareAtStr = compare_at, !compareAtStr.isEmpty else { return nil }
        
        if let compareDouble = Double(compareAtStr) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currency_code
            formatter.maximumFractionDigits = 0
            formatter.minimumFractionDigits = 0
            
            if let formattedAmount = formatter.string(from: NSNumber(value: compareDouble)) {
                return formattedAmount
            }
        }
        
        return nil
    }
}

// Modelo alternativo para probar otras estructuras
struct AlternativeReachuResponse: Codable {
    let data: AlternativeData?
    let errors: [ReachuGraphQLError]?
    
    func extractProducts() -> [ReachuProduct]? {
        // Intento 1: Estructura con Channel
        if let channel = data?.Channel,
           let products = channel.GetProducts {
            return products
        }
        
        // Intento 2: Estructura con channel (minúsculas)
        if let channel = data?.channel,
           let products = channel.getProducts {
            return products
        }
        
        // Intento 3: Estructura directa con products
        if let products = data?.products {
            return products
        }
        
        return nil
    }
}

struct AlternativeData: Codable {
    let Channel: AlternativeChannel?
    let channel: AlternativeChannelLowercase?
    let products: [ReachuProduct]?
}

struct AlternativeChannel: Codable {
    let GetProducts: [ReachuProduct]?
}

struct AlternativeChannelLowercase: Codable {
    let getProducts: [ReachuProduct]?
}

struct ReachuGraphQLError: Codable {
    let message: String
    let locations: [ErrorLocation]?
    let path: [String]?
}

struct ErrorLocation: Codable {
    let line: Int
    let column: Int
}

class ReachuGraphQLService {
    private let endpointURL = URL(string: "https://graph-ql.reachu.io/")!
    private let authToken = "ZN7EYWW-ZVX4PD9-Q74031G-MXTHK3R"
    
    enum APIError: Error, LocalizedError {
        case invalidResponse
        case networkError(Error)
        case decodingError(Error)
        case serverError(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidResponse:
                return "La respuesta del servidor no es válida"
            case .networkError(let error):
                return "Error de red: \(error.localizedDescription)"
            case .decodingError(let error):
                return "Error al procesar la respuesta: \(error.localizedDescription)"
            case .serverError(let message):
                return "Error del servidor: \(message)"
            }
        }
    }
    
    func fetchProducts() -> AnyPublisher<[ReachuProduct], Error> {
        print("🔍 Iniciando solicitud GraphQL para obtener productos")
        
        let query = """
        query GetProducts {
          Channel {
            GetProducts {
              id
              images {
                url
                order
                id
              }
              price {
                currency_code
                amount
                compare_at
              }
              title
              description
            }
          }
        }
        """
        
        return performGraphQLRequest(query: query)
            .tryMap { [self] data -> [ReachuProduct] in
                print("📦 Procesando respuesta GraphQL")
                
                // Imprimir la respuesta completa
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📄 Respuesta JSON completa:\n\(jsonString)")
                }
                
                // Intentar primero con la estructura esperada
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(ReachuResponse.self, from: data)
                    print("✅ Decodificación exitosa, se encontraron \(response.data.Channel.GetProducts.count) productos")
                    
                    // Imprimir información detallada de productos y filtrar productos inválidos
                    var validProducts: [ReachuProduct] = []
                    
                    for (index, product) in response.data.Channel.GetProducts.enumerated() {
                        print("📝 Producto \(index + 1): id=\(product.id), title=\(product.title), precio=\(product.price.amount) \(product.price.currency_code)")
                        
                        if product.images.isEmpty {
                            print("⚠️ Producto \(index + 1) no tiene imágenes, se omitirá")
                            continue
                        }
                        
                        print("   🖼️ \(product.images.count) imágenes, primera URL: \(product.images.first?.url ?? "N/A")")
                        
                        // Verificar que la URL de la imagen sea válida
                        if let mainImageURL = product.mainImageURL {
                            print("   ✅ URL principal válida: \(mainImageURL)")
                            validProducts.append(product)
                        } else {
                            print("   ⚠️ URL principal inválida, se omitirá el producto")
                        }
                    }
                    
                    print("✅ Total de productos válidos: \(validProducts.count)")
                    return validProducts
                } catch {
                    print("❌ Error al decodificar con estructura esperada: \(error)")
                    
                    // Intentar con estructura alternativa
                    do {
                        let decoder = JSONDecoder()
                        let alternativeResponse = try decoder.decode(AlternativeReachuResponse.self, from: data)
                        
                        if let products = alternativeResponse.extractProducts() {
                            print("✅ Decodificación alternativa exitosa, se encontraron \(products.count) productos")
                            
                            // Filtrar productos sin imágenes o con URLs inválidas
                            let validProducts = products.filter { product in
                                if product.images.isEmpty {
                                    print("⚠️ Producto \(product.id) no tiene imágenes, se omitirá")
                                    return false
                                }
                                
                                if product.mainImageURL == nil {
                                    print("⚠️ Producto \(product.id) tiene URL de imagen inválida, se omitirá")
                                    return false
                                }
                                
                                return true
                            }
                            
                            print("✅ Total de productos válidos: \(validProducts.count)")
                            return validProducts
                        } else {
                            print("❌ No se pudieron extraer productos de la estructura alternativa")
                            throw APIError.decodingError(error)
                        }
                    } catch {
                        print("❌ Error al decodificar con estructura alternativa: \(error)")
                        
                        // Intento manual de parseo
                        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            print("🔍 Intentando parseo manual del JSON")
                            return try self.parseProductsManually(json: json)
                        }
                        
                        throw APIError.decodingError(error)
                    }
                }
            }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.networkError(error)
            }
            .eraseToAnyPublisher()
    }
    
    private func parseProductsManually(json: [String: Any]) throws -> [ReachuProduct] {
        var products: [ReachuProduct] = []
        
        // Imprimimos las claves principales
        print("🔑 Claves principales en el JSON: \(json.keys.joined(separator: ", "))")
        
        // Intentamos diferentes rutas de acceso a los datos
        if let data = json["data"] as? [String: Any] {
            print("✅ Encontrada clave 'data'")
            
            // Ruta 1: data -> Channel -> GetProducts
            if let channel = data["Channel"] as? [String: Any],
               let getProducts = channel["GetProducts"] as? [[String: Any]] {
                print("✅ Ruta encontrada: data -> Channel -> GetProducts")
                
                for (index, productJson) in getProducts.enumerated() {
                    if let product = createProduct(from: productJson, index: index) {
                        products.append(product)
                    }
                }
            }
            // Ruta 2: data -> channel -> getProducts (minúsculas)
            else if let channel = data["channel"] as? [String: Any],
                    let getProducts = channel["getProducts"] as? [[String: Any]] {
                print("✅ Ruta encontrada: data -> channel -> getProducts")
                
                for (index, productJson) in getProducts.enumerated() {
                    if let product = createProduct(from: productJson, index: index) {
                        products.append(product)
                    }
                }
            }
            // Ruta 3: data -> products
            else if let productsArray = data["products"] as? [[String: Any]] {
                print("✅ Ruta encontrada: data -> products")
                
                for (index, productJson) in productsArray.enumerated() {
                    if let product = createProduct(from: productJson, index: index) {
                        products.append(product)
                    }
                }
            }
        }
        
        if products.isEmpty {
            throw APIError.decodingError(NSError(domain: "JSONParsingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se pudieron encontrar productos en el JSON"]))
        }
        
        print("✅ Parseo manual exitoso: \(products.count) productos")
        return products
    }
    
    private func createProduct(from json: [String: Any], index: Int) -> ReachuProduct? {
        print("🔍 Analizando producto \(index + 1): \(json)")
        
        // Manejar ID como Int o String
        var idString: String
        if let idInt = json["id"] as? Int {
            idString = String(idInt)
        } else if let idStr = json["id"] as? String {
            idString = idStr
        } else {
            print("❌ Falta ID o formato inválido en producto \(index + 1)")
            return nil
        }
        
        let title = json["title"] as? String ?? "Producto \(index + 1)"
        let description = json["description"] as? String
        
        // Procesar imágenes
        var images: [ReachuImage] = []
        if let imagesArray = json["images"] as? [[String: Any]] {
            for imageJson in imagesArray {
                if let url = imageJson["url"] as? String {
                    let order = imageJson["order"] as? Int ?? 0
                    
                    // Manejar ID de imagen como Int o String
                    var imageId: String? = nil
                    if let idInt = imageJson["id"] as? Int {
                        imageId = String(idInt)
                    } else if let idStr = imageJson["id"] as? String {
                        imageId = idStr
                    }
                    
                    images.append(ReachuImage(url: url, order: order, id: imageId))
                }
            }
        }
        
        // Si no hay imágenes, intentar con un campo image o imageUrl
        if images.isEmpty {
            if let imageUrl = json["image"] as? String ?? json["imageUrl"] as? String {
                images.append(ReachuImage(url: imageUrl, order: 0))
            }
        }
        
        // Procesar precio
        var price = ReachuPrice(currency_code: "USD", amount: "0.00")
        if let priceJson = json["price"] as? [String: Any] {
            let currencyCode = priceJson["currency_code"] as? String ?? "USD"
            
            // Manejar amount como Int, Double o String
            var amount = "0.00"
            if let amountInt = priceJson["amount"] as? Int {
                amount = String(amountInt)
            } else if let amountDouble = priceJson["amount"] as? Double {
                amount = String(format: "%.2f", amountDouble)
            } else if let amountStr = priceJson["amount"] as? String {
                amount = amountStr
            }
            
            // Manejar compare_at como Int, Double, String o nil
            var compareAt: String? = nil
            if let compareAtInt = priceJson["compare_at"] as? Int {
                compareAt = String(compareAtInt)
            } else if let compareAtDouble = priceJson["compare_at"] as? Double {
                compareAt = String(format: "%.2f", compareAtDouble)
            } else if let compareAtStr = priceJson["compare_at"] as? String, !compareAtStr.isEmpty {
                compareAt = compareAtStr
            }
            
            price = ReachuPrice(currency_code: currencyCode, amount: amount, compare_at: compareAt)
        } else if let priceValue = json["price"] as? Double {
            price = ReachuPrice(currency_code: "USD", amount: String(format: "%.2f", priceValue))
        }
        
        return ReachuProduct(
            id: idString,
            images: images,
            price: price,
            title: title,
            description: description
        )
    }
    
    private func performGraphQLRequest(query: String) -> AnyPublisher<Data, Error> {
        let url = endpointURL
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(authToken, forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = ["query": query]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("🚀 Enviando solicitud GraphQL a \(url)")
        print("🔑 Usando token: \(authToken)")
        print(" Query: \(query)")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ La respuesta no es HTTP")
                    throw APIError.invalidResponse
                }
                
                print("📡 Respuesta HTTP: \(httpResponse.statusCode)")
                
                if let headers = httpResponse.allHeaderFields as? [String: String] {
                    print("📋 Headers de respuesta:")
                    for (key, value) in headers {
                        print("   \(key): \(value)")
                    }
                }
                
                let preview = String(data: data.prefix(200), encoding: .utf8) ?? "No se pudo convertir"
                print("📄 Primeros 200 caracteres de la respuesta: \(preview)...")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    let errorMessage = "Servidor retornó código \(httpResponse.statusCode)"
                    print("❌ \(errorMessage)")
                    throw APIError.serverError(errorMessage)
                }
                
                return data
            }
            .mapError { error in
                print("❌ Error en la solicitud: \(error.localizedDescription)")
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.networkError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func fetchProductById(productId: Int) -> AnyPublisher<ReachuProduct, Error> {
        print("🔍 Iniciando solicitud GraphQL para obtener producto con ID: \(productId)")
        
        let query = """
        query GetProductsByIds {
          Channel {
            GetProductsByIds(product_ids: [\(productId)]) {
              id
              images {
                url
                order
              }
              supplier
              price {
                amount
                currency_code
                amount_incl_taxes
                tax_amount
                tax_rate
                compare_at
                compare_at_incl_taxes
              }
              title
              description
            }
          }
        }
        """
        
        return performGraphQLRequest(query: query)
            .tryMap { [self] data -> ReachuProduct in
                print("📦 Procesando respuesta GraphQL para producto ID: \(productId)")
                
                // Imprimir la respuesta completa
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📄 Respuesta JSON completa:\n\(jsonString)")
                }
                
                // Intentar obtener el producto
                do {
                    let decoder = JSONDecoder()
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    
                    if let dataObj = json?["data"] as? [String: Any],
                       let channel = dataObj["Channel"] as? [String: Any],
                       let products = channel["GetProductsByIds"] as? [[String: Any]],
                       let productJson = products.first {
                        
                        if let product = createProduct(from: productJson, index: 0) {
                            return product
                        }
                    }
                    
                    throw APIError.invalidResponse
                } catch {
                    print("❌ Error al decodificar producto: \(error)")
                    throw APIError.decodingError(error)
                }
            }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.networkError(error)
            }
            .eraseToAnyPublisher()
    }
} 