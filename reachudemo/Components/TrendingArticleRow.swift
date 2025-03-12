import SwiftUI

struct TrendingArticleRow: View {
    let article: Article
    
    var body: some View {
        NavigationLink(destination: ArticleDetailView(article: article)) {
            HStack(spacing: 12) {
                // Thumbnail
                if let imageUrl = article.imageURL {
                    RemoteImage(url: imageUrl) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 80, height: 80)
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                } else {
                    Image(article.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(article.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text(article.readTime)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if article.commentCount > 0 {
                            Spacer()
                            
                            Image(systemName: "bubble.left")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(article.commentCount)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 4)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    VStack {
        TrendingArticleRow(article: Article.sampleTrendingArticles[0])
        TrendingArticleRow(article: Article.sampleTrendingArticles[2])
    }
    .padding()
} 