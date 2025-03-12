import SwiftUI
import Combine

// MARK: - Constants
struct AppConstants {
    // Colors
    static let primaryColor = Color(hex: "#7300f9")
    
    // Text
    struct Text {
        static let appTitle = "StyleLife"
        static let categories = "CATEGORIES"
        static let trending = "TRENDING NOW"
        static let seeAll = "See All"
        static let retry = "Retry"
        static let noTrendingArticles = "No trending articles found"
    }
    
    // Loading Messages
    struct LoadingMessages {
        static let general = "Loading..."
        static let featuredArticles = "Loading featured articles..."
        static let trendingArticles = "Loading trending articles..."
        static let liveShow = "Loading live show..."
    }
    
    // Video IDs
    struct VideoIDs {
        static let defaultLiveShow = "cosmedbeauty-desember2024"
    }
    
    // Accessibility
    struct Accessibility {
        static let loadingIndicator = "Loading content"
        static let errorIcon = "Error icon"
        static let retryButton = "Retry loading content"
        static let seeAllButton = "See all items in this category"
        static let searchButton = "Search"
        static let categoriesSection = "Categories section"
        static let trendingSection = "Trending articles section"
        static let liveShowSection = "Live show section"
        static let featuredSection = "Featured articles section"
        static let nextProductButton = "Next product"
        static let previousProductButton = "Previous product"
        static let addToCartButton = "Add to cart"
    }
}

// MARK: - Loading View Component
/// Displays a loading indicator with optional text
struct LoadingView: View {
    let message: String
    let primaryColor: Color
    
    init(message: String = AppConstants.LoadingMessages.general, primaryColor: Color = AppConstants.primaryColor) {
        self.message = message
        self.primaryColor = primaryColor
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: primaryColor))
                .scaleEffect(1.2)
                .accessibilityLabel(AppConstants.Accessibility.loadingIndicator)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}

// MARK: - Error View Component
/// Displays an error message with retry button
struct ErrorView: View {
    let errorMessage: String
    let primaryColor: Color
    let onRetry: () -> Void
    
    init(errorMessage: String, primaryColor: Color = AppConstants.primaryColor, onRetry: @escaping () -> Void) {
        self.errorMessage = errorMessage
        self.primaryColor = primaryColor
        self.onRetry = onRetry
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(primaryColor)
                .accessibilityLabel(AppConstants.Accessibility.errorIcon)
            
            Text(errorMessage)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button(action: onRetry) {
                Text(AppConstants.Text.retry)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .accessibilityLabel(AppConstants.Accessibility.retryButton)
            .accessibilityHint(errorMessage)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .padding()
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Error: \(errorMessage)")
    }
}

// MARK: - Categories Section Component
/// Displays a horizontal scrollable list of categories
struct CategoriesSection: View {
    let categories: [String]
    let primaryColor: Color
    let onCategoryTap: (String) -> Void
    
    init(categories: [String], primaryColor: Color = AppConstants.primaryColor, onCategoryTap: @escaping (String) -> Void) {
        self.categories = categories
        self.primaryColor = primaryColor
        self.onCategoryTap = onCategoryTap
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            SectionHeader(title: AppConstants.Text.categories, primaryColor: primaryColor)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(categories, id: \.self) { category in
                        CategoryCard(category: category)
                            .onTapGesture {
                                onCategoryTap(category)
                            }
                            .accessibilityLabel("Category: \(category)")
                            .accessibilityAddTraits(.isButton)
                    }
                }
                .padding(.horizontal)
            }
            .accessibilityLabel("Scroll through categories")
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(AppConstants.Accessibility.categoriesSection)
    }
}

// MARK: - Trending Section Component
/// Displays a vertical list of trending articles
struct TrendingSection: View {
    let articles: [Article]
    let primaryColor: Color
    let isLoading: Bool
    
