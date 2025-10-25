# Yoga Studio App Specification

## Overview
A comprehensive iOS application for yoga studio owners to manage their business operations, including class scheduling, member management, subscription plans, and payment processing.

## Core Functionality Priorities

### 1. Member Profile Management (Priority 1)
**Essential Features:**
- Create and manage member profiles
- Track member information and contact details
- Manage member subscriptions and payment status
- Member search and filtering capabilities
- Member communication tools

### 2. Class and Booking Control (Priority 2)
**Essential Features:**
- Create and manage class schedules
- Handle class bookings and cancellations
- Manage class capacity and waitlists
- Track class instructor assignments
- Class performance analytics

### 3. Attendance Tracking and Record Keeping (Priority 3)
**Essential Features:**
- Mark attendance for each class session
- Track member attendance history
- Generate attendance reports
- Monitor member engagement and retention
- Export attendance data for analysis

## User Stories

### Core User Stories

#### 1. Member Management
- **As a studio owner**, I want to manage member profiles so that I can track attendance and membership status
- **As a studio owner**, I want to view member details and subscription information so that I can provide better service
- **As a studio owner**, I want to update member information so that I can keep records current
- **As a studio owner**, I want to search and filter members so that I can quickly find specific members
- **As a studio owner**, I want to communicate with members so that I can send updates and announcements

#### 2. Class Scheduling and Booking Management
- **As a studio owner**, I want to create and manage class schedules so that members can book sessions
- **As a studio owner**, I want to view class attendance and capacity so that I can optimize scheduling
- **As a studio owner**, I want to manage class cancellations and changes so that I can communicate with members
- **As a studio owner**, I want to track class performance so that I can make data-driven decisions
- **As a studio owner**, I want to manage class bookings and waitlists so that I can optimize class capacity

#### 3. Attendance Tracking and Record Keeping
- **As a studio owner**, I want to mark attendance for each class session so that I can track member participation
- **As a studio owner**, I want to view member attendance history so that I can monitor engagement
- **As a studio owner**, I want to generate attendance reports so that I can analyze member retention
- **As a studio owner**, I want to track attendance patterns so that I can identify popular classes
- **As a studio owner**, I want to export attendance data so that I can perform detailed analysis
- **As a studio owner**, I want to see attendance statistics so that I can make informed business decisions

#### 4. Subscription & Payment Management
- **As a studio owner**, I want to manage different subscription plans so that I can offer flexible pricing options
- **As a studio owner**, I want to track subscription revenue so that I can manage my business finances
- **As a studio owner**, I want to view member subscription usage so that I can optimize plan offerings
- **As a studio owner**, I want to process payments and refunds so that I can handle billing efficiently

#### 5. Notifications & Communication
- **As a studio owner**, I want to send class reminders to members so that they don't miss sessions
- **As a studio owner**, I want to notify members of schedule changes so that they can adjust their plans
- **As a studio owner**, I want to send announcements and promotions so that I can communicate with my community

## Technical Requirements

### Platform & Architecture
- **Platform**: iOS 17.0+
- **Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Data Persistence**: Core Data
- **Networking**: URLSession with async/await

### Core Features
1. **Authentication System**
   - Studio owner login and registration
   - Secure token management
   - Single-user application

2. **Member Management**
   - Member profile creation and editing
   - Member search and filtering
   - Subscription assignment and tracking
   - Member communication tools
   - Member status management

3. **Class Management**
   - Create, read, update, delete classes
   - Class categories (Hatha, Vinyasa, Yin, etc.)
   - Capacity management
   - Class instructor information display
   - Class scheduling and calendar view

4. **Booking Management**
   - Real-time availability checking
   - Waitlist management
   - Booking confirmations and cancellations
   - Booking analytics and reporting

5. **Attendance Tracking System**
   - Mark attendance for each class session
   - Track member attendance history
   - Generate attendance reports
   - Monitor member engagement patterns
   - Export attendance data
   - Attendance analytics and insights

6. **Subscription Management**
   - Multiple subscription plans (Basic, Premium, Unlimited)
   - Member subscription tracking
   - Usage monitoring and limits
   - Subscription analytics

7. **Analytics & Reporting**
   - Revenue tracking and analytics
   - Class performance metrics
   - Member analytics and retention
   - Attendance statistics
   - Business insights dashboard

### Data Models

#### Studio Owner
```swift
struct StudioOwner {
    let id: UUID
    let email: String
    let firstName: String
    let lastName: String
    let studioName: String
    let createdAt: Date
    let updatedAt: Date
}
```

