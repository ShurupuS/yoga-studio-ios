# Yoga Studio App Specification

## Overview
A comprehensive iOS application for yoga studio owners to manage their business operations, including class scheduling, member management, subscription plans, and payment processing.

## User Stories

### Core User Stories

#### 1. Member Management
- **As a studio owner**, I want to manage member profiles so that I can track attendance and membership status
- **As a studio owner**, I want to view member details and subscription information so that I can provide better service
- **As a studio owner**, I want to update member information so that I can keep records current

#### 2. Class Scheduling
- **As a studio owner**, I want to create and manage class schedules so that members can book sessions
- **As a studio owner**, I want to view class attendance and capacity so that I can optimize scheduling
- **As a studio owner**, I want to manage class cancellations and changes so that I can communicate with members
- **As a studio owner**, I want to track class performance so that I can make data-driven decisions

#### 3. Subscription & Payment Management
- **As a studio owner**, I want to manage different subscription plans so that I can offer flexible pricing options
- **As a studio owner**, I want to track subscription revenue so that I can manage my business finances
- **As a studio owner**, I want to view member subscription usage so that I can optimize plan offerings
- **As a studio owner**, I want to process payments and refunds so that I can handle billing efficiently

#### 4. Payment Processing
- **As a studio owner**, I want to track all payments and revenue so that I can manage my business finances
- **As a studio owner**, I want to view payment history and analytics so that I can make informed decisions
- **As a studio owner**, I want to process refunds and handle payment issues so that I can maintain customer satisfaction

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

2. **Class Management**
   - Create, read, update, delete classes
   - Class categories (Hatha, Vinyasa, Yin, etc.)
   - Capacity management
   - Class instructor information display
   - Attendance tracking

3. **Subscription Management**
   - Multiple subscription plans (Basic, Premium, Unlimited)
   - Member subscription tracking
   - Usage monitoring and limits
   - Subscription analytics

4. **Member Management**
   - Member profile management
   - Subscription assignment
   - Attendance tracking
   - Member communication

5. **Booking System**
   - Real-time availability checking
   - Waitlist management
   - Automatic reminders
   - Cancellation policies
   - Booking analytics

6. **Admin Dashboard**
   - Analytics and reporting
   - Member management
   - Subscription plan management
   - Revenue tracking
   - Class performance metrics

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
   - Quick actions
   - Notifications

3. **Class Management**
   - Class list with filtering and search
   - Calendar view for scheduling
   - Class details and attendance
   - Instructor information

4. **Member Management**
   - Member list with search and filtering
   - Member profile details
   - Subscription assignment and tracking
   - Communication tools

5. **Subscription Management**
   - Available plans overview
   - Member subscription details
   - Usage tracking and analytics
   - Plan management

6. **Booking Management**
   - Class bookings overview
   - Booking confirmations and cancellations
   - Waitlist management
   - Attendance tracking

7. **Analytics & Reports**
   - Revenue tracking
   - Class performance metrics
   - Member analytics
   - Subscription analytics

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