    init(articles: [Article], primaryColor: Color = AppConstants.primaryColor, isLoading: Bool = false) {
        self.articles = articles
        self.primaryColor = primaryColor
        self.isLoading = isLoading
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            SectionHeader(title: AppConstants.Text.trending, primaryColor: primaryColor)
            
            if isLoading {
                LoadingView(message: AppConstants.LoadingMessages.trendingArticles, primaryColor: primaryColor)
            } else if articles.isEmpty {
                Text(AppConstants.Text.noTrendingArticles)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .accessibilityLabel(AppConstants.Text.noTrendingArticles)
            } else {
                VStack(spacing: 15) {
                    ForEach(articles) { article in
                        TrendingArticleRow(article: article)
                            .accessibilityLabel("Article: \(article.title)")
                            .accessibilityHint("Tap to read more about this article")
                    }
                }
                .padding(.horizontal)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(AppConstants.Accessibility.trendingSection)
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
    
    init(
        liveStream: LiveStream,
        currentProduct: ReachuProduct?,
        primaryColor: Color = AppConstants.primaryColor,
        onShowTap: @escaping () -> Void,
        onAddToCart: @escaping (ReachuProduct) -> Void,
        onNextProduct: @escaping () -> Void,
        onPreviousProduct: @escaping () -> Void
    ) {
        self.liveStream = liveStream
        self.currentProduct = currentProduct
        self.primaryColor = primaryColor
        self.onShowTap = onShowTap
        self.onAddToCart = onAddToCart
        self.onNextProduct = onNextProduct
        self.onPreviousProduct = onPreviousProduct
    }
    
    var body: some View {
        LiveShowBanner(
            liveStream: liveStream,
            action: onShowTap,
            currentProduct: currentProduct,
            onAddToCart: onAddToCart,
            onNextProduct: onNextProduct,
            onPreviousProduct: onPreviousProduct
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel(AppConstants.Accessibility.liveShowSection)
        .accessibilityHint("Live show: \(liveStream.title). Tap to watch.")
    }
}

// MARK: - Section Header Component
/// Reusable section header with title and "See All" button
struct SectionHeader: View {
    let title: String
    let primaryColor: Color
    var action: (() -> Void)?
    
    init(title: String, primaryColor: Color = AppConstants.primaryColor, action: (() -> Void)? = nil) {
        self.title = title
        self.primaryColor = primaryColor
        self.action = action
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .accessibilityAddTraits(.isHeader)
            
            Spacer()
            
            Button(action: {
                action?()
            }) {
                Text(AppConstants.Text.seeAll)
                    .foregroundColor(primaryColor)
            }
            .accessibilityLabel(AppConstants.Accessibility.seeAllButton)
            .accessibilityHint("See all \(title.lowercased())")
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
    
    init(
        viewModel: ArticleViewModel,
        liveShowViewModel: LiveShowViewModel,
        primaryColor: Color = AppConstants.primaryColor,
        onShowTap: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.liveShowViewModel = liveShowViewModel
        self.primaryColor = primaryColor
        self.onShowTap = onShowTap
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Featured Articles
            if viewModel.isLoading && viewModel.featuredArticles.isEmpty {
                LoadingView(message: AppConstants.LoadingMessages.featuredArticles, primaryColor: primaryColor)
            } else if let errorMessage = viewModel.errorMessage {
                ErrorView(
                    errorMessage: errorMessage,
                    primaryColor: primaryColor,
                    onRetry: { viewModel.fetchArticles() }
                )
            } else {
                FeaturedArticlesView(viewModel: viewModel)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel(AppConstants.Accessibility.featuredSection)
            }
            
            // Categories Section
            CategoriesSection(
                categories: viewModel.categories,
                primaryColor: primaryColor,
                onCategoryTap: { category in
                    viewModel.fetchArticlesByCategory(category)
                }
            )
            
            // Live Show Banner
            if liveShowViewModel.isLoading && liveShowViewModel.currentShow == nil {
                LoadingView(message: AppConstants.LoadingMessages.liveShow, primaryColor: primaryColor)
            } else if let error = liveShowViewModel.error {
                ErrorView(
                    errorMessage: error.localizedDescription,
                    primaryColor: primaryColor,
                    onRetry: { 
                        liveShowViewModel.fetchShowBySlug(AppConstants.VideoIDs.defaultLiveShow)
                    }
                )
            } else if let liveStream = liveShowViewModel.currentShow {
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
                primaryColor: primaryColor,
                isLoading: viewModel.isLoading && viewModel.trendingArticles.isEmpty
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
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    HomeContentView(
                        viewModel: viewModel,
                        liveShowViewModel: liveShowViewModel,
                        onShowTap: {
                            showVideoPlayer = true
                        }
                    )
                }
                .accessibilityLabel("Home feed")
                
                // Global loading indicator
                if viewModel.isLoading && liveShowViewModel.isLoading {
                    Color.black.opacity(0.1)
                        .ignoresSafeArea()
                        .accessibilityHidden(true)
                    
                    LoadingView()
                        .background(Color(UIColor.systemBackground).opacity(0.8))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(AppConstants.Text.appTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .accessibilityAddTraits(.isHeader)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Search action
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppConstants.primaryColor)
                    }
                    .accessibilityLabel(AppConstants.Accessibility.searchButton)
                }
            }
            .onAppear {
                viewModel.fetchArticles()
                liveShowViewModel.fetchShowBySlug(AppConstants.VideoIDs.defaultLiveShow)
            }
            .fullScreenCover(isPresented: $showVideoPlayer) {
                VideoPlayerView(videoId: AppConstants.VideoIDs.defaultLiveShow)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    HomeView()
} 
