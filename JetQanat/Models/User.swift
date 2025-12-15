
import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var fullName: String
    var email: String
    var phone: String
    var profileImageURL: String?
    
    // Verification
    var isVerified: Bool
    var verificationStatus: VerificationStatus
    
    // Ratings
    var renterRating: Double
    var ownerRating: Double
    var totalRentals: Int
    
    // Finance
    var cashbackBalance: Double
    
    enum VerificationStatus: String, Codable {
        case unverified = "Unverified"
        case pending = "Pending"
        case verified = "Verified"
    }
    
    init(
        id: UUID = UUID(),
        fullName: String = "Ivan Petrov",
        email: String = "ivan@example.com",
        phone: String = "+7 777 123 4567",
        profileImageURL: String? = nil,
        isVerified: Bool = true,
        verificationStatus: VerificationStatus = .verified,
        renterRating: Double = 4.8,
        ownerRating: Double = 4.9,
        totalRentals: Int = 24,
        cashbackBalance: Double = 15000
    ) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.phone = phone
        self.profileImageURL = profileImageURL
        self.isVerified = isVerified
        self.verificationStatus = verificationStatus
        self.renterRating = renterRating
        self.ownerRating = ownerRating
        self.totalRentals = totalRentals
        self.cashbackBalance = cashbackBalance
    }
}
