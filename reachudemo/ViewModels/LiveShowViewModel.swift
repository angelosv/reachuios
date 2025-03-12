import Foundation
import Combine
import SwiftUI

// Nuevo ViewModel con nombre diferente
class LiveShowViewModel: ObservableObject {
    @Published var currentShow: LiveStream?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let baseURL = "https://microservices.tipioapp.com"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load demo data on initialization
        loadDemoShow()
    }
    
    func fetchShowBySlug(_ slug: String) {
        isLoading = true
        error = nil
        
        guard let url = URL(string: "\(baseURL)/stream/by-slug-or-streamid") else {
            self.error = URLError(.badURL)
            self.isLoading = false
            return
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "slug", value: slug)
        ]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: LiveStreamResponse.self, decoder: JSONDecoder())
            .map { response -> LiveStream in
                let dateFormatter = ISO8601DateFormatter()
                return LiveStream(
                    id: response.id,
                    title: response.title,
                    slug: response.slug,
                    thumbnail: response.thumbnail,
                    broadcasting: response.broadcasting,
                    createdAt: dateFormatter.date(from: response.createdAt) ?? Date(),
                    updatedAt: dateFormatter.date(from: response.updatedAt) ?? Date(),
                    hostName: "Cosmed Beauty",
                    description: "Bli med vinn fine premier live",
                    duration: 3600, 
                    viewerCount: 0,
                    category: "Beauty"
                )
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] liveStream in
                    self?.currentShow = liveStream
                }
            )
            .store(in: &cancellables)
    }
    
    private func loadDemoShow() {
        // Create a demo LiveStream with data from the endpoint
        currentShow = LiveStream(
            id: 35,
            title: "30% på alt! Bli med vinn fine premier live",
            slug: "cosmedbeauty-desember2024",
            thumbnail: "https://storage.googleapis.com/tipio-images/a7835493-0171-4e8c-8d59-c2dafede021b.jpeg",
            broadcasting: false,
            createdAt: Date(),
            updatedAt: Date(),
            hostName: "Cosmed Beauty",
            description: "Bli med vinn fine premier live",
            duration: 3600,
            viewerCount: 0,
            category: "Beauty"
        )
    }
    
    // Helper to format the date
    func formattedTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
} 