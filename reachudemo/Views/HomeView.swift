import SwiftUI
import Combine

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
                VStack(alignment: .leading, spacing: 20) {
                    // Featured Articles
                    FeaturedArticlesView(viewModel: viewModel)
                    
                    // Categories Section
                    VStack(alignment: .leading) {
                        HStack {
                            Text("CATEGORIES")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {
                                // Action for See All
                            }) {
                                Text("See All")
                                    .foregroundColor(primaryColor)
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(viewModel.categories, id: \.self) { category in
                                    CategoryCard(category: category)
                                        .onTapGesture {
                                            viewModel.fetchArticlesByCategory(category)
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Live Show Banner
                    if let liveStream = liveShowViewModel.currentShow {
                        LiveShowBanner(
                            liveStream: liveStream,
                            action: {
                                showVideoPlayer = true
                            },
                            currentProduct: liveShowViewModel.currentProduct,
                            onAddToCart: { product in
                                print("Adding product to cart: \(product.title)")
                                // Aquí puedes integrar con tu sistema de carrito
                                // Por ejemplo, usando el modelo de StoreViewModel
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
                    VStack(alignment: .leading) {
                        HStack {
                            Text("TRENDING NOW")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {
                                // Action for See All
                            }) {
                                Text("See All")
                                    .foregroundColor(primaryColor)
                            }
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 15) {
                            ForEach(viewModel.trendingArticles) { article in
                                TrendingArticleRow(article: article)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
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