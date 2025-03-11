import Foundation

struct Product: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let price: Double
    let imageName: String
    let category: ProductCategory
    let rating: Double
    let reviewCount: Int
    let isAvailable: Bool
    let isFeatured: Bool
    
    var formattedPrice: String {
        return String(format: "$%.2f", price)
    }
}

enum ProductCategory: String, CaseIterable, Identifiable {
    case glucometers = "Glucometers"
    case supplements = "Supplements"
    case diabeticFood = "Diabetic Food"
    case accessories = "Accessories"
    case books = "Books"
    
    var id: String { self.rawValue }
    
    var imageName: String {
        switch self {
        case .glucometers:
            return "glucometer_category"
        case .supplements:
            return "supplements_category"
        case .diabeticFood:
            return "diabetic_food_category"
        case .accessories:
            return "accessories_category"
        case .books:
            return "books_category"
        }
    }
}

// Sample Data
extension Product {
    static let sampleFeaturedProducts: [Product] = [
        Product(
            name: "Smart Glucometer Pro",
            description: "Advanced blood glucose monitoring system with smartphone connectivity",
            price: 79.99,
            imageName: "glucometer_pro",
            category: .glucometers,
            rating: 4.8,
            reviewCount: 156,
            isAvailable: true,
            isFeatured: true
        ),
        Product(
            name: "Diabetic Superfood Mix",
            description: "Nutrient-rich superfood blend specifically formulated for diabetics",
            price: 34.99,
            imageName: "superfood_mix",
            category: .diabeticFood,
            rating: 4.6,
            reviewCount: 89,
            isAvailable: true,
            isFeatured: true
        )
    ]
    
    static let sampleProducts: [Product] = [
        Product(
            name: "Glucose Control Supplement",
            description: "Natural supplement to help maintain healthy blood sugar levels",
            price: 29.99,
            imageName: "glucose_supplement",
            category: .supplements,
            rating: 4.5,
            reviewCount: 42,
            isAvailable: true,
            isFeatured: false
        ),
        Product(
            name: "Diabetic Cookbook 2024",
            description: "200+ delicious recipes for a healthy diabetic lifestyle",
            price: 24.99,
            imageName: "diabetic_cookbook",
            category: .books,
            rating: 4.7,
            reviewCount: 128,
            isAvailable: true,
            isFeatured: false
        ),
        Product(
            name: "Insulin Cooling Case",
            description: "Portable cooling case for insulin storage",
            price: 45.99,
            imageName: "cooling_case",
            category: .accessories,
            rating: 4.9,
            reviewCount: 75,
            isAvailable: true,
            isFeatured: false
        )
    ]
} 