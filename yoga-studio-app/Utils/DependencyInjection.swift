import Foundation
import SwiftData
import Combine

/// Dependency Injection container for managing app dependencies
@MainActor
class DependencyContainer: ObservableObject {
    static let shared = DependencyContainer()
    
    // MARK: - Core Dependencies
    private(set) var swiftDataContainer: SwiftDataContainer
    private(set) var networkManager: NetworkManager
    private(set) var logger: Logger
    private(set) var errorHandler: ErrorHandler
    
    // MARK: - Services
    private(set) var authenticationService: AuthenticationService?
    private(set) var memberService: MemberService?
    private(set) var classService: ClassService?
    private(set) var bookingService: BookingService?
    private(set) var subscriptionService: SubscriptionService?
    private(set) var paymentService: PaymentService?
    private(set) var attendanceService: AttendanceService?
    private(set) var syncManager: SyncManager?
    
    private init() {
        // Initialize core dependencies
        self.swiftDataContainer = SwiftDataContainer.shared
        self.networkManager = NetworkManager()
        self.logger = Logger()
        self.errorHandler = ErrorHandler(logger: logger)
        
        logger.log("✅ DependencyContainer initialized", level: .info)
    }
    
    // MARK: - Service Registration
    
    /// Register authentication service
    func registerAuthenticationService() {
        authenticationService = AuthenticationService(
            modelContext: swiftDataContainer.modelContext,
            logger: logger,
            errorHandler: errorHandler
        )
        logger.log("✅ AuthenticationService registered", level: .info)
    }
    
    /// Register member service
    func registerMemberService() {
        memberService = MemberService(
            modelContext: swiftDataContainer.modelContext,
            logger: logger,
            errorHandler: errorHandler
        )
        logger.log("✅ MemberService registered", level: .info)
    }
    
    /// Register class service
    func registerClassService() {
        classService = ClassService(
            modelContext: swiftDataContainer.modelContext,
            logger: logger,
            errorHandler: errorHandler
        )
        logger.log("✅ ClassService registered", level: .info)
    }
    
    /// Register booking service
    func registerBookingService() {
        bookingService = BookingService(
            modelContext: swiftDataContainer.modelContext,
            logger: logger,
            errorHandler: errorHandler
        )
        logger.log("✅ BookingService registered", level: .info)
    }
    
    /// Register subscription service
    func registerSubscriptionService() {
        subscriptionService = SubscriptionService(
            modelContext: swiftDataContainer.modelContext,
            logger: logger,
            errorHandler: errorHandler
        )
        logger.log("✅ SubscriptionService registered", level: .info)
    }
    
    /// Register payment service
    func registerPaymentService() {
        paymentService = PaymentService(
            modelContext: swiftDataContainer.modelContext,
            logger: logger,
            errorHandler: errorHandler
        )
        logger.log("✅ PaymentService registered", level: .info)
    }
    
    /// Register attendance service
    func registerAttendanceService() {
        attendanceService = AttendanceService(
            modelContext: swiftDataContainer.modelContext,
            logger: logger,
            errorHandler: errorHandler
        )
        logger.log("✅ AttendanceService registered", level: .info)
    }
    
    /// Register sync manager
    func registerSyncManager() {
        syncManager = SyncManager(
            modelContext: swiftDataContainer.modelContext,
            logger: logger,
            errorHandler: errorHandler
        )
        logger.log("✅ SyncManager registered", level: .info)
    }
    
    // MARK: - Service Access
    
    /// Get authentication service (required)
    func getAuthenticationService() -> AuthenticationService {
        guard let service = authenticationService else {
            fatalError("AuthenticationService not registered. Call registerAuthenticationService() first.")
        }
        return service
    }
    
    /// Get member service (required)
    func getMemberService() -> MemberService {
        guard let service = memberService else {
            fatalError("MemberService not registered. Call registerMemberService() first.")
        }
        return service
    }
    
    /// Get class service (required)
    func getClassService() -> ClassService {
        guard let service = classService else {
            fatalError("ClassService not registered. Call registerClassService() first.")
        }
        return service
    }
    
    /// Get booking service (required)
    func getBookingService() -> BookingService {
        guard let service = bookingService else {
            fatalError("BookingService not registered. Call registerBookingService() first.")
        }
        return service
    }
    
