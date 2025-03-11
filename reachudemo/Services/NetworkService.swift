import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case unknown(Error)
}

class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    func fetch<T: Decodable>(
        url: URL,
        httpMethod: String = "GET",
        headers: [String: String]? = nil,
        body: Data? = nil
    ) -> AnyPublisher<T, NetworkError> {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.httpBody = body
        
        // Set default headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add custom headers if provided
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw NetworkError.httpError(httpResponse.statusCode)
                }
                
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                } else if error is DecodingError {
                    return NetworkError.decodingError(error)
                } else {
                    return NetworkError.unknown(error)
                }
            }
            .eraseToAnyPublisher()
    }
} 