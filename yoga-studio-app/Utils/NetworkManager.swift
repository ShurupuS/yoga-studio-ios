import Foundation
import Network

/// Network manager for handling API communication and connectivity monitoring
@MainActor
class NetworkManager: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var connectionType: ConnectionType = .none
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private let logger: Logger
    
    // MARK: - Configuration
    private let baseURL = "https://api.yogastudio.com" // Future backend URL
    private let timeout: TimeInterval = 30.0
    
    init(logger: Logger = Logger()) {
        self.logger = logger
        startNetworkMonitoring()
        logger.log("✅ NetworkManager initialized", level: .info)
    }
    
    deinit {
        monitor.cancel()
    }
    
    // MARK: - Network Monitoring
    
    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.updateConnectionStatus(path: path)
            }
        }
        monitor.start(queue: queue)
    }
    
    private func updateConnectionStatus(path: NWPath) {
        let wasConnected = isConnected
        isConnected = path.status == .satisfied
        
        // Update connection type
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .none
        }
        
        // Log connection changes
        if wasConnected != isConnected {
            if isConnected {
                logger.log("🌐 Network connected via \(connectionType.rawValue)", level: .info)
            } else {
                logger.log("🌐 Network disconnected", level: .warning)
            }
        }
    }
    
    // MARK: - API Communication (Future Backend Integration)
    
    /// Make HTTP request (prepared for future backend)
    func makeRequest<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Data? = nil,
        responseType: T.Type
    ) async throws -> T {
        
        guard isConnected else {
            throw NetworkError.noConnection
        }
        
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        logger.log("🌐 Making \(method.rawValue) request to \(endpoint)", level: .debug)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            logger.log("✅ Request successful: \(endpoint)", level: .debug)
            return decodedResponse
            
        } catch {
            logger.log("❌ Request failed: \(endpoint) - \(error.localizedDescription)", level: .error)
            throw NetworkError.requestFailed(error.localizedDescription)
        }
    }
    
    /// Upload data (prepared for future backend)
    func uploadData(
        endpoint: String,
        data: Data,
        fileName: String,
        mimeType: String
    ) async throws -> Data {
        
        guard isConnected else {
            throw NetworkError.noConnection
        }
        
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = timeout
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        logger.log("🌐 Uploading file: \(fileName)", level: .debug)
        
        do {
            let (responseData, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            logger.log("✅ Upload successful: \(fileName)", level: .debug)
            return responseData
            
        } catch {
            logger.log("❌ Upload failed: \(fileName) - \(error.localizedDescription)", level: .error)
            throw NetworkError.requestFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Offline-First Support
    
    /// Check if network is available for sync operations
    var canSync: Bool {
        return isConnected && connectionType != .none
    }
    
    /// Get network quality indicator
    var networkQuality: NetworkQuality {
        switch connectionType {
        case .wifi, .ethernet:
            return .excellent
        case .cellular:
            return .good
        case .none:
            return .poor
        }
    }
}

// MARK: - Supporting Types

enum ConnectionType: String, CaseIterable {
    case wifi = "WiFi"
    case cellular = "Cellular"
    case ethernet = "Ethernet"
    case none = "None"
}

enum NetworkQuality: String, CaseIterable {
    case excellent = "Excellent"
    case good = "Good"
    case poor = "Poor"
}

enum HTTPMethod: String, CaseIterable {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

enum NetworkError: LocalizedError, Equatable {
    case noConnection
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case requestFailed(String)
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No internet connection available"
        case .invalidURL:
            return "Invalid URL provided"
        case .invalidResponse:
            return "Invalid response received"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .requestFailed(let message):
            return "Request failed: \(message)"
        case .decodingError(let message):
            return "Failed to decode response: \(message)"
        }
    }
}

// MARK: - Mock API Responses (For Testing)

struct MockAPIResponse: Codable {
    let success: Bool
    let message: String
    let data: [String: String]?
}

extension NetworkManager {
    /// Mock API call for testing (will be replaced with real API)
    func mockAPICall() async throws -> MockAPIResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        return MockAPIResponse(
            success: true,
            message: "Mock API call successful",
            data: ["timestamp": "\(Date().timeIntervalSince1970)"]
        )
    }
}
