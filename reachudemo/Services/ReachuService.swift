import Foundation
import Combine

struct GraphQLRequest: Encodable {
    let query: String
    let variables: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case query
        case variables
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(query, forKey: .query)
        
        if let variables = variables {
            let data = try JSONSerialization.data(withJSONObject: variables)
            let variablesString = String(data: data, encoding: .utf8)
            try container.encode(variablesString, forKey: .variables)
        }
    }
}

struct GraphQLResponse<T: Decodable>: Decodable {
    let data: T?
    let errors: [GraphQLError]?
}

struct GraphQLError: Decodable {
    let message: String
    let locations: [GraphQLErrorLocation]?
    let path: [String]?
}

struct GraphQLErrorLocation: Decodable {
    let line: Int
    let column: Int
}

class ReachuService {
    static let shared = ReachuService()
    
    private let networkService = NetworkService.shared
    private let baseURL = URL(string: "https://api.reachu.io/graphql")!
    private var apiKey: String = "YOUR_API_KEY" // Replace with your actual API key
    
    private init() {}
    
    func executeQuery<T: Decodable>(
        query: String,
        variables: [String: Any]? = nil
    ) -> AnyPublisher<T, NetworkError> {
        guard let url = URL(string: "https://api.reachu.io/graphql") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        let graphQLRequest = GraphQLRequest(query: query, variables: variables)
        
        guard let requestBody = try? JSONEncoder().encode(graphQLRequest) else {
            return Fail(error: NetworkError.unknown(NSError(domain: "ReachuService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode request"]))).eraseToAnyPublisher()
        }
        
        let headers = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        return networkService.fetch(
            url: url,
            httpMethod: "POST",
            headers: headers,
            body: requestBody
        )
    }
    
    // Example query to fetch articles
    func fetchArticles() -> AnyPublisher<[Article], NetworkError> {
        let query = """
        query GetArticles {
            articles {
                id
                title
                subtitle
                content
                imageName
                readTime
                commentCount
                category
                isFeatured
                isTrending
                publishDate
            }
        }
        """
        
        // This is a placeholder since we don't have the actual API
        // In a real implementation, we would use the executeQuery method
        // For now, we'll return a failure to simulate the API call
        return Fail(error: NetworkError.unknown(NSError(domain: "ReachuService", code: -1, userInfo: [NSLocalizedDescriptionKey: "API not implemented yet"]))).eraseToAnyPublisher()
    }
} 