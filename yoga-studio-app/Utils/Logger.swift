import Foundation
import os.log
import Combine

/// Centralized logging system for the app
class Logger: ObservableObject {
    static let shared = Logger()
    
    @Published var logs: [LogEntry] = []
    @Published var isLoggingEnabled: Bool = true
    
    private let osLog = OSLog(subsystem: "com.yogastudio.app", category: "general")
    private let maxLogEntries = 1000
    
    init() {
        log("✅ Logger initialized", level: .info)
    }
    
    // MARK: - Logging Methods
    
    /// Log a message with specified level
    func log(_ message: String, level: LogLevel = .info, category: String = "general", file: String = #file, function: String = #function, line: Int = #line) {
        guard isLoggingEnabled else { return }
        
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let timestamp = Date()
        
        let logEntry = LogEntry(
            timestamp: timestamp,
            level: level,
            category: category,
            message: message,
            file: fileName,
            function: function,
            line: line
        )
        
        // Add to in-memory logs
        DispatchQueue.main.async {
            self.logs.append(logEntry)
            
            // Keep only the last maxLogEntries
            if self.logs.count > self.maxLogEntries {
                self.logs.removeFirst(self.logs.count - self.maxLogEntries)
            }
        }
        
        // Log to system
        logToSystem(logEntry)
    }
    
    /// Log info message
    func info(_ message: String, category: String = "general", file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, category: category, file: file, function: function, line: line)
    }
    
    /// Log debug message
    func debug(_ message: String, category: String = "general", file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, category: category, file: file, function: function, line: line)
    }
    
    /// Log warning message
    func warning(_ message: String, category: String = "general", file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, category: category, file: file, function: function, line: line)
    }
    
    /// Log error message
    func error(_ message: String, category: String = "general", file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, category: category, file: file, function: function, line: line)
    }
    
    // MARK: - System Logging
    
    private func logToSystem(_ entry: LogEntry) {
        let osLogType: OSLogType
        
        switch entry.level {
        case .debug:
            osLogType = .debug
        case .info:
            osLogType = .info
        case .warning:
            osLogType = .default
        case .error:
            osLogType = .error
        }
        
        let logMessage = "[\(entry.category)] \(entry.message) (\(entry.file):\(entry.line))"
        os_log("%{public}@", log: osLog, type: osLogType, logMessage)
    }
    
    // MARK: - Log Management
    
    /// Clear all logs
    func clearLogs() {
        DispatchQueue.main.async {
            self.logs.removeAll()
        }
        log("🧹 Logs cleared", level: .info)
    }
    
    /// Export logs as text
    func exportLogs() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let logText = logs.map { entry in
            let timestamp = dateFormatter.string(from: entry.timestamp)
            return "[\(timestamp)] [\(entry.level.rawValue.uppercased())] [\(entry.category)] \(entry.message)"
        }.joined(separator: "\n")
        
        return logText
    }
    
    /// Save logs to file
    func saveLogsToFile() throws -> URL {
        let logText = exportLogs()
        let fileName = "yoga-studio-logs-\(Date().timeIntervalSince1970).txt"
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        try logText.write(to: fileURL, atomically: true, encoding: .utf8)
        
        log("💾 Logs saved to file: \(fileName)", level: .info)
        return fileURL
    }
    
    // MARK: - Filtering
    
    /// Get logs filtered by level
    func getLogs(level: LogLevel) -> [LogEntry] {
        return logs.filter { $0.level == level }
    }
    
    /// Get logs filtered by category
    func getLogs(category: String) -> [LogEntry] {
        return logs.filter { $0.category == category }
    }
    
    /// Get logs filtered by level and category
    func getLogs(level: LogLevel, category: String) -> [LogEntry] {
        return logs.filter { $0.level == level && $0.category == category }
    }
    
    // MARK: - Performance Logging
    
    /// Log performance metrics
    func logPerformance(_ operation: String, duration: TimeInterval, category: String = "performance") {
        let message = "⏱️ \(operation) took \(String(format: "%.3f", duration))s"
        log(message, level: .info, category: category)
    }
    
    /// Log memory usage
    func logMemoryUsage(category: String = "memory") {
        let memoryInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &memoryInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let memoryMB = Double(memoryInfo.resident_size) / 1024.0 / 1024.0
            log("🧠 Memory usage: \(String(format: "%.2f", memoryMB)) MB", level: .info, category: category)
        }
    }
}

// MARK: - Log Entry Model

struct LogEntry: Identifiable, Codable {
    let id = UUID()
    let timestamp: Date
    let level: LogLevel
    let category: String
    let message: String
    let file: String
    let function: String
    let line: Int
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: timestamp)
    }
    
    var formattedMessage: String {
        return "[\(level.emoji)] \(message)"
    }
}

// MARK: - Log Level

enum LogLevel: String, CaseIterable, Codable {
    case debug = "debug"
    case info = "info"
    case warning = "warning"
    case error = "error"
    
    var emoji: String {
        switch self {
        case .debug:
            return "🐛"
        case .info:
            return "ℹ️"
        case .warning:
            return "⚠️"
        case .error:
            return "❌"
        }
    }
    
    var color: String {
        switch self {
        case .debug:
            return "gray"
        case .info:
            return "blue"
        case .warning:
            return "orange"
        case .error:
            return "red"
        }
    }
}

// MARK: - Log Categories

struct LogCategory {
    static let general = "general"
    static let network = "network"
    static let data = "data"
    static let authentication = "authentication"
    static let ui = "ui"
    static let performance = "performance"
    static let memory = "memory"
    static let sync = "sync"
    static let error = "error"
}

// MARK: - Performance Measurement

class PerformanceTimer {
    private let startTime: CFAbsoluteTime
    private let operation: String
    private let logger: Logger
    private let category: String
    
    init(operation: String, logger: Logger = Logger.shared, category: String = LogCategory.performance) {
        self.startTime = CFAbsoluteTimeGetCurrent()
        self.operation = operation
        self.logger = logger
        self.category = category
        
        logger.debug("⏱️ Starting \(operation)", category: category)
    }
    
    deinit {
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        logger.logPerformance(operation, duration: duration, category: category)
    }
}

// MARK: - Convenience Extensions

extension Logger {
    /// Log network request
    func logNetworkRequest(_ request: URLRequest) {
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "unknown"
        debug("🌐 \(method) \(url)", category: LogCategory.network)
    }
    
    /// Log network response
    func logNetworkResponse(_ response: URLResponse, data: Data?) {
        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            let dataSize = data?.count ?? 0
            debug("🌐 Response: \(statusCode) (\(dataSize) bytes)", category: LogCategory.network)
        }
    }
    
    /// Log data operation
    func logDataOperation(_ operation: String, success: Bool) {
        let emoji = success ? "✅" : "❌"
        info("\(emoji) Data operation: \(operation)", category: LogCategory.data)
    }
    
    /// Log authentication event
    func logAuthEvent(_ event: String, success: Bool) {
        let emoji = success ? "🔐" : "🔓"
        info("\(emoji) Auth event: \(event)", category: LogCategory.authentication)
    }
}
