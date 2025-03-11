import Foundation
import Combine

class StoreViewModel: ObservableObject {
    @Published var featuredProducts: [Product] = []
    @Published var products: [Product] = []
    @Published var reachuProducts: [ReachuProduct] = []
    @Published var categories: [ProductCategory] = ProductCategory.allCases
    @Published var selectedCategory: ProductCategory?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var cartItemCount: Int = 0
    
    private let graphQLService = ReachuGraphQLService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Cargamos datos de muestra como fallback inicial
        loadSampleData()
    }
    
    private func loadSampleData() {
        self.featuredProducts = Product.sampleFeaturedProducts
        self.products = Product.sampleProducts
    }
    
    func fetchProducts() {
        isLoading = true
        errorMessage = nil
        
        // Fetch real products from Reachu GraphQL
        graphQLService.fetchProducts()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                switch completion {
                case .finished:
                    // Completed successfully
                    break
                case .failure(let error):
                    print("❌ Error fetching products: \(error.localizedDescription)")
                    self.errorMessage = "Failed to load products: \(error.localizedDescription)"
                    
                    // Use sample data as fallback
                    self.loadSampleData()
                }
            }, receiveValue: { [weak self] reachuProducts in
                guard let self = self else { return }
                
                print("✅ Successfully loaded \(reachuProducts.count) products from Reachu API")
                self.reachuProducts = reachuProducts
                
                // Si no hay productos, usar los de muestra como fallback
                if reachuProducts.isEmpty {
                    self.loadSampleData()
                }
            })
            .store(in: &cancellables)
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
    
    func addReachuProductToCart(_ product: ReachuProduct) {
        // In a real app, this would add the Reachu product to cart
        cartItemCount += 1
    }
} 