import Foundation
import Combine

class StoreViewModel: ObservableObject {
    @Published var reachuProducts: [ReachuProduct] = []
    @Published var categories: [ProductCategory] = ProductCategory.allCases
    @Published var selectedCategory: ProductCategory?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var cartItems: [CartItem] = []
    
    // Computed property for cartItemCount
    var cartItemCount: Int {
        return cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    // Computed property to get the total of selected items
    var selectedItemsTotal: Double {
        return cartItems.filter { $0.isSelected }.reduce(0) { $0 + $1.subtotal }
    }
    
    // Computed property for formatted total
    var formattedSelectedItemsTotal: String {
        if let currencyCode = cartItems.first?.product.price.currency_code {
            return "\(currencyCode)\(Int(selectedItemsTotal))"
        }
        return "Rp0"
    }
    
    // Computed property to count how many items are selected
    var selectedItemsCount: Int {
        return cartItems.filter { $0.isSelected }.count
    }
    
    private let graphQLService = ReachuGraphQLService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load Reachu products on initialization
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
        // Implement category filtering for Reachu products if needed
    }
    
    // Methods for handling the cart
    func addReachuProductToCart(_ product: ReachuProduct, size: String? = nil, color: String? = nil, quantity: Int = 1) {
        // Check if the product is already in the cart
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id && $0.size == size && $0.color == color }) {
            cartItems[index].quantity += quantity
        } else {
            let newItem = CartItem(product: product, quantity: quantity, size: size, color: color)
            cartItems.append(newItem)
        }
        
        print("✅ Added to cart: \(product.title), Size: \(size ?? "N/A"), Color: \(color ?? "N/A"), Quantity: \(quantity)")
    }
    
    func updateCartItemQuantity(itemId: UUID, newQuantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.id == itemId }) {
            if newQuantity > 0 {
                cartItems[index].quantity = newQuantity
            } else {
                // If quantity is 0 or negative, remove the item
                removeCartItem(itemId: itemId)
            }
        }
    }
    
    func toggleCartItemSelection(itemId: UUID) {
        if let index = cartItems.firstIndex(where: { $0.id == itemId }) {
            cartItems[index].isSelected.toggle()
        }
    }
    
    func removeCartItem(itemId: UUID) {
        cartItems.removeAll(where: { $0.id == itemId })
    }
    
    func clearCart() {
        cartItems.removeAll()
    }
} 