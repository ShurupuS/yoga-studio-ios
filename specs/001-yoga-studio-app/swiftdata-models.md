# SwiftData Models for Yoga Studio App

## Data Models

### Studio Owner
```swift
import SwiftData

@Model
class StudioOwner {
    var id: UUID
    var email: String
    var firstName: String
    var lastName: String
    var studioName: String
    var createdAt: Date
    var updatedAt: Date
    
    init(email: String, firstName: String, lastName: String, studioName: String) {
        self.id = UUID()
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.studioName = studioName
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
```

### Member
```swift
@Model
class Member {
    var id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: String?
    var joinDate: Date
    var isActive: Bool
    var notes: String?
    var subscription: Subscription?
    var bookings: [Booking] = []
    var attendanceRecords: [AttendanceRecord] = []
    
    init(firstName: String, lastName: String, email: String) {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.joinDate = Date()
        self.isActive = true
    }
}
```

### Subscription Plan
```swift
enum SubscriptionPlan: String, CaseIterable, Codable {
    case basic = "basic"        // 4 classes per month
    case premium = "premium"     // 8 classes per month
    case unlimited = "unlimited" // Unlimited classes
    case dropIn = "dropIn"      // Pay per class
}

@Model
class Subscription {
    var id: UUID
    var plan: String // SubscriptionPlan.rawValue
    var startDate: Date
    var endDate: Date
    var isActive: Bool
    var classesUsed: Int
    var classesLimit: Int
    var autoRenew: Bool
    var member: Member?
    
    init(plan: SubscriptionPlan, startDate: Date, endDate: Date, classesLimit: Int) {
        self.id = UUID()
        self.plan = plan.rawValue
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = true
        self.classesUsed = 0
        self.classesLimit = classesLimit
        self.autoRenew = true
    }
}
```

### Class
```swift
enum ClassCategory: String, CaseIterable, Codable {
    case hatha = "hatha"
    case vinyasa = "vinyasa"
    case yin = "yin"
    case restorative = "restorative"
    case power = "power"
    case meditation = "meditation"
}

@Model
class YogaClass {
    var id: UUID
    var title: String
    var description: String
    var instructorName: String
    var category: String // ClassCategory.rawValue
    var startTime: Date
    var duration: TimeInterval
    var capacity: Int
    var price: Decimal
    var isActive: Bool
    var bookings: [Booking] = []
    var attendanceRecords: [AttendanceRecord] = []
    
    init(title: String, description: String, instructorName: String, category: ClassCategory, startTime: Date, duration: TimeInterval, capacity: Int, price: Decimal) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.instructorName = instructorName
        self.category = category.rawValue
        self.startTime = startTime
        self.duration = duration
        self.capacity = capacity
        self.price = price
        self.isActive = true
    }
}
```

### Booking
```swift
enum BookingStatus: String, CaseIterable, Codable {
    case confirmed = "confirmed"
    case cancelled = "cancelled"
    case completed = "completed"
    case noShow = "noShow"
}

@Model
class Booking {
    var id: UUID
    var bookingDate: Date
    var status: String // BookingStatus.rawValue
    var member: Member?
    var yogaClass: YogaClass?
    var payment: Payment?
    
    init(member: Member, yogaClass: YogaClass, bookingDate: Date) {
        self.id = UUID()
        self.member = member
        self.yogaClass = yogaClass
        self.bookingDate = bookingDate
        self.status = BookingStatus.confirmed.rawValue
    }
}
```

### Attendance Record
```swift
enum AttendanceStatus: String, CaseIterable, Codable {
    case present = "present"
    case absent = "absent"
    case late = "late"
    case cancelled = "cancelled"
}

@Model
class AttendanceRecord {
    var id: UUID
    var attendanceDate: Date
    var status: String // AttendanceStatus.rawValue
    var checkInTime: Date?
    var notes: String?
    var member: Member?
    var yogaClass: YogaClass?
    
    init(member: Member, yogaClass: YogaClass, attendanceDate: Date, status: AttendanceStatus) {
        self.id = UUID()
        self.member = member
        self.yogaClass = yogaClass
        self.attendanceDate = attendanceDate
        self.status = status.rawValue
    }
}
```

### Payment
```swift
enum PaymentType: String, CaseIterable, Codable {
    case subscription = "subscription"
    case dropIn = "dropIn"
    case upgrade = "upgrade"
    case refund = "refund"
}

enum PaymentStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case completed = "completed"
    case failed = "failed"
    case refunded = "refunded"
}

@Model
class Payment {
    var id: UUID
    var amount: Decimal
    var currency: String
    var type: String // PaymentType.rawValue
    var status: String // PaymentStatus.rawValue
    var createdAt: Date
    var description: String
    var member: Member?
    var booking: Booking?
    
    init(amount: Decimal, currency: String, type: PaymentType, description: String) {
        self.id = UUID()
        self.amount = amount
        self.currency = currency
        self.type = type.rawValue
        self.status = PaymentStatus.pending.rawValue
        self.createdAt = Date()
        self.description = description
    }
}
```

## SwiftData Configuration

### Model Container Setup
```swift
import SwiftData
import SwiftUI

@main
struct YogaStudioApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: 
                StudioOwner.self,
                Member.self,
                Subscription.self,
                YogaClass.self,
                Booking.self,
                AttendanceRecord.self,
                Payment.self
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
```

### Usage in SwiftUI Views
```swift
import SwiftData
import SwiftUI

struct MemberListView: View {
    @Query var members: [Member]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List(members) { member in
            Text(member.firstName + " " + member.lastName)
        }
    }
}
```

## Key Benefits of SwiftData

1. **Simplified Setup**: No need for `.xcdatamodeld` files
2. **SwiftUI Integration**: Native `@Query` and `@Model` support
3. **Automatic Migrations**: Handles schema changes automatically
4. **Type Safety**: Full Swift type safety with enums
5. **Relationships**: Automatic relationship management
6. **Performance**: Optimized for SwiftUI reactive updates
