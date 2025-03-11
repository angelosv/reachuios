import SwiftUI

struct LiveShowBanner: View {
    let title: String
    let startTime: Date
    let hostName: String
    let thumbnailName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                // Imagen de fondo
                Image(thumbnailName)
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fill)
                    .frame(height: 150)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(12)
                
                // Contenido superpuesto
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "dot.radiowaves.left.and.right")
                            .foregroundColor(.red)
                        Text("PRÓXIMO EN VIVO")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(4)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.gray)
                            Text(hostName)
                                .font(.subheadline)
                            Spacer()
                            Image(systemName: "clock.fill")
                                .foregroundColor(.gray)
                            Text(startTime, style: .time)
                                .font(.subheadline)
                        }
                        .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding()
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    LiveShowBanner(
        title: "Tips para una Dieta Saludable",
        startTime: Date().addingTimeInterval(3600),
        hostName: "Dr. García",
        thumbnailName: "healthy-food",
        action: {}
    )
    .previewLayout(.sizeThatFits)
} 