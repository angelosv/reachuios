import SwiftUI

struct CategoryCard: View {
    let category: String
    @StateObject private var viewModel = ArticleViewModel()
    
    var body: some View {
        NavigationLink(destination: ArticleDetailView(article: viewModel.getSampleArticle())) {
            ZStack(alignment: .center) {
                // Image
                Image(Categories.imageName(for: category))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.4))
                    )
                
                // Title
                Text(category)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
            .frame(width: 150, height: 150)
        }
    }
}

#Preview {
    HStack {
        CategoryCard(category: Categories.diet)
        CategoryCard(category: Categories.diabeticLifestyle)
    }
} 