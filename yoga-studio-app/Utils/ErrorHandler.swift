import Foundation
import Combine

/// Centralized error handling system for the app
class ErrorHandler: ObservableObject {
    @Published var lastError: AppError?
    @Published var errorCount: Int = 0
    
    private let logger: Logger
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    // MARK: - Error Handling
    
    /// Handle and log an error
    func handle(_ error: Error, context: String = "") {
        let appError = AppError.from(error, context: context)
        
        DispatchQueue.main.async {
            self.lastError = appError
            self.errorCount += 1
        }
        
        logger.log("❌ Error in \(context): \(appError.localizedDescription)", level: .error)
        
        // Log additional details for debugging
        if let underlyingError = appError.underlyingError {
            logger.log("❌ Underlying error: \(underlyingError)", level: .debug)
        }
    }
    
    /// Handle a specific app error
    func handle(_ appError: AppError, context: String = "") {
        DispatchQueue.main.async {
            self.lastError = appError
            self.errorCount += 1
        }
        
        logger.log("❌ App error in \(context): \(appError.localizedDescription)", level: .error)
    }
    
    /// Clear the last error
    func clearError() {
        DispatchQueue.main.async {
            self.lastError = nil
        }
    }
    
    /// Reset error count
    func resetErrorCount() {
        DispatchQueue.main.async {
            self.errorCount = 0
        }
    }
    
    // MARK: - Error Recovery
    
    /// Attempt to recover from an error
    func attemptRecovery(from error: AppError) async -> Bool {
        logger.log("🔄 Attempting recovery from error: \(error.localizedDescription)", level: .info)
        
        switch error.type {
        case .network:
            // Network errors might resolve themselves
            return true
            
        case .data:
            // Data errors might need user intervention
            return false
            
        case .authentication:
            // Authentication errors might need re-login
            return false
            
        case .validation:
            // Validation errors need user input correction
            return false
            
        case .system:
            // System errors might need app restart
            return false
            
        case .unknown:
            // Unknown errors are unpredictable
            return false
        }
    }
}

// MARK: - App Error Types

/// Centralized error types for the app
enum AppError: LocalizedError {
    case network(NetworkError)
    case data(DataError)
    case authentication(AuthenticationError)
    case validation(ValidationError)
    case system(SystemError)
    case unknown(String)
    
    var type: ErrorType {
        switch self {
        case .network:
            return .network
        case .data:
            return .data
        case .authentication:
            return .authentication
        case .validation:
            return .validation
        case .system:
            return .system
        case .unknown:
            return .unknown
        }
    }
    
    var underlyingError: Error? {
        switch self {
        case .network(let error):
            return error
        case .data(let error):
            return error
        case .authentication(let error):
            return error
        case .validation(let error):
            return error
        case .system(let error):
            return error
        case .unknown(let message):
            return NSError(domain: "AppError", code: -1, userInfo: [NSLocalizedDescriptionKey: message])
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .network(let error):
            return "Network Error: \(error.localizedDescription)"
        case .data(let error):
            return "Data Error: \(error.localizedDescription)"
        case .authentication(let error):
            return "Authentication Error: \(error.localizedDescription)"
        case .validation(let error):
            return "Validation Error: \(error.localizedDescription)"
        case .system(let error):
            return "System Error: \(error.localizedDescription)"
        case .unknown(let message):
            return "Unknown Error: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .network:
            return "Check your internet connection and try again."
        case .data:
            return "The data might be corrupted. Please try again or contact support."
        case .authentication:
            return "Please log in again to continue."
        case .validation:
            return "Please check your input and try again."
        case .system:
            return "Please restart the app and try again."
        case .unknown:
            return "An unexpected error occurred. Please try again."
        }
    }
    
    static func from(_ error: Error, context: String = "") -> AppError {
        if let networkError = error as? NetworkError {
            return .network(networkError)
        } else if let dataError = error as? DataError {
            return .data(dataError)
        } else if let authError = error as? AuthenticationError {
            return .authentication(authError)
        } else if let validationError = error as? ValidationError {
            return .validation(validationError)
        } else if let systemError = error as? SystemError {
            return .system(systemError)
        } else {
            return .unknown(error.localizedDescription)
        }
    }
}

enum ErrorType: String, CaseIterable {
    case network = "Network"
    case data = "Data"
    case authentication = "Authentication"
    case validation = "Validation"
    case system = "System"
    case unknown = "Unknown"
}

// MARK: - Specific Error Types

enum DataError: LocalizedError, Equatable {
    case saveFailed
    case loadFailed
    case deleteFailed
    case notFound
    case invalidFormat
    case syncFailed
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save data"
        case .loadFailed:
            return "Failed to load data"
        case .deleteFailed:
            return "Failed to delete data"
        case .notFound:
            return "Data not found"
        case .invalidFormat:
            return "Invalid data format"
        case .syncFailed:
            return "Failed to sync data"
        }
    }
}

enum AuthenticationError: LocalizedError, Equatable {
    case invalidCredentials
    case userNotFound
    case sessionExpired
    case registrationFailed
    case logoutFailed
    case biometricNotAvailable
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .userNotFound:
            return "User not found"
        case .sessionExpired:
            return "Session expired. Please log in again."
        case .registrationFailed:
            return "Registration failed"
        case .logoutFailed:
            return "Logout failed"
        case .biometricNotAvailable:
            return "Biometric authentication not available"
        }
    }
}

enum ValidationError: LocalizedError, Equatable {
    case invalidEmail
    case invalidPhone
    case passwordTooShort
    case passwordMismatch
    case requiredFieldMissing
    case invalidDate
    case invalidNumber
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address"
        case .invalidPhone:
            return "Please enter a valid phone number"
        case .passwordTooShort:
            return "Password must be at least 8 characters"
        case .passwordMismatch:
            return "Passwords do not match"
        case .requiredFieldMissing:
            return "Please fill in all required fields"
        case .invalidDate:
            return "Please enter a valid date"
        case .invalidNumber:
            return "Please enter a valid number"
        }
    }
}

enum SystemError: LocalizedError, Equatable {
    case storageFull
    case permissionDenied
    case deviceNotSupported
    case appVersionOutdated
    case systemResourceUnavailable
    
    var errorDescription: String? {
        switch self {
        case .storageFull:
            return "Device storage is full"
        case .permissionDenied:
            return "Permission denied"
        case .deviceNotSupported:
            return "Device not supported"
        case .appVersionOutdated:
            return "App version is outdated"
        case .systemResourceUnavailable:
            return "System resource unavailable"
        }
    }
}

// MARK: - Error Display

extension AppError {
    var displayTitle: String {
        switch self {
        case .network:
            return "Connection Error"
        case .data:
            return "Data Error"
        case .authentication:
            return "Authentication Error"
        case .validation:
            return "Validation Error"
        case .system:
            return "System Error"
        case .unknown:
            return "Error"
        }
    }
    
    var displayMessage: String {
        return errorDescription ?? "An error occurred"
    }
    
    var shouldShowRetryButton: Bool {
        switch self {
        case .network, .data:
            return true
        case .authentication, .validation, .system, .unknown:
            return false
        }
    }
}
