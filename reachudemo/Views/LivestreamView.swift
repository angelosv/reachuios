import SwiftUI

struct LivestreamView: View {
    @StateObject private var viewModel = LivestreamViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if let error = viewModel.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                            .padding()
                        
                        Text(error)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button("Try Again") {
                            viewModel.fetchLivestreams()
                        }
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                } else if viewModel.livestreams.isEmpty {
                    VStack {
                        Image(systemName: "tv")
                            .font(.largeTitle)
                            .padding()
                        
                        Text("No livestreams available at the moment")
                            .font(.headline)
                        
                        Text("Check back later for new content")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.livestreams) { livestream in
                                LivestreamCard(livestream: livestream)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Live Streams")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            .onAppear {
                viewModel.fetchLivestreams()
            }
        }
    }
}

struct LivestreamCard: View {
    let livestream: Livestream
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Thumbnail with live indicator
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: livestream.thumbnailURL)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(16/9, contentMode: .fill)
                            .cornerRadius(12)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .cornerRadius(12)
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(16/9, contentMode: .fill)
                            .cornerRadius(12)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(16/9, contentMode: .fill)
                            .cornerRadius(12)
                    }
                }
                .frame(height: 180)
                
                if livestream.isLive {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        
                        Text("LIVE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(4)
                    .padding(8)
                }
                
                // Viewer count
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.caption)
                    
                    Text("\(livestream.viewerCount)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.6))
                .cornerRadius(4)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(livestream.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(livestream.hostName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(livestream.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }
            .padding(.horizontal, 4)
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    LivestreamView()
} 