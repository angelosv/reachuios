import SwiftUI

struct FeaturedArticlesView: View {
    @ObservedObject var viewModel: ArticleViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(viewModel.featuredArticles) { article in
                    FeaturedArticleCard(article: article)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct FeaturedArticleCard: View {
    let article: Article
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Image
            Image(article.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 280, height: 200)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                if let subtitle = article.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                HStack {
                    Text(article.readTime)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    if article.commentCount > 0 {
                        Image(systemName: "bubble.left")
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("\(article.commentCount)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.top, 4)
            }
            .padding()
        }
        .frame(width: 280, height: 200)
    }
}

#Preview {
    FeaturedArticlesView(viewModel: ArticleViewModel())
} 