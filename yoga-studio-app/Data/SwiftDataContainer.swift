import SwiftData
import Foundation

/// SwiftData container configuration for offline-first architecture
@MainActor
class SwiftDataContainer: ObservableObject {
    static let shared = SwiftDataContainer()
    
    let modelContainer: ModelContainer
    
    private init() {
        do {
            // Configure SwiftData models for offline-first storage
            let schema = Schema([
                StudioOwner.self,
                Member.self,
                YogaClass.self,
                Booking.self,
                Subscription.self,
                Payment.self,
                AttendanceRecord.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            print("✅ SwiftData container initialized successfully")
        } catch {
            fatalError("❌ Failed to initialize SwiftData container: \(error)")
        }
    }
    
    /// Get the model context for data operations
    var modelContext: ModelContext {
        modelContainer.mainContext
    }
    
    /// Save changes to the persistent store
    func save() {
        do {
            try modelContext.save()
            print("✅ Data saved successfully")
        } catch {
            print("❌ Failed to save data: \(error)")
        }
    }
    
    /// Delete all data (for testing purposes)
    func deleteAllData() {
        do {
            try modelContext.delete(model: StudioOwner.self)
            try modelContext.delete(model: Member.self)
            try modelContext.delete(model: YogaClass.self)
            try modelContext.delete(model: Booking.self)
            try modelContext.delete(model: Subscription.self)
            try modelContext.delete(model: Payment.self)
            try modelContext.delete(model: AttendanceRecord.self)
            save()
            print("✅ All data deleted")
        } catch {
            print("❌ Failed to delete data: \(error)")
        }
    }
}

// MARK: - Model Definitions (Temporary - will be moved to separate files)

import SwiftData

/// Base model with sync metadata for offline-first architecture
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

/// Sync status for offline-first data management
enum SyncStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case syncing = "syncing"
    case synced = "synced"
    case conflict = "conflict"
    case error = "error"
}

/// Studio Owner model
@Model
class StudioOwner: BaseModel {
    var email: String
    var firstName: String
    var lastName: String
    var studioName: String
    
    init(email: String, firstName: String, lastName: String, studioName: String) {
        super.init()
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.studioName = studioName
    }
}

/// Member model
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

/// Yoga Class model
@Model
class YogaClass: BaseModel {
    var name: String
    var description: String
    var instructorName: String
    var category: ClassCategory
    var capacity: Int
    var duration: Int // in minutes
    var startTime: Date
    var endTime: Date
    var bookings: [Booking] = []
    
    init(name: String, description: String, instructorName: String, category: ClassCategory, capacity: Int, duration: Int, startTime: Date) {
        super.init()
        self.name = name
        self.description = description
        self.instructorName = instructorName
        self.category = category
        self.capacity = capacity
        self.duration = duration
        self.startTime = startTime
        self.endTime = startTime.addingTimeInterval(TimeInterval(duration * 60))
    }
}

/// Class Category enum
enum ClassCategory: String, Codable, CaseIterable {
    case hatha = "hatha"
    case vinyasa = "vinyasa"
    case yin = "yin"
    case restorative = "restorative"
    case power = "power"
    case meditation = "meditation"
    case beginner = "beginner"
    case advanced = "advanced"
}

/// Booking model
@Model
class Booking: BaseModel {
    var member: Member?
    var yogaClass: YogaClass?
    var status: BookingStatus
    var bookedAt: Date
    var notes: String?
    
    init(member: Member?, yogaClass: YogaClass?, status: BookingStatus = .confirmed) {
        super.init()
        self.member = member
        self.yogaClass = yogaClass
        self.status = status
        self.bookedAt = Date()
    }
}

/// Booking Status enum
enum BookingStatus: String, Codable, CaseIterable {
    case confirmed = "confirmed"
    case cancelled = "cancelled"
    case waitlist = "waitlist"
    case completed = "completed"
    case noShow = "no_show"
}

/// Subscription model
@Model
class Subscription: BaseModel {
    var member: Member?
    var plan: SubscriptionPlan
    var startDate: Date
    var endDate: Date
    var isActive: Bool
    var usageCount: Int
    var maxUsage: Int?
    
    init(member: Member?, plan: SubscriptionPlan, startDate: Date, endDate: Date, maxUsage: Int? = nil) {
        super.init()
        self.member = member
        self.plan = plan
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = true
        self.usageCount = 0
        self.maxUsage = maxUsage
    }
}

/// Subscription Plan enum
enum SubscriptionPlan: String, Codable, CaseIterable {
    case basic = "basic"
    case premium = "premium"
    case unlimited = "unlimited"
    case dropIn = "drop_in"
}

/// Payment model
@Model
class Payment: BaseModel {
    var member: Member?
    var amount: Double
    var currency: String
    var paymentType: PaymentType
    var status: PaymentStatus
    var transactionId: String?
    var paidAt: Date?
    
    init(member: Member?, amount: Double, currency: String = "USD", paymentType: PaymentType, status: PaymentStatus = .pending) {
        super.init()
        self.member = member
        self.amount = amount
        self.currency = currency
        self.paymentType = paymentType
        self.status = status
    }
}

/// Payment Type enum
enum PaymentType: String, Codable, CaseIterable {
    case subscription = "subscription"
    case dropIn = "drop_in"
    case workshop = "workshop"
    case merchandise = "merchandise"
}

/// Payment Status enum
enum PaymentStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case completed = "completed"
    case failed = "failed"
    case refunded = "refunded"
}

/// Attendance Record model
@Model
class AttendanceRecord: BaseModel {
    var member: Member?
    var yogaClass: YogaClass?
    var status: AttendanceStatus
    var checkedInAt: Date?
    var notes: String?
    
    init(member: Member?, yogaClass: YogaClass?, status: AttendanceStatus = .absent) {
        super.init()
        self.member = member
        self.yogaClass = yogaClass
        self.status = status
    }
}

/// Attendance Status enum
enum AttendanceStatus: String, Codable, CaseIterable {
    case present = "present"
    case absent = "absent"
    case late = "late"
    case excused = "excused"
}