    /// Get subscription service (optional)
    func getSubscriptionService() -> SubscriptionService? {
        return subscriptionService
    }
    
    /// Get payment service (optional)
    func getPaymentService() -> PaymentService? {
        return paymentService
    }
    
    /// Get attendance service (optional)
    func getAttendanceService() -> AttendanceService? {
        return attendanceService
    }
    
    /// Get sync manager (optional)
    func getSyncManager() -> SyncManager? {
        return syncManager
    }
    
    // MARK: - Initialization
    
    /// Initialize all core services
    func initializeCoreServices() {
        registerAuthenticationService()
        registerMemberService()
        registerClassService()
        registerBookingService()
        logger.log("✅ Core services initialized", level: .info)
    }
    
    /// Initialize optional services
    func initializeOptionalServices() {
        registerSubscriptionService()
        registerPaymentService()
        registerAttendanceService()
        registerSyncManager()
        logger.log("✅ Optional services initialized", level: .info)
    }
}

// MARK: - Service Protocols (Temporary - will be moved to separate files)

protocol AuthenticationServiceProtocol {
    func login(email: String, password: String) async throws -> StudioOwner
    func register(email: String, password: String, firstName: String, lastName: String, studioName: String) async throws -> StudioOwner
    func logout() async throws
    func getCurrentUser() -> StudioOwner?
}

protocol MemberServiceProtocol {
    func createMember(firstName: String, lastName: String, email: String, phoneNumber: String?) async throws -> Member
    func updateMember(_ member: Member) async throws
    func deleteMember(_ member: Member) async throws
    func getAllMembers() async throws -> [Member]
    func getMember(by id: UUID) async throws -> Member?
}

protocol ClassServiceProtocol {
    func createClass(name: String, description: String, instructorName: String, category: ClassCategory, capacity: Int, duration: Int, startTime: Date) async throws -> YogaClass
    func updateClass(_ yogaClass: YogaClass) async throws
    func deleteClass(_ yogaClass: YogaClass) async throws
    func getAllClasses() async throws -> [YogaClass]
    func getClass(by id: UUID) async throws -> YogaClass?
}

protocol BookingServiceProtocol {
    func createBooking(member: Member, yogaClass: YogaClass) async throws -> Booking
    func updateBooking(_ booking: Booking) async throws
    func cancelBooking(_ booking: Booking) async throws
    func getAllBookings() async throws -> [Booking]
    func getBookings(for member: Member) async throws -> [Booking]
    func getBookings(for yogaClass: YogaClass) async throws -> [Booking]
}

protocol SubscriptionServiceProtocol {
    func createSubscription(member: Member, plan: SubscriptionPlan, startDate: Date, endDate: Date, maxUsage: Int?) async throws -> Subscription
    func updateSubscription(_ subscription: Subscription) async throws
    func cancelSubscription(_ subscription: Subscription) async throws
    func getAllSubscriptions() async throws -> [Subscription]
    func getActiveSubscriptions() async throws -> [Subscription]
}

protocol PaymentServiceProtocol {
    func createPayment(member: Member, amount: Double, currency: String, paymentType: PaymentType) async throws -> Payment
    func updatePayment(_ payment: Payment) async throws
    func processPayment(_ payment: Payment) async throws
    func getAllPayments() async throws -> [Payment]
    func getPayments(for member: Member) async throws -> [Payment]
}

protocol AttendanceServiceProtocol {
    func createAttendanceRecord(member: Member, yogaClass: YogaClass, status: AttendanceStatus) async throws -> AttendanceRecord
    func updateAttendanceRecord(_ record: AttendanceRecord) async throws
    func getAllAttendanceRecords() async throws -> [AttendanceRecord]
    func getAttendanceRecords(for member: Member) async throws -> [AttendanceRecord]
    func getAttendanceRecords(for yogaClass: YogaClass) async throws -> [AttendanceRecord]
}

protocol SyncManagerProtocol {
    func markForSync<T: BaseModel>(_ object: T)
    func syncWhenOnline() async
    func getPendingChanges() -> [BaseModel]
    func resolveConflict<T: BaseModel>(local: T, remote: T) -> T
}
