import Foundation
import Combine

class ArticleViewModel: ObservableObject {
    @Published var featuredArticles: [Article] = []
    @Published var trendingArticles: [Article] = []
    @Published var allArticles: [Article] = []
    @Published var categories: [String] = Categories.all
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init() {
        // Load sample data for now
        loadSampleData()
    }
    
    func loadSampleData() {
        self.featuredArticles = Article.sampleFeaturedArticles
        self.trendingArticles = Article.sampleTrendingArticles
        self.allArticles = Article.sampleArticles
    }
    
    // MARK: - API Methods
    
    func fetchArticles() {
        isLoading = true
        errorMessage = nil
        
        // This would be replaced with actual API calls using Reachu.io GraphQL
        // For now, we'll simulate a network request with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // Simulate successful data fetch
            self.loadSampleData()
            self.isLoading = false
        }
    }
    
    func fetchArticlesByCategory(_ category: String) {
        isLoading = true
        errorMessage = nil
        
        // This would be replaced with actual API calls
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // Filter sample data by category
            let filtered = Article.sampleArticles.filter { $0.category == category }
            self.allArticles = filtered
            self.isLoading = false
        }
    }
    
    func searchArticles(query: String) {
        guard !query.isEmpty else {
            self.allArticles = Article.sampleArticles
            return
        }
        
        isLoading = true
        
        // This would be replaced with actual API calls
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Filter sample data by search query
            let filtered = Article.sampleArticles.filter { 
                $0.title.lowercased().contains(query.lowercased()) ||
                ($0.subtitle?.lowercased().contains(query.lowercased()) ?? false) ||
                $0.content.lowercased().contains(query.lowercased())
            }
            
            self.allArticles = filtered
            self.isLoading = false
        }
    }
    
    // Gets a sample article for display in Article Detail View
    func getSampleArticle() -> Article {
        return Article(
            id: "omega3-article",
            title: "Hvorfor er Omega-3 viktig under graviditet og for babyens helse?",
            content: "Omega-3-fettsyrer spiller en avgjørende rolle i både mors og babyens helse under graviditeten. Disse essensielle fettsyrene, spesielt DHA (dokosaheksaensyre), er viktige for utviklingen av babyens hjerne, øyne og nervesystem.\n\nFordeler med Omega-3 under graviditet:\n• Hjerneutvikling – DHA er en viktig byggestein i hjernen og bidrar til kognitiv utvikling hos fosteret.\n• Øyehelse – Omega-3 støtter utviklingen av netthinnen, som er avgjørende for god synsfunksjon.\n• Redusert risiko for tidlig fødsel – Studier antyder at tilstrekkelig inntak av Omega-3 kan bidra til å redusere risikoen for for tidlig fødsel.\n• Støtter mors helse – Omega-3 kan bidra til å redusere betennelser, støtte hjertehelsen og redusere risikoen for fødselsdepresjon.\n\nHvorfor er Omega-3 viktig for babyen etter fødselen?\nEtter fødselen fortsetter Omega-3 å spille en viktig rolle. Babyer som får tilstrekkelig DHA gjennom morsmelk eller morsmelkerstatning, kan oppleve fordeler som bedre kognitiv utvikling, sterkere immunforsvar og sunn vekst.\n\nHvordan få nok Omega-3?\nOmega-3 finnes naturlig i fet fisk som laks, makrell og sild. For gravide som ikke spiser nok fisk, kan Omega-3-tilskudd være et godt alternativ. Det er viktig å velge høykvalitets tilskudd som er trygge for både mor og baby.\n\nÅ sikre et godt inntak av Omega-3 under graviditet og amming kan gi babyen en sunn start på livet. Snakk gjerne med en helsepersonell for å finne den beste løsningen for deg!",
            imageURL: URL(string: "https://picsum.photos/800/600?random=10"),
            category: Categories.health
        )
    }
} 