import SwiftUI

/// Versión refactorizada de StoreView que usa los componentes reutilizables
/// Esta es una versión de ejemplo para demostrar el uso de los componentes
struct StoreViewRefactored: View {
    @StateObject private var viewModel = StoreViewModel()
    @State private var searchText = ""
    @State private var selectedProduct: ReachuProduct? = nil
    @State private var showProductDetail = false
    @State private var showShoppingCart = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header con búsqueda y carrito
                searchAndCartHeader
                
                // Contenido principal
                StateAwareView(
                    isLoading: viewModel.isLoading,
                    error: viewModel.errorMessage != nil ? NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: viewModel.errorMessage!]) : nil,
                    isEmpty: viewModel.reachuProducts.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil,
                    emptyTitle: "No hay productos",
                    emptyMessage: "No se encontraron productos disponibles",
                    emptyIconName: "cart",
                    retryAction: { viewModel.fetchProducts() }
                ) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: AppTheme.Padding.large) {
                            // Banner promocional
                            promotionalBanner
                            
                            // Categorías
                            categoriesSection
                            
                            // Productos destacados
                            featuredProductsSection
                            
                            // Todos los productos
                            allProductsSection
                        }
                        .padding(.bottom, AppTheme.Padding.large)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showProductDetail) {
                if let product = selectedProduct {
                    ProductDetailModal(
                        product: product,
                        isPresented: $showProductDetail,
                        onAddToCart: { _, size, color, quantity in
                            viewModel.addReachuProductToCart(product, size: size, color: color, quantity: quantity)
                            selectedProduct = nil
                        }
                    )
                }
            }
            .sheet(isPresented: $showShoppingCart) {
                ShoppingCartView(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Secciones de la UI
    
    private var searchAndCartHeader: some View {
        HStack(spacing: AppTheme.Padding.medium) {
            // Campo de búsqueda
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Buscar productos", text: $searchText)
                    .autocapitalization(.none)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(AppTheme.Padding.medium)
            .background(Color(.systemGray6))
            .cornerRadius(AppTheme.CornerRadius.standard)
            
            // Botón de carrito con contador
            Button(action: { showShoppingCart = true }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "cart")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.primaryColor)
                        .frame(width: 44, height: 44)
                    
                    if viewModel.cartItemCount > 0 {
                        Text("\(viewModel.cartItemCount)")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .frame(width: 18, height: 18)
                            .background(AppTheme.secondaryColor)
                            .clipShape(Circle())
                            .offset(x: 8, y: -8)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, AppTheme.Padding.medium)
    }
    
    private var promotionalBanner: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(AppTheme.primaryColor)
                .cornerRadius(AppTheme.CornerRadius.medium)
            
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Get Winter Discount")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("20% Off")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                    
                    Text("For Diabetes Products")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.leading)
                
                Spacer()
                
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.trailing)
            }
        }
        .frame(height: 120)
        .padding(.horizontal)
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Padding.medium) {
            Text("Categorías")
                .font(AppTheme.TextStyle.sectionHeader)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Padding.medium) {
                    // Botón "Todos"
                    CategoryButton(
                        title: "Todos",
                        isSelected: viewModel.selectedCategory == nil,
                        action: { viewModel.filterByCategory(nil) }
                    )
                    
                    // Botones de categorías individuales
                    ForEach(viewModel.categories, id: \.self) { category in
                        CategoryButton(
                            title: category.rawValue,
                            isSelected: viewModel.selectedCategory == category,
                            action: { viewModel.filterByCategory(category) }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // Componente auxiliar para simplificar los botones de categoría
    private struct CategoryButton: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(AppTheme.TextStyle.body)
                    .foregroundColor(isSelected ? .white : .primary)
                    .padding(.horizontal, AppTheme.Padding.standard)
                    .padding(.vertical, AppTheme.Padding.small)
                    .background(isSelected ? AppTheme.primaryColor : Color(.systemGray5))
                    .cornerRadius(AppTheme.CornerRadius.standard)
            }
        }
    }
    
    private var featuredProductsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Padding.medium) {
            HStack {
                Text("Destacados")
                    .font(AppTheme.TextStyle.sectionHeader)
                
                Spacer()
                
                Button(action: {}) {
                    Text("Ver Todos")
                        .font(AppTheme.TextStyle.caption)
                        .foregroundColor(AppTheme.primaryColor)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Padding.medium) {
                    ForEach(viewModel.reachuProducts.prefix(5)) { product in
                        FeaturedProductCard(
                            product: product, 
                            onTap: {
                                selectedProduct = product
                                showProductDetail = true
                            },
                            onFavorite: {
                                // Implementar lógica de favoritos
                                print("Favorito: \(product.title)")
                            }
                        )
                        .frame(width: 180)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, AppTheme.Padding.small)
            }
        }
    }
    
    private var allProductsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Padding.medium) {
            Text("Todos los Productos")
                .font(AppTheme.TextStyle.sectionHeader)
                .padding(.horizontal)
            
            let columns = [
                GridItem(.flexible(), spacing: AppTheme.Padding.medium),
                GridItem(.flexible(), spacing: AppTheme.Padding.medium)
            ]
            
            LazyVGrid(columns: columns, spacing: AppTheme.Padding.medium) {
                ForEach(viewModel.reachuProducts) { product in
                    ReachuProductCard(
                        product: product, 
                        onTap: {
                            selectedProduct = product
                            showProductDetail = true
                        }, 
                        onAddToCart: {
                            viewModel.addReachuProductToCart(product)
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    StoreViewRefactored()
} 