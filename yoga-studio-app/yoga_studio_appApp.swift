//
//  yoga_studio_appApp.swift
//  yoga-studio-app
//
//  Created by Alexey Kochetov on 22.10.2025.
//

import SwiftUI
import SwiftData

@main
struct yoga_studio_appApp: App {
    // MARK: - Dependencies
    @StateObject private var dependencyContainer = DependencyContainer.shared
    @StateObject private var logger = Logger.shared
    @StateObject private var errorHandler = ErrorHandler(logger: Logger.shared)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(dependencyContainer.swiftDataContainer.modelContainer)
                .environmentObject(dependencyContainer)
                .environmentObject(logger)
                .environmentObject(errorHandler)
                .onAppear {
                    initializeApp()
                }
        }
    }
    
    // MARK: - App Initialization
    
    private func initializeApp() {
        logger.info("🚀 Initializing Yoga Studio App")
        
        // Initialize core services
        dependencyContainer.initializeCoreServices()
        
        // Initialize optional services (for future features)
        dependencyContainer.initializeOptionalServices()
        
        logger.info("✅ App initialization completed")
        
        // Log system information
        logSystemInfo()
    }
    
    private func logSystemInfo() {
        let device = UIDevice.current
        let systemVersion = device.systemVersion
        let deviceModel = device.model
        
        logger.info("📱 Device: \(deviceModel) iOS \(systemVersion)")
        logger.logMemoryUsage()
    }
}
