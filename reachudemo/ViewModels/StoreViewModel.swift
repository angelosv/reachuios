import Foundation
import Combine

class StoreViewModel: ObservableObject {
    @Published var reachuProducts: [ReachuProduct] = []
    @Published var categories: [ProductCategory] = ProductCategory.allCases
    @Published var selectedCategory: ProductCategory?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var cartItemCount: Int = 0
    
    private let graphQLService = ReachuGraphQLService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Cargar productos de Reachu al inicializar
        fetchProducts()
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
                }
            }, receiveValue: { [weak self] reachuProducts in
                guard let self = self else { return }
                
                print("✅ Successfully loaded \(reachuProducts.count) products from Reachu API")
                self.reachuProducts = reachuProducts
            })
            .store(in: &cancellables)
    }
    
    func filterByCategory(_ category: ProductCategory?) {
        self.selectedCategory = category
        // Implementar filtrado por categoría para productos de Reachu si es necesario
    }
    
    func addReachuProductToCart(_ product: ReachuProduct) {
        // In a real app, this would add the Reachu product to cart
        cartItemCount += 1
    }
} 