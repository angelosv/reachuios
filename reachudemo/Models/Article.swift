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
            title: "Hvorfor er Omega-3 viktig under graviditet og for babyens helse?",
            subtitle: nil,
            content: "Omega-3-fettsyrer spiller en avgjørende rolle i både mors og babyens helse under graviditeten. Disse essensielle fettsyrene, spesielt DHA (dokosaheksaensyre), er viktige for utviklingen av babyens hjerne, øyne og nervesystem.\n\nFordeler med Omega-3 under graviditet:\n• Hjerneutvikling – DHA er en viktig byggestein i hjernen og bidrar til kognitiv utvikling hos fosteret.\n• Øyehelse – Omega-3 støtter utviklingen av netthinnen, som er avgjørende for god synsfunksjon.\n• Redusert risiko for tidlig fødsel – Studier antyder at tilstrekkelig inntak av Omega-3 kan bidra til å redusere risikoen for for tidlig fødsel.\n• Støtter mors helse – Omega-3 kan bidra til å redusere betennelser, støtte hjertehelsen og redusere risikoen for fødselsdepresjon.\n\nHvorfor er Omega-3 viktig for babyen etter fødselen?\nEtter fødselen fortsetter Omega-3 å spille en viktig rolle. Babyer som får tilstrekkelig DHA gjennom morsmelk eller morsmelkerstatning, kan oppleve fordeler som bedre kognitiv utvikling, sterkere immunforsvar og sunn vekst.\n\nHvordan få nok Omega-3?\nOmega-3 finnes naturlig i fet fisk som laks, makrell og sild. For gravide som ikke spiser nok fisk, kan Omega-3-tilskudd være et godt alternativ. Det er viktig å velge høykvalitets tilskudd som er trygge for både mor og baby.\n\nÅ sikre et godt inntak av Omega-3 under graviditet og amming kan gi babyen en sunn start på livet. Snakk gjerne med en helsepersonell for å finne den beste løsningen for deg!",
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