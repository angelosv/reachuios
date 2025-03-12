import Foundation
import Combine
import SwiftUI

// Nuevo ViewModel con nombre diferente
class LiveShowViewModel: ObservableObject {
    @Published var currentShow: LiveStream?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var products: [ReachuProduct] = []
    @Published var currentProductIndex: Int = 0
    
    private let baseURL = "https://microservices.tipioapp.com"
    private var cancellables = Set<AnyCancellable>()
    private let reachuService = ReachuGraphQLService()
    
    var currentProduct: ReachuProduct? {
        guard !products.isEmpty else { return nil }
        return products[safe: currentProductIndex]
    }
    
    init() {
        // Load demo data on initialization
        loadDemoShow()
        fetchProducts()
    }
    
    func fetchShowBySlug(_ slug: String) {
        isLoading = true
        error = nil
        
        let urlString = "\(baseURL)/stream/by-slug-or-streamid"
        guard let url = URL(string: urlString) else {
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
    
    func fetchProducts() {
        reachuService.fetchProducts()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error fetching products: \(error)")
                    }
                },
                receiveValue: { [weak self] products in
                    guard let self = self else { return }
                    self.products = products
                    self.currentProductIndex = 0
                }
            )
            .store(in: &cancellables)
    }
    
    func nextProduct() {
        guard !products.isEmpty else { return }
        currentProductIndex = (currentProductIndex + 1) % products.count
    }
    
    func previousProduct() {
        guard !products.isEmpty else { return }
        currentProductIndex = (currentProductIndex - 1 + products.count) % products.count
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

// Extension to safely access array elements
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
} 