#### Member
```swift
struct Member {
    let id: UUID
    let firstName: String
    let lastName: String
    let email: String
    let phoneNumber: String?
    let subscription: Subscription?
    let joinDate: Date
    let isActive: Bool
    let notes: String?
}

enum SubscriptionPlan {
    case basic        // 4 classes per month
    case premium      // 8 classes per month
    case unlimited    // Unlimited classes
    case dropIn       // Pay per class
}

struct Subscription {
    let id: UUID
    let memberId: UUID
    let plan: SubscriptionPlan
    let startDate: Date
    let endDate: Date
    let isActive: Bool
    let classesUsed: Int
    let classesLimit: Int
    let autoRenew: Bool
}
```

#### Class
```swift
struct YogaClass {
    let id: UUID
    let title: String
    let description: String
    let instructorName: String
    let category: ClassCategory
    let startTime: Date
    let duration: TimeInterval
    let capacity: Int
    let price: Decimal
    let isActive: Bool
}

enum ClassCategory {
    case hatha
    case vinyasa
    case yin
    case restorative
    case power
    case meditation
}
```

#### Booking
```swift
struct Booking {
    let id: UUID
    let memberId: UUID
    let classId: UUID
    let bookingDate: Date
    let status: BookingStatus
    let paymentId: UUID?
}

enum BookingStatus {
    case confirmed
    case cancelled
    case completed
    case noShow
}
```

#### Payment
```swift
struct Payment {
    let id: UUID
    let memberId: UUID
    let amount: Decimal
    let currency: String
    let type: PaymentType
    let status: PaymentStatus
    let createdAt: Date
    let description: String
}

enum PaymentType {
    case subscription
    case dropIn
    case upgrade
    case refund
}

enum PaymentStatus {
    case pending
    case completed
    case failed
    case refunded
}
```

#### Attendance Record
```swift
struct AttendanceRecord {
    let id: UUID
    let memberId: UUID
    let classId: UUID
    let attendanceDate: Date
    let status: AttendanceStatus
    let checkInTime: Date?
    let notes: String?
}

enum AttendanceStatus {
    case present
    case absent
    case late
    case cancelled
}
```

#### Subscription Plan Details
```swift
struct SubscriptionPlanDetails {
    let plan: SubscriptionPlan
    let name: String
    let description: String
    let price: Decimal
    let classesPerMonth: Int
    let features: [String]
    let isPopular: Bool
}
```

### UI/UX Requirements

#### Design Principles
- Clean, minimalist design reflecting yoga's peaceful nature
- Calming color palette (soft greens, blues, earth tones)
- Smooth animations and transitions
- Accessibility compliance (VoiceOver, Dynamic Type)

#### Key Screens
1. **Onboarding Flow**
   - Welcome screen
   - Studio owner registration/Login
   - Studio setup

2. **Dashboard**
   - Overview of classes and members
   - Revenue and subscription analytics
   - Attendance statistics
   - Quick actions
   - Notifications

3. **Member Management**
   - Member list with search and filtering
   - Member profile details
   - Subscription assignment and tracking
   - Communication tools
   - Member attendance history

4. **Class Management**
   - Class list with filtering and search
   - Calendar view for scheduling
   - Class details and capacity
   - Instructor information
   - Class performance metrics

5. **Attendance Tracking**
   - Class attendance marking interface
   - Member attendance history
   - Attendance reports and analytics
   - Export attendance data
   - Attendance statistics dashboard

6. **Booking Management**
   - Class bookings overview
   - Booking confirmations and cancellations
   - Waitlist management
   - Booking analytics

7. **Subscription Management**
   - Available plans overview
   - Member subscription details
   - Usage tracking and analytics
   - Plan management

8. **Analytics & Reports**
   - Revenue tracking
   - Class performance metrics
   - Member analytics
   - Attendance analytics
   - Business insights

### Performance Requirements
- App launch time: < 2 seconds
- Screen transition: < 300ms
- API response time: < 1 second
- Offline functionality for core features
- Smooth 60fps animations

### Security Requirements
- End-to-end encryption for sensitive data
- Secure authentication with biometric support
- PCI compliance for payment processing
- Data privacy compliance (GDPR, CCPA)
- Regular security audits

## Success Criteria
- 90% user satisfaction rating
- 95% uptime
- < 0.1% crash rate
- 80% feature adoption rate
- Positive App Store reviews (4.5+ stars)

## Constraints
- Must work offline for core features
- Limited to iOS platform initially
- Budget constraints for third-party services
- 6-month development timeline
- Support for 1000+ concurrent users
