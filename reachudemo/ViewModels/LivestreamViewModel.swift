import Foundation
import Combine

class LivestreamViewModel: ObservableObject {
    @Published var livestreams: [Livestream] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let livestreamService = LivestreamService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // For demo purposes, we'll create some sample data
        createSampleData()
    }
    
    func fetchLivestreams() {
        isLoading = true
        errorMessage = nil
        
        // In a real app, we would call the API
        // livestreamService.fetchLivestreams()
        //     .receive(on: DispatchQueue.main)
        //     .sink(
        //         receiveCompletion: { [weak self] completion in
        //             self?.isLoading = false
        //             if case .failure(let error) = completion {
        //                 self?.errorMessage = error.localizedDescription
        //             }
        //         },
        //         receiveValue: { [weak self] livestreams in
        //             self?.livestreams = livestreams
        //         }
        //     )
        //     .store(in: &cancellables)
        
        // For now, we'll simulate a network request with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            // Use sample data
            self.isLoading = false
        }
    }
    
    private func createSampleData() {
        // Create sample livestreams for demo purposes
        let dateFormatter = ISO8601DateFormatter()
        
        self.livestreams = [
            Livestream(
                id: "1",
                title: "Cooking Healthy Meals for Diabetics",
                description: "Learn how to prepare delicious and healthy meals suitable for people with diabetes.",
                thumbnailURL: "https://example.com/thumbnails/cooking.jpg",
                hostName: "Chef Maria",
                startTime: dateFormatter.date(from: "2023-06-15T14:00:00Z") ?? Date(),
                isLive: true,
                viewerCount: 245,
                category: "Cooking"
            ),
            Livestream(
                id: "2",
                title: "Diabetes Management Q&A with Dr. Johnson",
                description: "Live Q&A session with Dr. Johnson, a specialist in diabetes management.",
                thumbnailURL: "https://example.com/thumbnails/doctor.jpg",
                hostName: "Dr. Johnson",
                startTime: dateFormatter.date(from: "2023-06-15T16:30:00Z") ?? Date(),
                isLive: true,
                viewerCount: 512,
                category: "Health"
            ),
            Livestream(
                id: "3",
                title: "Yoga for Diabetics - Gentle Flow",
                description: "A gentle yoga flow designed specifically for people with diabetes to improve circulation and reduce stress.",
                thumbnailURL: "https://example.com/thumbnails/yoga.jpg",
                hostName: "Sarah Wellness",
                startTime: dateFormatter.date(from: "2023-06-16T10:00:00Z") ?? Date(),
                isLive: false,
                viewerCount: 0,
                category: "Fitness"
            ),
            Livestream(
                id: "4",
                title: "Understanding Nutrition Labels",
                description: "Learn how to read and understand nutrition labels to make better food choices for managing diabetes.",
                thumbnailURL: "https://example.com/thumbnails/nutrition.jpg",
                hostName: "Nutritionist Alex",
                startTime: dateFormatter.date(from: "2023-06-16T13:00:00Z") ?? Date(),
                isLive: false,
                viewerCount: 0,
                category: "Nutrition"
            )
        ]
    }
} 