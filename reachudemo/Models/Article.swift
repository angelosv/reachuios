import Foundation

struct Article: Identifiable {
    let id: String
    let title: String
    let subtitle: String?
    let content: String
    let imageName: String
    let imageURL: URL?
    let readTime: String
    let commentCount: Int
    let category: String
    let isFeatured: Bool
    let isTrending: Bool
    let publishDate: Date
    
    var formattedCommentCount: String {
        commentCount > 0 ? "\(commentCount)" : ""
    }
    
    init(id: String = UUID().uuidString, 
         title: String, 
         subtitle: String? = nil, 
         content: String, 
         imageName: String = "",
         imageURL: URL? = nil,
         readTime: String = "5 mins read", 
         commentCount: Int = 0, 
         category: String,
         isFeatured: Bool = false, 
         isTrending: Bool = false, 
         publishDate: Date = Date()) {
        
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.content = content
        self.imageName = imageName
        self.imageURL = imageURL
        self.readTime = readTime
        self.commentCount = commentCount
        self.category = category
        self.isFeatured = isFeatured
        self.isTrending = isTrending
        self.publishDate = publishDate
    }
}

// Categories as constants
struct Categories {
    static let diet = "Diet"
    static let diabeticLifestyle = "Diabetic Lifestyle"
    static let dailyNutrition = "Daily Nutrition"
    static let general = "General"
    static let health = "Health"
    
    static let all = [diet, diabeticLifestyle, dailyNutrition, general, health]
    
    static func imageName(for category: String) -> String {
        switch category {
        case diet:
            return "diet_image"
        case diabeticLifestyle:
            return "diabetic_lifestyle"
        case dailyNutrition:
            return "daily_nutrition"
        case health:
            return "health_category"
        case general:
            return "general_health"
        default:
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
            imageURL: URL(string: "https://picsum.photos/800/600?random=1"),
            readTime: "7 mins reading",
            commentCount: 2,
            category: Categories.general,
            isFeatured: true,
            isTrending: false,
            publishDate: Date().addingTimeInterval(-86400)
        ),
        Article(
            title: "How to make your cooking fun?",
            subtitle: "Get tips from the master.",
            content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            imageName: "cooking_ingredients",
            imageURL: URL(string: "https://picsum.photos/800/600?random=2"),
            readTime: "7 mins reading",
            commentCount: 2,
            category: Categories.general,
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
            imageURL: URL(string: "https://picsum.photos/800/600?random=3"),
            readTime: "5 mins read",
            commentCount: 2,
            category: Categories.health,
            isFeatured: false,
            isTrending: true,
            publishDate: Date().addingTimeInterval(-86400 * 3)
        ),
        Article(
            title: "Diabetes Mellitus in Young Age: Causes and Characteristics",
            subtitle: nil,
            content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            imageName: "diabetes_consultation",
            imageURL: URL(string: "https://picsum.photos/800/600?random=4"),
            readTime: "5 mins read",
            commentCount: 0,
            category: Categories.diabeticLifestyle,
            isFeatured: false,
            isTrending: true,
            publishDate: Date().addingTimeInterval(-86400 * 4)
        ),
        Article(
            title: "Diabetes - Symptoms, causes and treatment",
            subtitle: nil,
            content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            imageName: "diabetes_family",
            imageURL: URL(string: "https://picsum.photos/800/600?random=5"),
            readTime: "5 mins read",
            commentCount: 0,
            category: Categories.diabeticLifestyle,
            isFeatured: false,
            isTrending: true,
            publishDate: Date().addingTimeInterval(-86400 * 5)
        )
    ]
    
    static let sampleArticles: [Article] = sampleFeaturedArticles + sampleTrendingArticles
} 