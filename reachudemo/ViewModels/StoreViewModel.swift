import Foundation
import Combine

class StoreViewModel: ObservableObject {
    @Published var reachuProducts: [ReachuProduct] = []
    @Published var categories: [ProductCategory] = ProductCategory.allCases
    @Published var selectedCategory: ProductCategory?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var cartItems: [CartItem] = []
    
    // Computed property para cartItemCount
    var cartItemCount: Int {
        return cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    // Computed property para obtener el total de los items seleccionados
    var selectedItemsTotal: Double {
        return cartItems.filter { $0.isSelected }.reduce(0) { $0 + $1.subtotal }
    }
    
    // Computed property para el total formateado
    var formattedSelectedItemsTotal: String {
        if let currencyCode = cartItems.first?.product.price.currency_code {
            return "\(currencyCode)\(Int(selectedItemsTotal))"
        }
        return "Rp0"
    }
    
    // Computed property para contar cuántos items están seleccionados
    var selectedItemsCount: Int {
        return cartItems.filter { $0.isSelected }.count
    }
    
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
    
    // Métodos para manejar el carrito
    func addReachuProductToCart(_ product: ReachuProduct, size: String? = nil, color: String? = nil, quantity: Int = 1) {
        // Verificar si el producto ya está en el carrito
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
                // Si la cantidad es 0 o negativa, eliminamos el item
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