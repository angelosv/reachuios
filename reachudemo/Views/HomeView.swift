import SwiftUI
import Combine

struct HomeView: View {
    // MARK: - Properties
    @StateObject private var viewModel = ArticleViewModel()
    @StateObject private var liveShowViewModel = LiveShowViewModel()
    @State private var searchText = ""
    @State private var selectedTab = 1
    
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
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(viewModel.categories) { category in
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
                                selectedTab = 1
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
                                    .foregroundColor(.red)
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
                    Text("Eksplor")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Search action
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.red)
                    }
                }
            }
            .onAppear {
                viewModel.fetchArticles()
                liveShowViewModel.fetchShowBySlug("cosmedbeauty-desember2024")
            }
        }
    }
}

// MARK: - Preview
#Preview {
    HomeView()
} 