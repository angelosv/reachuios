import SwiftUI

struct StoreView: View {
    @StateObject private var viewModel = StoreViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Featured Products
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(viewModel.featuredProducts) { product in
                                FeaturedProductCard(product: product) {
                                    viewModel.addToCart(product)
                                }
                            }
                        }
                    }
                    
                    // Categories
                    VStack(alignment: .leading) {
                        HStack {
                            Text("CATEGORIES")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.filterByCategory(nil)
                            }) {
                                Text("See All")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(viewModel.categories) { category in
                                    StoreCategoryCard(category: category)
                                        .onTapGesture {
                                            viewModel.filterByCategory(category)
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Products Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(viewModel.products) { product in
                            ProductCard(product: product) {
                                viewModel.addToCart(product)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Store")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "cart")
                                .foregroundColor(.red)
                            
                            if viewModel.cartItemCount > 0 {
                                Text("\(viewModel.cartItemCount)")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 10, y: -10)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .onAppear {
                viewModel.fetchProducts()
            }
        }
    }
}

struct ProductCard: View {
    let product: Product
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image
            Image(product.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .clipped()
                .cornerRadius(12)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(product.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    // Rating
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", product.rating))
                    }
                    .font(.caption)
                    
                    Spacer()
                    
                    // Price
                    Text(product.formattedPrice)
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                
                Button(action: action) {
                    Text("Add to Cart")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
        }
        .padding(12)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    StoreView()
} 