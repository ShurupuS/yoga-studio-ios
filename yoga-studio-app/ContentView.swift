//
//  ContentView.swift
//  yoga-studio-app
//
//  Created by Alexey Kochetov on 22.10.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // MARK: - Environment Objects
    @EnvironmentObject private var dependencyContainer: DependencyContainer
    @EnvironmentObject private var logger: Logger
    @EnvironmentObject private var errorHandler: ErrorHandler
    
    // MARK: - State
    @State private var isShowingArchitectureDemo = false
    @State private var isShowingLogs = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "figure.yoga")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Yoga Studio App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Offline-First Architecture")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Architecture Status
                VStack(spacing: 16) {
                    ArchitectureStatusCard()
                    
                    NetworkStatusCard()
                    
                    ServicesStatusCard()
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button("View Architecture Demo") {
                        isShowingArchitectureDemo = true
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("View Logs") {
                        isShowingLogs = true
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Test Error Handling") {
                        testErrorHandling()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
                .padding(.bottom, 40)
            }
            .padding()
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $isShowingArchitectureDemo) {
            ArchitectureDemoView()
        }
        .sheet(isPresented: $isShowingLogs) {
            LogsView()
        }
        .alert("Error", isPresented: .constant(errorHandler.lastError != nil)) {
            Button("OK") {
                errorHandler.clearError()
            }
        } message: {
            if let error = errorHandler.lastError {
                Text(error.displayMessage)
            }
        }
    }
    
    // MARK: - Actions
    
    private func testErrorHandling() {
        let testError = AppError.data(.saveFailed)
        errorHandler.handle(testError, context: "ContentView")
        logger.warning("🧪 Testing error handling system")
    }
}

// MARK: - Status Cards

struct ArchitectureStatusCard: View {
    @EnvironmentObject private var logger: Logger
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Architecture Status")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                StatusRow(title: "SwiftData Container", isActive: true)
                StatusRow(title: "Dependency Injection", isActive: true)
                StatusRow(title: "Error Handling", isActive: true)
                StatusRow(title: "Logging System", isActive: true)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct NetworkStatusCard: View {
    @EnvironmentObject private var networkManager: NetworkManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: networkManager.isConnected ? "wifi" : "wifi.slash")
                    .foregroundColor(networkManager.isConnected ? .green : .orange)
                Text("Network Status")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                StatusRow(title: "Connection", isActive: networkManager.isConnected)
                StatusRow(title: "Type: \(networkManager.connectionType.rawValue)", isActive: networkManager.isConnected)
                StatusRow(title: "Quality: \(networkManager.networkQuality.rawValue)", isActive: networkManager.isConnected)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ServicesStatusCard: View {
    @EnvironmentObject private var dependencyContainer: DependencyContainer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.blue)
                Text("Services Status")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                StatusRow(title: "Authentication Service", isActive: dependencyContainer.authenticationService != nil)
                StatusRow(title: "Member Service", isActive: dependencyContainer.memberService != nil)
                StatusRow(title: "Class Service", isActive: dependencyContainer.classService != nil)
                StatusRow(title: "Booking Service", isActive: dependencyContainer.bookingService != nil)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatusRow: View {
    let title: String
    let isActive: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isActive ? .green : .gray)
                .font(.caption)
            Text(title)
                .font(.caption)
            Spacer()
        }
    }
}

// MARK: - Demo Views

struct ArchitectureDemoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Offline-First Architecture")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    ArchitectureFeature(
                        title: "SwiftData Container",
                        description: "Local-first data persistence with automatic relationships",
                        icon: "externaldrive.fill"
                    )
                    
                    ArchitectureFeature(
                        title: "Dependency Injection",
                        description: "Centralized service management and dependency resolution",
                        icon: "puzzlepiece.fill"
                    )
                    
                    ArchitectureFeature(
                        title: "Error Handling",
                        description: "Comprehensive error management with user-friendly messages",
                        icon: "exclamationmark.triangle.fill"
                    )
                    
                    ArchitectureFeature(
                        title: "Logging System",
                        description: "Centralized logging with performance monitoring",
                        icon: "doc.text.fill"
                    )
                    
                    ArchitectureFeature(
                        title: "Network Manager",
                        description: "Connectivity monitoring and API communication",
                        icon: "network"
                    )
                }
                .padding()
            }
            .navigationTitle("Architecture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ArchitectureFeature: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct LogsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var logger: Logger
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(logger.logs.suffix(50)) { logEntry in
                        LogEntryView(logEntry: logEntry)
                    }
                }
                .padding()
            }
            .navigationTitle("Logs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear") {
                        logger.clearLogs()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct LogEntryView: View {
    let logEntry: LogEntry
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(logEntry.level.emoji)
                .font(.caption)
            
            Text(logEntry.formattedTimestamp)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            
            Text(logEntry.message)
                .font(.caption)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(4)
    }
}

#Preview {
    ContentView()
        .environmentObject(DependencyContainer.shared)
        .environmentObject(Logger.shared)
        .environmentObject(ErrorHandler(logger: Logger.shared))
}
