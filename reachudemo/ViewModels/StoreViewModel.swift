import Foundation
import Combine

class StoreViewModel: ObservableObject {
    @Published var featuredProducts: [Product] = []
    @Published var products: [Product] = []
    @Published var categories: [ProductCategory] = ProductCategory.allCases
    @Published var selectedCategory: ProductCategory?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var cartItemCount: Int = 0
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        self.featuredProducts = Product.sampleFeaturedProducts
        self.products = Product.sampleProducts
    }
    
    func fetchProducts() {
        isLoading = true
        errorMessage = nil
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.loadSampleData()
            self.isLoading = false
        }
    }
    
    func filterByCategory(_ category: ProductCategory?) {
        self.selectedCategory = category
        if let category = category {
            self.products = Product.sampleProducts.filter { $0.category == category }
        } else {
            self.products = Product.sampleProducts
        }
    }
    
    func addToCart(_ product: Product) {
        // In a real app, this would manage a cart
        cartItemCount += 1
    }
} 