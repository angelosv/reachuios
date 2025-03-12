import Foundation
import Combine

// MARK: - Apollo Manager
/// This class provides a wrapper around Apollo GraphQL client
/// It is designed to work independently from the existing Reachu implementation
class ApolloManager {
    // Singleton instance
    static let shared = ApolloManager()
    
    // MARK: - Properties
    private let endpointURL = URL(string: "https://graph-ql.reachu.io/")!
    private let authToken = "ZN7EYWW-ZVX4PD9-Q74031G-MXTHK3R" // Same token as ReachuGraphQLService
    
    // MARK: - Cache Configuration
    /// When Apollo is fully integrated, this will be replaced with a proper Apollo cache
    private var cache: [String: Any] = [:]
    private let cacheExpirationTime: TimeInterval = 5 * 60 // 5 minutes
    private var cacheTimestamps: [String: Date] = [:]
    
    // MARK: - Initialization
    private init() {
        print("🚀 Apollo Manager initialized")
    }
    
    // MARK: - Error Types
    enum ApolloError: Error, LocalizedError {
        case invalidResponse
        case networkError(Error)
        case decodingError(Error)
        case serverError(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidResponse:
                return "Invalid response from server"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .decodingError(let error):
                return "Error processing response: \(error.localizedDescription)"
            case .serverError(let message):
                return "Server error: \(message)"
            }
        }
    }
    
    // MARK: - Cache Policies
    enum CachePolicy {
        case fetchIgnoringCache // Always fetch from network
        case returnCacheDataElseFetch // Return cache if available and not expired, else fetch
        case returnCacheDataAndFetch // Return cache if available, but also fetch in background
        case returnCacheDataDontFetch // Return cache if available, don't fetch
    }
    
    // MARK: - GraphQL Operations
    /// Performs a GraphQL query using URLSession with cache support
    func performQuery<T: Decodable>(
        query: String,
        variables: [String: Any]? = nil,
        decodingType: T.Type,
        cachePolicy: CachePolicy = .returnCacheDataElseFetch
    ) -> AnyPublisher<T, Error> {
        // Create cache key
        let cacheKey = createCacheKey(query: query, variables: variables)
        
        // Check if we should return cached data
        if cachePolicy != .fetchIgnoringCache, 
           let cachedData = getCachedData(for: cacheKey, type: decodingType) {
            
            // If we should return cache and not fetch, return immediately
            if cachePolicy == .returnCacheDataDontFetch {
                return Just(cachedData)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            
            // If we should return cache and fetch in background
            if cachePolicy == .returnCacheDataAndFetch {
                // Return cached data immediately
                let cachedPublisher = Just(cachedData)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
                
                // Also fetch in background
                fetchFromNetwork(query: query, variables: variables, cacheKey: cacheKey, decodingType: decodingType)
                
                return cachedPublisher
            }
            
            // For returnCacheDataElseFetch, check if cache is expired
            if cachePolicy == .returnCacheDataElseFetch,
               let timestamp = cacheTimestamps[cacheKey],
               Date().timeIntervalSince(timestamp) < cacheExpirationTime {
                
                return Just(cachedData)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        }
        
        // If we reach here, we need to fetch from network
        return fetchFromNetwork(query: query, variables: variables, cacheKey: cacheKey, decodingType: decodingType)
    }
    
    // MARK: - Private Helper Methods
    
    /// Creates a cache key from query and variables
    private func createCacheKey(query: String, variables: [String: Any]?) -> String {
        var key = query
        if let variables = variables {
            do {
                let variablesData = try JSONSerialization.data(withJSONObject: variables)
                if let variablesString = String(data: variablesData, encoding: .utf8) {
                    key += variablesString
                }
            } catch {
                print("Error serializing variables for cache key: \(error)")
            }
        }
        return key.md5
    }
    
    /// Gets cached data if available
    private func getCachedData<T: Decodable>(for key: String, type: T.Type) -> T? {
        if let cachedData = cache[key] as? T {
            print("🔄 Apollo Manager using cached data for key: \(key)")
            return cachedData
        }
        return nil
    }
    
    /// Fetches data from network and caches it
    private func fetchFromNetwork<T: Decodable>(
        query: String,
        variables: [String: Any]?,
        cacheKey: String,
        decodingType: T.Type
    ) -> AnyPublisher<T, Error> {
        print("🌐 Apollo Manager fetching from network for key: \(cacheKey)")
        
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(authToken, forHTTPHeaderField: "Authorization")
        
        var body: [String: Any] = ["query": query]
        if let variables = variables {
            body["variables"] = variables
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw ApolloError.invalidResponse
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw ApolloError.serverError("Server returned status code \(httpResponse.statusCode)")
                }
                
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .handleEvents(receiveOutput: { [weak self] value in
                // Cache the result
                self?.cache[cacheKey] = value
                self?.cacheTimestamps[cacheKey] = Date()
                print("💾 Apollo Manager cached data for key: \(cacheKey)")
            })
            .mapError { error in
                if let apolloError = error as? ApolloError {
                    return apolloError
                } else if error is DecodingError {
                    return ApolloError.decodingError(error)
                } else {
                    return ApolloError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Cache Management
    
    /// Clears all cached data
    func clearCache() {
        cache.removeAll()
        cacheTimestamps.removeAll()
        print("🧹 Apollo Manager cleared all cache")
    }
    
    /// Clears cached data for a specific query
    func clearCache(for query: String, variables: [String: Any]? = nil) {
        let cacheKey = createCacheKey(query: query, variables: variables)
        cache.removeValue(forKey: cacheKey)
        cacheTimestamps.removeValue(forKey: cacheKey)
        print("🧹 Apollo Manager cleared cache for key: \(cacheKey)")
    }
}

// MARK: - String Extension for MD5
extension String {
    var md5: String {
        let data = Data(self.utf8)
        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Future Implementation
// TODO: Add Apollo Client implementation
// This will be implemented once we add the Apollo package dependency
// For now, we're using a simple in-memory cache with expiration