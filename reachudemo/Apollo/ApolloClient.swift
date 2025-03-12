import Foundation
import Apollo
import ApolloAPI
import ReachuAPI

/// Cliente Apollo para realizar consultas GraphQL
class ApolloClient {
    // MARK: - Singleton
    
    /// Instancia compartida del cliente Apollo
    static let shared = ApolloClient()
    
    // MARK: - Propiedades
    
    /// Cliente Apollo para realizar consultas GraphQL
    private let apollo: Apollo.ApolloClient
    
    // MARK: - Inicialización
    
    /// Inicializa el cliente Apollo con la URL del servidor GraphQL
    private init() {
        // Crear la URL del servidor GraphQL
        let url = URL(string: "https://graph-ql.reachu.io/")!
        
        // Crear el cliente Apollo
        apollo = Apollo.ApolloClient(url: url, configuration: .init(
            headers: ["Authorization": "ZN7EYWW-ZVX4PD9-Q74031G-MXTHK3R"]
        ))
        
        print("ApolloClient inicializado con éxito")
    }
    
    // MARK: - Métodos
    
    /// Obtiene una lista de productos
    /// - Parameter completion: Closure que se ejecuta cuando se completa la consulta
    func fetchProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        apollo.fetch(query: GetProductsQuery()) { result in
            switch result {
            case .success(let graphQLResult):
                if let products = graphQLResult.data?.channel?.getProducts {
                    let mappedProducts = products.compactMap { self.mapToProduct($0) }
                    completion(.success(mappedProducts))
                } else if let errors = graphQLResult.errors {
                    let error = NSError(
                        domain: "ApolloClient",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: errors.first?.localizedDescription ?? "Error desconocido"]
                    )
                    completion(.failure(error))
                } else {
                    completion(.success([]))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Obtiene un producto por su ID
    /// - Parameters:
    ///   - id: ID del producto
    ///   - completion: Closure que se ejecuta cuando se completa la consulta
    func fetchProduct(id: Int, completion: @escaping (Result<Product?, Error>) -> Void) {
        apollo.fetch(query: GetProductDetailQuery(productId: id)) { result in
            switch result {
            case .success(let graphQLResult):
                if let products = graphQLResult.data?.channel?.products, let product = products.first {
                    let mappedProduct = self.mapToProduct(product)
                    completion(.success(mappedProduct))
                } else if let errors = graphQLResult.errors {
                    let error = NSError(
                        domain: "ApolloClient",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: errors.first?.localizedDescription ?? "Error desconocido"]
                    )
                    completion(.failure(error))
                } else {
                    completion(.success(nil))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Busca productos por término de búsqueda
    /// - Parameters:
    ///   - query: Término de búsqueda
    ///   - completion: Closure que se ejecuta cuando se completa la consulta
    func searchProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        apollo.fetch(query: SearchProductsQuery()) { result in
            switch result {
            case .success(let graphQLResult):
                if let products = graphQLResult.data?.channel?.getProducts {
                    let mappedProducts = products.compactMap { self.mapToProduct($0) }
                    completion(.success(mappedProducts))
                } else if let errors = graphQLResult.errors {
                    let error = NSError(
                        domain: "ApolloClient",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: errors.first?.localizedDescription ?? "Error desconocido"]
                    )
                    completion(.failure(error))
                } else {
                    completion(.success([]))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Métodos privados
    
    /// Mapea un producto de GraphQL a un modelo de dominio
    /// - Parameter graphQLProduct: Producto de GraphQL
    /// - Returns: Producto de dominio
    private func mapToProduct(_ graphQLProduct: GetProductsQuery.Data.Channel.GetProduct?) -> Product? {
        guard let graphQLProduct = graphQLProduct else { return nil }
        
        // Mapear imágenes
        let images = graphQLProduct.images?.compactMap { image -> ProductImage? in
            guard let url = image?.url else { return nil }
            return ProductImage(
                id: image?.id ?? "",
                url: url,
                order: image?.order ?? 0
            )
        } ?? []
        
        // Mapear precio
        let price = graphQLProduct.price.map { price -> ProductPrice in
            ProductPrice(
                currencyCode: price.currency_code ?? "USD",
                amount: price.amount ?? 0,
                compareAt: price.compare_at
            )
        }
        
        // Mapear categorías
        let categories = graphQLProduct.categories?.compactMap { category -> ProductCategory? in
            guard let id = category?.id, let name = category?.name else { return nil }
            return ProductCategory(id: id, name: name)
        } ?? []
        
        // Mapear variantes
        let variants = graphQLProduct.variants?.compactMap { variant -> ProductVariant? in
            guard let id = variant?.id, let title = variant?.title else { return nil }
            return ProductVariant(id: id, title: title, options: [])
        } ?? []
        
        // Crear producto
        return Product(
            id: graphQLProduct.id ?? "",
            title: graphQLProduct.title ?? "",
            description: graphQLProduct.description ?? "",
            images: images,
            price: price,
            categories: categories,
            variants: variants,
            inventory: ProductInventory(available: 0, inStock: true)
        )
    }
    
    /// Mapea un producto de GraphQL a un modelo de dominio
    /// - Parameter graphQLProduct: Producto de GraphQL
    /// - Returns: Producto de dominio
    private func mapToProduct(_ graphQLProduct: GetProductDetailQuery.Data.Channel.Product?) -> Product? {
        guard let graphQLProduct = graphQLProduct else { return nil }
        
        // Mapear imágenes
        let images = graphQLProduct.images?.compactMap { image -> ProductImage? in
            guard let url = image?.url else { return nil }
            return ProductImage(
                id: image?.id ?? "",
                url: url,
                order: image?.order ?? 0
            )
        } ?? []
        
        // Mapear precio
        let price = graphQLProduct.price.map { price -> ProductPrice in
            ProductPrice(
                currencyCode: price.currency_code ?? "USD",
                amount: price.amount ?? 0,
                compareAt: price.compare_at
            )
        }
        
        // Mapear categorías
        let categories = graphQLProduct.categories?.compactMap { category -> ProductCategory? in
            guard let id = category?.id, let name = category?.name else { return nil }
            return ProductCategory(id: id, name: name)
        } ?? []
        
        // Mapear variantes
        let variants = graphQLProduct.variants?.compactMap { variant -> ProductVariant? in
            guard let id = variant?.id, let title = variant?.title else { return nil }
            return ProductVariant(id: id, title: title, options: [])
        } ?? []
        
        // Crear producto
        return Product(
            id: graphQLProduct.id ?? "",
            title: graphQLProduct.title ?? "",
            description: graphQLProduct.description ?? "",
            images: images,
            price: price,
            categories: categories,
            variants: variants,
            inventory: ProductInventory(available: 0, inStock: true)
        )
    }
    
    /// Mapea un producto de GraphQL a un modelo de dominio
    /// - Parameter graphQLProduct: Producto de GraphQL
    /// - Returns: Producto de dominio
    private func mapToProduct(_ graphQLProduct: SearchProductsQuery.Data.Channel.GetProduct?) -> Product? {
        guard let graphQLProduct = graphQLProduct else { return nil }
        
        // Mapear imágenes
        let images = graphQLProduct.images?.compactMap { image -> ProductImage? in
            guard let url = image?.url else { return nil }
            return ProductImage(
                id: image?.id ?? "",
                url: url,
                order: image?.order ?? 0
            )
        } ?? []
        
        // Mapear precio
        let price = graphQLProduct.price.map { price -> ProductPrice in
            ProductPrice(
                currencyCode: price.currency_code ?? "USD",
                amount: price.amount ?? 0,
                compareAt: price.compare_at
            )
        }
        
        // Crear producto
        return Product(
            id: graphQLProduct.id ?? "",
            title: graphQLProduct.title ?? "",
            description: graphQLProduct.description ?? "",
            images: images,
            price: price,
            categories: [],
            variants: [],
            inventory: ProductInventory(available: 0, inStock: true)
        )
    }
}

// MARK: - Modelos de dominio

/// Modelo de producto
struct Product {
    let id: String
    let title: String
    let description: String
    let images: [ProductImage]
    let price: ProductPrice?
    let categories: [ProductCategory]
    let variants: [ProductVariant]
    let inventory: ProductInventory
    
    /// URL de la imagen principal
    var mainImageURL: URL? {
        guard let mainImage = images.sorted(by: { $0.order < $1.order }).first else { return nil }
        return URL(string: mainImage.url)
    }
    
    /// Precio formateado
    var formattedPrice: String {
        guard let price = price else { return "N/A" }
        return price.formatted
    }
}

/// Modelo de imagen de producto
struct ProductImage {
    let id: String
    let url: String
    let order: Int
}

/// Modelo de precio de producto
struct ProductPrice {
    let currencyCode: String
    let amount: Double
    let compareAt: Double?
    
    /// Precio formateado
    var formatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        
        guard let formattedAmount = formatter.string(from: NSNumber(value: amount)) else {
            return "\(currencyCode) \(amount)"
        }
        
        return formattedAmount
    }
    
    /// Indica si el producto tiene descuento
    var hasDiscount: Bool {
        guard let compareAt = compareAt else { return false }
        return compareAt > amount
    }
    
    /// Porcentaje de descuento
    var discountPercentage: Int? {
        guard hasDiscount, let compareAt = compareAt, compareAt > 0 else { return nil }
        return Int(((compareAt - amount) / compareAt) * 100)
    }
}

/// Modelo de categoría de producto
struct ProductCategory {
    let id: String
    let name: String
}

/// Modelo de variante de producto
struct ProductVariant {
    let id: String
    let title: String
    let options: [ProductOption]
}

/// Modelo de opción de variante de producto
struct ProductOption {
    let name: String
    let value: String
}

/// Modelo de inventario de producto
struct ProductInventory {
    let available: Int
    let inStock: Bool
} 