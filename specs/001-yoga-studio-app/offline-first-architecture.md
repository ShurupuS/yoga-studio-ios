# Offline-First Architecture Guide

## Overview

This document outlines the offline-first architecture strategy for the Yoga Studio App, ensuring the application works perfectly without internet connectivity while preparing for future backend integration.

## Core Principles

### 1. Local Data Priority
- **All data operations** happen locally first using SwiftData
- **Immediate persistence** of all user actions
- **No network dependency** for core functionality

### 2. Eventual Consistency
- **Background sync** when network is available
- **Conflict resolution** strategies for data conflicts
- **Graceful degradation** when offline

### 3. User Experience
- **Instant responsiveness** from local data
- **Clear offline indicators** in UI
- **Seamless transition** between online/offline states

## Data Flow Architecture

### Write Operations
```
User Action → SwiftData (Local) → Sync Queue → Backend (Future)
     ↓              ↓                ↓
  Immediate      Instant UI      Background
  Response       Update          Sync
```

### Read Operations
```
UI Request → SwiftData Query → Local Data → Instant Display
     ↓              ↓              ↓
  @Query        @Model         Immediate
  Binding       Objects        Response
```

## SwiftData Models with Sync Metadata

### Base Sync Properties
All models should include sync metadata:

```swift
import SwiftData

@Model
class BaseModel {
    var id: UUID
    var createdAt: Date
    var updatedAt: Date
    var syncStatus: SyncStatus
    var lastSyncedAt: Date?
    var syncVersion: Int
    
    init() {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.syncStatus = .pending
        self.lastSyncedAt = nil
        self.syncVersion = 1
    }
}

enum SyncStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case syncing = "syncing"
    case synced = "synced"
    case conflict = "conflict"
    case error = "error"
}
```

### Example: Member Model
```swift
@Model
class Member: BaseModel {
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: String?
    var subscription: Subscription?
    var bookings: [Booking] = []
    
    init(firstName: String, lastName: String, email: String) {
        super.init()
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
}
```

## Sync Manager Architecture

### SyncManager Responsibilities
1. **Change Tracking**: Monitor all data modifications
2. **Queue Management**: Manage sync queue for offline operations
3. **Conflict Resolution**: Handle data conflicts intelligently
4. **Status Monitoring**: Track sync status across the app

### Implementation Strategy
```swift
class SyncManager: ObservableObject {
    @Published var isOnline: Bool = false
    @Published var syncStatus: SyncStatus = .pending
    @Published var pendingChanges: Int = 0
    
    private let modelContext: ModelContext
    private var syncQueue: [SyncOperation] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        startNetworkMonitoring()
    }
    
    // Mark changes for sync
    func markForSync<T: BaseModel>(_ object: T) {
        object.syncStatus = .pending
        object.updatedAt = Date()
        syncQueue.append(SyncOperation(object: object))
    }
    
    // Background sync when online
    func syncWhenOnline() {
        guard isOnline else { return }
        processSyncQueue()
    }
}
```

## Conflict Resolution Strategy

### Last-Write-Wins with User Notification
```swift
enum ConflictResolutionStrategy {
    case lastWriteWins
    case userChoice
    case mergeFields
}

class ConflictResolver {
    func resolveConflict<T: BaseModel>(
        local: T,
        remote: T,
        strategy: ConflictResolutionStrategy = .lastWriteWins
    ) -> T {
        switch strategy {
        case .lastWriteWins:
            return local.updatedAt > remote.updatedAt ? local : remote
        case .userChoice:
            // Present conflict resolution UI to user
            return presentConflictResolutionUI(local: local, remote: remote)
        case .mergeFields:
            return mergeFields(local: local, remote: remote)
        }
    }
}
```

## Offline Indicators

### UI Components
```swift
struct OfflineIndicator: View {
    @EnvironmentObject var syncManager: SyncManager
    
    var body: some View {
        HStack {
            Image(systemName: syncManager.isOnline ? "wifi" : "wifi.slash")
                .foregroundColor(syncManager.isOnline ? .green : .orange)
            
            if !syncManager.isOnline {
                Text("Offline")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            if syncManager.pendingChanges > 0 {
                Text("\(syncManager.pendingChanges) pending")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
    }
}
```

## Network Monitoring

### Connectivity Detection
```swift
import Network

class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected = false
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}
```

## Data Migration Strategy

### From Offline to Online
1. **Phase 1**: Complete offline functionality
2. **Phase 2**: Add sync metadata to existing models
3. **Phase 3**: Implement SyncManager
4. **Phase 4**: Add backend API integration
5. **Phase 5**: Enable real-time sync

### Migration Steps
```swift
class DataMigrationManager {
    func migrateToSyncEnabled() {
        // Add sync metadata to existing records
        let members = try? modelContext.fetch(FetchDescriptor<Member>())
        members?.forEach { member in
            if member.syncStatus == nil {
                member.syncStatus = .pending
                member.syncVersion = 1
            }
        }
    }
}
```

## Testing Strategy

### Offline Testing
- **Airplane Mode**: Test all features without network
- **Network Interruption**: Test sync recovery
- **Conflict Scenarios**: Test conflict resolution
- **Data Integrity**: Verify data consistency

### Sync Testing
- **Mock Backend**: Test sync with mock API
- **Conflict Resolution**: Test various conflict scenarios
- **Performance**: Test sync performance with large datasets

## Benefits of This Approach

### Immediate Benefits
- ✅ **Works everywhere**: No internet required
- ✅ **Instant response**: Local data queries
- ✅ **Reliable**: No network dependency
- ✅ **Fast**: No network latency

### Future Benefits
- ✅ **Easy backend integration**: Sync layer already prepared
- ✅ **Multi-device sync**: Share data across devices
- ✅ **Cloud backup**: Automatic data protection
- ✅ **Real-time updates**: When backend is ready

## Implementation Timeline

### Phase 1: Offline Foundation (Weeks 1-4)
- SwiftData models with sync metadata
- Local-first data operations
- Offline indicators in UI

### Phase 2: Sync Preparation (Weeks 5-6)
- SyncManager implementation
- Conflict resolution system
- Network monitoring

### Phase 3: Backend Integration (Future)
- API client implementation
- Real-time sync
- Multi-device support

This architecture ensures the app provides immediate value while being perfectly positioned for future backend integration.
