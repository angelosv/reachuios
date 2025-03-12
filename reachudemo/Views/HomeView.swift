import SwiftUI
import Combine

// MARK: - Categories Section Component
/// Displays a horizontal scrollable list of categories
struct CategoriesSection: View {
    let categories: [String]
    let primaryColor: Color
    let onCategoryTap: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            SectionHeader(title: "CATEGORIES", primaryColor: primaryColor)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(categories, id: \.self) { category in
                        CategoryCard(category: category)
                            .onTapGesture {
                                onCategoryTap(category)
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Trending Section Component
/// Displays a vertical list of trending articles
struct TrendingSection: View {
    let articles: [Article]
    let primaryColor: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            SectionHeader(title: "TRENDING NOW", primaryColor: primaryColor)
            
            VStack(spacing: 15) {
                ForEach(articles) { article in
                    TrendingArticleRow(article: article)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - LiveShowSection Component
/// Displays the live show banner with current product
struct LiveShowSection: View {
    let liveStream: LiveStream
    let currentProduct: ReachuProduct?
    let primaryColor: Color
    let onShowTap: () -> Void
    let onAddToCart: (ReachuProduct) -> Void
    let onNextProduct: () -> Void
    let onPreviousProduct: () -> Void
    
    var body: some View {
        LiveShowBanner(
            liveStream: liveStream,
            action: onShowTap,
            currentProduct: currentProduct,
            onAddToCart: onAddToCart,
            onNextProduct: onNextProduct,
            onPreviousProduct: onPreviousProduct
        )
    }
}

// MARK: - Section Header Component
/// Reusable section header with title and "See All" button
struct SectionHeader: View {
    let title: String
    let primaryColor: Color
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: {
                action?()
            }) {
                Text("See All")
                    .foregroundColor(primaryColor)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Home Content View
/// Main content of the home screen
struct HomeContentView: View {
    @ObservedObject var viewModel: ArticleViewModel
    @ObservedObject var liveShowViewModel: LiveShowViewModel
    let primaryColor: Color
    let onShowTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Featured Articles
            FeaturedArticlesView(viewModel: viewModel)
            
            // Categories Section
            CategoriesSection(
                categories: viewModel.categories,
                primaryColor: primaryColor,
                onCategoryTap: { category in
                    viewModel.fetchArticlesByCategory(category)
                }
            )
            
            // Live Show Banner
            if let liveStream = liveShowViewModel.currentShow {
                LiveShowSection(
                    liveStream: liveStream,
                    currentProduct: liveShowViewModel.currentProduct,
                    primaryColor: primaryColor,
                    onShowTap: onShowTap,
                    onAddToCart: { product in
                        print("Adding product to cart: \(product.title)")
                        // Aquí puedes integrar con tu sistema de carrito
                    },
                    onNextProduct: {
                        liveShowViewModel.nextProduct()
                    },
                    onPreviousProduct: {
                        liveShowViewModel.previousProduct()
                    }
                )
            }
            
            // Trending Now Section
            TrendingSection(
                articles: viewModel.trendingArticles,
                primaryColor: primaryColor
            )
        }
        .padding(.vertical)
    }
}

struct HomeView: View {
    // MARK: - Properties
    @StateObject private var viewModel = ArticleViewModel()
    @StateObject private var liveShowViewModel = LiveShowViewModel()
    @State private var searchText = ""
    @State private var selectedTab = 1
    @State private var showVideoPlayer = false
    
    // Main app color
    let primaryColor = Color(hex: "#7300f9")
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                HomeContentView(
                    viewModel: viewModel,
                    liveShowViewModel: liveShowViewModel,
                    primaryColor: primaryColor,
                    onShowTap: {
                        showVideoPlayer = true
                    }
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("StyleLife")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Search action
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(primaryColor)
                    }
                }
            }
            .onAppear {
                viewModel.fetchArticles()
                liveShowViewModel.fetchShowBySlug("cosmedbeauty-desember2024")
            }
            .fullScreenCover(isPresented: $showVideoPlayer) {
                VideoPlayerView(videoId: "cosmedbeauty-desember2024")
            }
        }
    }
}

// MARK: - Preview
#Preview {
    HomeView()
} 