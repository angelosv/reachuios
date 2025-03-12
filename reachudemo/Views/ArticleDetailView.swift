import SwiftUI
import Combine

struct ArticleDetailView: View {
    let article: Article
    @State private var product: ReachuProduct?
    @State private var isLoadingProduct = true
    @State private var cancellables = Set<AnyCancellable>()
    @State private var showBookmark = false
    @Environment(\.presentationMode) var presentationMode
    
    // Demo product ID
    let productId = 123 // Replace with an actual product ID
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header and Image
                ZStack(alignment: .top) {
                    if let imageUrl = article.imageURL {
                        RemoteImage(url: imageUrl) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 240)
                        }
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 240)
                        .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 240)
                    }
                    
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding(.top, 8)
                        
                        Spacer()
                        
                        Button(action: {
                            showBookmark.toggle()
                        }) {
                            Image(systemName: showBookmark ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .padding(.top, 30)
                }
                
                // Article Title
                Text(article.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // Tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(["Diabetic", "Health", "Lifestyle"], id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: "#F5F5F5"))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // First paragraph
                Text("Lorem ipsum dolor sit amet consectetur. Interdum viverra vitae lectus mi quis pharetra. Vel fusce sed viverra eget a ante mauris libero adipiscing. Pellentesque urna nulla dictum lacus pharetra viverra urna nisi nisi. Bibendum fames nibh pellentesque at mus nunc risus.")
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Embedded Product (after first paragraph)
                if isLoadingProduct {
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Spacer()
                    }
                    .padding()
                    .background(Color(hex: "#F5F5F5").opacity(0.5))
                    .cornerRadius(12)
                    .padding(.horizontal)
                } else if let product = product {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            if let mainImageURL = product.mainImageURL {
                                RemoteImage(url: mainImageURL) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 80, height: 80)
                                }
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(product.title)
                                    .font(.headline)
                                    .lineLimit(1)
                                
                                Text(product.formattedPrice)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "#7300f9"))
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // Add to cart action
                            }) {
                                Text("Add")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color(hex: "#7300f9"))
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding()
                    .background(Color(hex: "#F5F5F5").opacity(0.5))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // More paragraphs
                Text("Sem cras eget eleifend cursus pretium id in vulputate. Dignissim vel vestibulum orci curabitur. Nullam fermentum sed nunc massa. Porttitor habitant facilisis vel arcu.")
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                Text("Libero facilisis nisl consectetur nisi nunc a consequat. Ullamcorper augue massa nunc sagittis ipsum sed eu quisque. Morbi dui et neque urna consectetur nunc massa. Pharetra volutpat semper nisi faucibus. Sed lectus at libero hendrerit tristique nunc.")
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Tags section at the bottom
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tags")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack {
                        ForEach(["Diabetic", "Health", "Lifestyle"], id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: "#F5F5F5"))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            fetchProduct()
        }
    }
    
    private func fetchProduct() {
        let service = ReachuGraphQLService()
        
        // Use a valid product ID from the Reachu API
        // For demo purposes, we'll use a hardcoded ID
        service.fetchProductById(productId: 1234)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoadingProduct = false
                    if case .failure(let error) = completion {
                        print("Error fetching product: \(error)")
                    }
                },
                receiveValue: { fetchedProduct in
                    self.product = fetchedProduct
                }
            )
            .store(in: &cancellables)
    }
}

#Preview {
    ArticleDetailView(article: Article(
        id: "1",
        title: "Diabetes Mellitus in Young Age: Causes and Characteristics",
        content: "Lorem ipsum dolor sit amet...",
        imageURL: URL(string: "https://picsum.photos/800/600"),
        category: "Health"
    ))
} 