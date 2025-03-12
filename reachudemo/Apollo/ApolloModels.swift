import Foundation

// MARK: - Apollo Models
/// These models are specifically for use with Apollo GraphQL
/// They are separate from the existing Reachu models to avoid conflicts

// MARK: - Product Response
struct ApolloProductResponse: Decodable {
    let data: ApolloProductData
}

struct ApolloProductData: Decodable {
    let Channel: ApolloChannel
}

struct ApolloChannel: Decodable {
    let GetProducts: [ApolloProduct]
}

// MARK: - Product Model
struct ApolloProduct: Identifiable, Decodable {
    let id: String
    let title: String
    let description: String?
    let images: [ApolloImage]
    let price: ApolloPrice
    let category: String?
    let variants: [ApolloVariant]?
    let inventory: ApolloInventory?
    
    // Computed properties
    var mainImageURL: URL? {
        if let mainImage = images.first(where: { $0.order == 0 }) {
            return URL(string: mainImage.url)
        }
        return images.first.flatMap { URL(string: $0.url) }
    }
    
    var formattedPrice: String {
        return price.formattedPrice
    }
    
    // Custom decoder to handle different ID types
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle ID as either Int or String
        if let idInt = try? container.decode(Int.self, forKey: .id) {
            id = String(idInt)
        } else {
            id = try container.decode(String.self, forKey: .id)
        }
        
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        images = try container.decode([ApolloImage].self, forKey: .images)
        price = try container.decode(ApolloPrice.self, forKey: .price)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        variants = try container.decodeIfPresent([ApolloVariant].self, forKey: .variants)
        inventory = try container.decodeIfPresent(ApolloInventory.self, forKey: .inventory)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, images, price, category, variants, inventory
    }
}

// MARK: - Image Model
struct ApolloImage: Decodable {
    let url: String
    let order: Int
    let id: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        url = try container.decode(String.self, forKey: .url)
        order = try container.decode(Int.self, forKey: .order)
        
        // Handle ID as either Int or String
        if let idInt = try? container.decode(Int.self, forKey: .id) {
            id = String(idInt)
        } else {
            id = try? container.decode(String.self, forKey: .id)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case url, order, id
    }
}

// MARK: - Price Model
struct ApolloPrice: Decodable {
    let currency_code: String
    let amount: String
    let compare_at: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        currency_code = try container.decode(String.self, forKey: .currency_code)
        
        // Handle amount as either Int or String
        if let amountInt = try? container.decode(Int.self, forKey: .amount) {
            amount = String(amountInt)
        } else {
            amount = try container.decode(String.self, forKey: .amount)
        }
        
        // Handle compare_at as either Int, String, or nil
        if let compareAtInt = try? container.decode(Int.self, forKey: .compare_at) {
            compare_at = String(compareAtInt)
        } else {
            compare_at = try? container.decode(String.self, forKey: .compare_at)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case currency_code, amount, compare_at
    }
    
    var formattedPrice: String {
        if let amountDouble = Double(amount) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currency_code
            formatter.maximumFractionDigits = 0
            
            if let formattedAmount = formatter.string(from: NSNumber(value: amountDouble)) {
                return formattedAmount
            }
        }
        
        return "\(currency_code) \(amount)"
    }
    
    var hasDiscount: Bool {
        guard let compareAtStr = compare_at, !compareAtStr.isEmpty else { return false }
        
        if let compareDouble = Double(compareAtStr), let amountDouble = Double(amount) {
            return compareDouble > amountDouble
        }
        
        return false
    }
}

// MARK: - Variant Model
struct ApolloVariant: Identifiable, Decodable {
    let id: String
    let title: String
    let options: [ApolloOption]?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle ID as either Int or String
        if let idInt = try? container.decode(Int.self, forKey: .id) {
            id = String(idInt)
        } else {
            id = try container.decode(String.self, forKey: .id)
        }
        
        title = try container.decode(String.self, forKey: .title)
        options = try container.decodeIfPresent([ApolloOption].self, forKey: .options)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, options
    }
}

// MARK: - Option Model
struct ApolloOption: Decodable {
    let name: String
    let value: String
}

// MARK: - Inventory Model
struct ApolloInventory: Decodable {
    let available: Int?
    let in_stock: Bool?
} 