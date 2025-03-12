import Foundation
import Combine

// MARK: - Apollo ViewModel
/// This ViewModel is specifically for use with Apollo GraphQL
/// It is separate from the existing Reachu ViewModels to avoid conflicts
class ApolloViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var products: [ApolloProduct] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var hasMoreProducts: Bool = true
    @Published var isRefreshing: Bool = false
    
    // MARK: - Private Properties
    private let apolloManager = ApolloManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var currentOffset = 0
    private let productsPerPage = 20
    private var currentCategory: String?
    
    // MARK: - Initialization
    init() {
        print("🚀 Apollo ViewModel initialized")
    }
    
    // MARK: - Public Methods
    /// Fetches products using Apollo GraphQL with cache support
    func fetchProducts(
        category: String? = nil,
        resetResults: Bool = true,
        cachePolicy: ApolloManager.CachePolicy = .returnCacheDataElseFetch
    ) {
        if resetResults {
            if !isRefreshing {
                isLoading = true
            }
            currentOffset = 0
            hasMoreProducts = true
            products = []
            errorMessage = nil
            currentCategory = category
        }
        
        let query = """
        query GetProducts($limit: Int!, $offset: Int!, $category: String) {
          Channel {
            GetProducts(limit: $limit, offset: $offset, category: $category) {
              id
              images {
                url
                order
                id
              }
              price {
                currency_code
                amount
                compare_at
              }
              title
              description
              category
              variants {
                id
                title
                options {
                  name
                  value
                }
              }
              inventory {
                available
                in_stock
              }
            }
          }
        }
        """
        
        var variables: [String: Any] = [
            "limit": productsPerPage,
            "offset": currentOffset
        ]
        
        if let category = currentCategory {
            variables["category"] = category
        }
        
        apolloManager.performQuery(
            query: query,
            variables: variables,
            decodingType: ApolloProductResponse.self,
            cachePolicy: cachePolicy
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] completion in
            guard let self = self else { return }
            
            self.isLoading = false
            self.isRefreshing = false
            
            switch completion {
            case .finished:
                break
            case .failure(let error):
                print("❌ Apollo ViewModel error: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
            }
        }, receiveValue: { [weak self] response in
            guard let self = self else { return }
            
            let newProducts = response.data.Channel.GetProducts
            print("✅ Apollo ViewModel received \(newProducts.count) products")
            
            // Update hasMoreProducts flag
            self.hasMoreProducts = newProducts.count >= self.productsPerPage
            
            // Update currentOffset for pagination
            self.currentOffset += newProducts.count
            
            // Update products list
            if resetResults {
                self.products = newProducts
            } else {
                // Append new products, avoiding duplicates
                let existingIds = Set(self.products.map { $0.id })
                let uniqueNewProducts = newProducts.filter { !existingIds.contains($0.id) }
                self.products.append(contentsOf: uniqueNewProducts)
            }
        })
        .store(in: &cancellables)
    }
    
    /// Loads more products with cache support
    func loadMoreProducts() {
        guard !isLoading, hasMoreProducts else { return }
        fetchProducts(category: currentCategory, resetResults: false)
    }
    
    /// Refreshes products by forcing a network fetch
    func refreshProducts() {
        isRefreshing = true
        fetchProducts(
            category: currentCategory,
            resetResults: true,
            cachePolicy: .fetchIgnoringCache
        )
    }
    
    /// Fetches products by category with cache support
    func fetchProductsByCategory(_ category: String) {
        fetchProducts(category: category, resetResults: true)
    }
    
    /// Clears the cache for products
    func clearProductsCache() {
        apolloManager.clearCache()
        refreshProducts()
    }
    
    // MARK: - Cleanup
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
} 