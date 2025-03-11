import SwiftUI

struct LiveShowBanner: View {
    let liveStream: LiveStream
    let action: () -> Void
    
    // Main app color
    let primaryColor = Color(hex: "#7300f9")
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // Image on the left
                AsyncImage(url: URL(string: liveStream.thumbnail)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 90)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 90)
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 120, height: 90)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 120, height: 90)
                    }
                }
                .clipped()
                .cornerRadius(10)
                .overlay(
                    VStack {
                        HStack {
                            Image(systemName: "dot.radiowaves.left.and.right")
                                .foregroundColor(primaryColor)
                            Text("LIVE")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(4)
                        .padding(6)
                        
                        Spacer()
                    },
                    alignment: .topLeading
                )
                
                // Content on the right
                VStack(alignment: .leading, spacing: 4) {
                    Text("COMING LIVE SOON")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(primaryColor)
                    
                    Text(liveStream.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        if let hostName = liveStream.hostName {
                            Image(systemName: "person.circle.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(hostName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "clock.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(DateFormatter.livestreamTimeFormatter.string(from: liveStream.createdAt))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal)
    }
}

// DateFormatter extension
extension DateFormatter {
    static let livestreamTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

#Preview {
    let demoLiveStream = LiveStream(
        id: 1,
        title: "Demo Live Stream",
        slug: "demo-stream",
        thumbnail: "https://example.com/thumbnail.jpg",
        broadcasting: true,
        createdAt: Date(),
        updatedAt: Date(),
        hostName: "Demo Host",
        description: "Demo Description",
        duration: 3600,
        viewerCount: 100,
        category: "Health"
    )
    
    return LiveShowBanner(
        liveStream: demoLiveStream,
        action: {}
    )
    .previewLayout(.sizeThatFits)
    .padding()
    .background(Color.gray.opacity(0.1))
} 