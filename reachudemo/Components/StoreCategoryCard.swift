import SwiftUI

struct StoreCategoryCard: View {
    let category: ProductCategory
    
    var body: some View {
        ZStack(alignment: .center) {
            // Image
            Image(category.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.4))
                )
            
            // Title
            Text(category.rawValue)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .frame(width: 150, height: 150)
    }
}

#Preview {
    HStack {
        StoreCategoryCard(category: .glucometers)
        StoreCategoryCard(category: .supplements)
    }
} 