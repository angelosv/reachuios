import Foundation

struct Article: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let content: String
    let imageName: String
    let readTime: String
    let commentCount: Int
    let category: Category
    let isFeatured: Bool
    let isTrending: Bool
    let publishDate: Date
    
    var formattedCommentCount: String {
        commentCount > 0 ? "\(commentCount)" : ""
    }
}

enum Category: String, CaseIterable, Identifiable {
    case diet = "Diet"
    case diabeticLifestyle = "Diabetic Lifestyle"
    case dailyNutrition = "Daily Nutrition"
    case general = "General"
    
    var id: String { self.rawValue }
    
    var imageName: String {
        switch self {
        case .diet:
            return "diet_image"
        case .diabeticLifestyle:
            return "diabetic_lifestyle"
        case .dailyNutrition:
            return "daily_nutrition"
        case .general:
            return "general_health"
        }
    }
}

// Sample Data
extension Article {
    static let sampleFeaturedArticles: [Article] = [
        Article(
            title: "How to make your cooking fun?",
            subtitle: "Get tips from the master.",
            content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            imageName: "cooking_fun",
            readTime: "7 mins reading",
            commentCount: 2,
            category: .general,
            isFeatured: true,
            isTrending: false,
            publishDate: Date().addingTimeInterval(-86400)
        ),
        Article(
            title: "How to make your cooking fun?",
            subtitle: "Get tips from the master.",
            content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            imageName: "cooking_ingredients",
            readTime: "7 mins reading",
            commentCount: 2,
            category: .general,
            isFeatured: true,
            isTrending: false,
            publishDate: Date().addingTimeInterval(-86400 * 2)
        )
    ]
    
    static let sampleTrendingArticles: [Article] = [
        Article(
            title: "Diabetes Mellitus in Young Age: Causes and Characteristics",
            subtitle: nil,
            content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            imageName: "diabetes_young",
            readTime: "5 mins read",
            commentCount: 2,
            category: .diabeticLifestyle,
            isFeatured: false,
            isTrending: true,
            publishDate: Date().addingTimeInterval(-86400 * 3)
        ),
        Article(
            title: "Diabetes Mellitus in Young Age: Causes and Characteristics",
            subtitle: nil,
            content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            imageName: "diabetes_consultation",
            readTime: "5 mins read",
            commentCount: 0,
            category: .diabeticLifestyle,
            isFeatured: false,
            isTrending: true,
            publishDate: Date().addingTimeInterval(-86400 * 4)
        ),
        Article(
            title: "Diabetes - Symptoms, causes and treatment",
            subtitle: nil,
            content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            imageName: "diabetes_family",
            readTime: "5 mins read",
            commentCount: 0,
            category: .diabeticLifestyle,
            isFeatured: false,
            isTrending: true,
            publishDate: Date().addingTimeInterval(-86400 * 5)
        )
    ]
    
    static let sampleArticles: [Article] = sampleFeaturedArticles + sampleTrendingArticles
} 