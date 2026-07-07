import Foundation
import UIKit

// MARK: - API Error
enum APIError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case networkError(Error)
    case serverError(statusCode: Int, message: String)
    case timeout
    case noInternet
    case unknown

    var localizedDescription: String {
        switch self {
        case .invalidURL:                           return "Invalid URL"
        case .noData:                               return "No data received"
        case .decodingError(let error):             return "Decoding failed: \(error.localizedDescription)"
        case .encodingError(let error):             return "Encoding failed: \(error.localizedDescription)"
        case .networkError(let error):              return "Network error: \(error.localizedDescription)"
        case .serverError(_, let message):          return message
        case .timeout:                              return "Request timed out"
        case .noInternet:                           return "No internet connection"
        case .unknown:                              return "Something went wrong"
        }
    }
}

// MARK: - HTTP Method
enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case patch  = "PATCH"
    case delete = "DELETE"
}

// MARK: - API Service Protocol
protocol APIServiceProtocol {
    func request<U: Codable>(
        endpoint: String,
        method: HTTPMethod,
        pathParams: [String: CustomStringConvertible]?,
        queryParams: [String: CustomStringConvertible?]?,
        body: [String:Any]?,
        headers: [String: String]?,
        requiresAuth: Bool
    ) async throws -> U
}

// MARK: - Generic API Service
class APIService: APIServiceProtocol {

    static let shared = APIService()

    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init(baseURL: String = Constants.ServiceConfiguration.baseURL) {
        self.baseURL = baseURL

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)

        self.decoder = JSONDecoder()
        // ✅ handles snake_case → camelCase automatically
        //self.decoder.keyDecodingStrategy = .convertFromSnakeCase

        self.encoder = JSONEncoder()
        //self.encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    // MARK: - Main Request Method
    func request<U: Codable>(
        endpoint: String,
        method: HTTPMethod = .get,
        pathParams: [String: CustomStringConvertible]? = nil,
        queryParams: [String: CustomStringConvertible?]? = nil,
        body: [String: Any]? = nil,
        headers: [String: String]? = nil,
        requiresAuth: Bool = true
    ) async throws -> U {

        // 1. Resolve path params
        var resolvedEndpoint = endpoint
        pathParams?.forEach {
            resolvedEndpoint = resolvedEndpoint.replacingOccurrences(of: "{\($0.key)}", with: "\($0.value)")
        }

        // 2. Build URL with query params todo //baseURL
        guard var components = URLComponents(string: baseURL + resolvedEndpoint) else {
            throw APIError.invalidURL
        }

        if let queryParams {
            components.queryItems = queryParams
                .compactMapValues { $0 }
                .filter { !($0.value is NSNull) }
                .map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            print("components.queryItems \(components.queryItems as Any)")
        }

        guard let url = components.url else { throw APIError.invalidURL }

        // 3. Build request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if body != nil && method != .get {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if requiresAuth, let token = UserDefaults.standard.authToken {
            print("requiresAuth Bearer \(token)")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        if let body, method != .get {
            do {
                let data = try JSONSerialization.data(withJSONObject: body, options: [])
                //print(String(data: data, encoding: .utf8)!)
                print("📡 body \(String(data: data, encoding: .utf8)!)")
                request.httpBody = data
            } catch {
                throw APIError.encodingError(error)
            }
        }

        // 4. Execute
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            throw handleURLError(urlError)
        } catch {
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else { throw APIError.unknown }

        print("📡 \(method.rawValue) \(url.absoluteString)")
        print("📡 Status: \(httpResponse.statusCode)")
       // print("📡 Response: \(data.inString.toJSON() as Any)")

        // 5. Handle response
        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try decoder.decode(U.self, from: data)
            } catch {
                print("❌ decoding error: \(error)")
                throw APIError.decodingError(error)  // ✅ fixed: was throwing encodingError by mistake
            }
        case 400...499:
            return try decoder.decode(U.self, from: data)
//            throw APIError.serverError(statusCode: httpResponse.statusCode, message: parseErrorMessage(from: data))
        case 500...599:
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Server error occurred")
        default:
            throw APIError.unknown
        }
    }



    
    // MARK: - Convenience: GET
    func get<U: Codable>(
        endpoint: String,
        headers: [String: String]? = nil,
        queryItems: [String: Any]? = nil,
        requiresAuth: Bool = true
    ) async throws -> U {
        let convertedQuery: [String: CustomStringConvertible?]? = queryItems?.mapValues { value in
            if let convertible = value as? CustomStringConvertible { return convertible }
            return String(describing: value)
        }
        return try await request(endpoint: endpoint, method: .get, pathParams: nil, queryParams: convertedQuery, body: EmptyBody?.none?.toJson(), headers: headers, requiresAuth: requiresAuth)
    }

    // MARK: - Convenience: POST
    func post<U: Codable>(
        endpoint: String,
        body: [String: Any],
        headers: [String: String]? = nil,
        requiresAuth: Bool = true
    ) async throws -> U {
        return try await request(endpoint: endpoint, method: .post, body: body, headers: headers, requiresAuth: requiresAuth)
    }

    // MARK: - Convenience: PUT
    func put<U: Codable>(
        endpoint: String,
        body: [String:Any],
        headers: [String: String]? = nil,
        requiresAuth: Bool = true
    ) async throws -> U {
        return try await request(endpoint: endpoint, method: .put, body: body, headers: headers, requiresAuth: requiresAuth)
    }

    // MARK: - Convenience: DELETE
    func delete<U: Codable>(
        endpoint: String,
        headers: [String: String]? = nil,
        requiresAuth: Bool = true
    ) async throws -> U {
        return try await request(endpoint: endpoint, method: .delete, body: EmptyBody?.none?.toJson(), headers: headers, requiresAuth: requiresAuth)
    }

    // MARK: - Helpers
    private func handleURLError(_ error: URLError) -> APIError {
        switch error.code {
        case .timedOut:                                                             return .timeout
        case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost: return .noInternet
        default:                                                                    return .networkError(error)
        }
    }

    private func parseErrorMessage(from data: Data) -> String {
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let message = json["message"] as? String { return message }
            if let errors = json["errors"] as? [String: Any],
               let firstError = errors.values.first as? [String],
               let firstMessage = firstError.first { return firstMessage }
        }
        return "An error occurred"
    }
}

// MARK: - Empty Body
struct EmptyBody: Codable {}

// MARK: - Encodable Helper
extension Encodable {
    func toStrJson() -> [String: Any]? {
        guard let jsonData = try? JSONEncoder().encode(self),
              let str = String(data: jsonData, encoding: .utf8) else { return nil }
        return str.toJSON()
    }

    func toJson() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
    }
}


extension Array where Element: Encodable {
    func inJson() -> [[String: Any]]? {
        guard let data = try? JSONEncoder().encode(self),
              let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return nil
        }
        return json
    }
}
