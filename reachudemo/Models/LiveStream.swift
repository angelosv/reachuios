import Foundation

struct LiveStream: Identifiable, Codable {
    let id: Int
    let title: String
    let slug: String
    let thumbnail: String
    let broadcasting: Bool
    let createdAt: Date
    let updatedAt: Date
    
    // Campos adicionales que podrían ser útiles
    var hostName: String?
    var description: String?
    var duration: TimeInterval?
    var viewerCount: Int?
    var category: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case slug
        case thumbnail
        case broadcasting
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }
}

// API Response structure
struct LiveStreamResponse: Codable {
    let id: Int
    let title: String
    let slug: String
    let thumbnail: String
    let broadcasting: Bool
    let createdAt: String
    let updatedAt: String
    
    func toLiveStream() -> LiveStream {
        let dateFormatter = ISO8601DateFormatter()
        return LiveStream(
            id: id,
            title: title,
            slug: slug,
            thumbnail: thumbnail,
            broadcasting: broadcasting,
            createdAt: dateFormatter.date(from: createdAt) ?? Date(),
            updatedAt: dateFormatter.date(from: updatedAt) ?? Date(),
            hostName: "Dr. García", // Demo data
            description: nil,
            duration: 3600, // 1 hour demo
            viewerCount: 0,
            category: "Health"
        )
    }
} 