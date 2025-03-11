import Foundation
import Combine

class ArticleViewModel: ObservableObject {
    @Published var featuredArticles: [Article] = []
    @Published var trendingArticles: [Article] = []
    @Published var allArticles: [Article] = []
    @Published var categories: [Category] = Category.allCases
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
    
    func fetchArticlesByCategory(_ category: Category) {
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
} 