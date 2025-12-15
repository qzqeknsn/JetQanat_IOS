import Foundation
import Combine

class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var cashbackBalance: Double = 0.0
    

    
    static let shared = UserViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bindToAuth()
    }
    
    var formattedCashback: String {
        return "₸\(Int(cashbackBalance).formatted())"
    }
    
    private func bindToAuth() {
        AuthenticationViewModel.shared.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.user = user
                self?.cashbackBalance = user?.cashbackBalance ?? 0.0
            }
            .store(in: &cancellables)
    }
    
    func loadUser() {
        
    }
    
    func refreshCashback() {
        
    }
    
    func updateProfile(name: String, email: String, phone: String) {
        guard var currentUser = user else { return }
        
        currentUser = User(
            id: currentUser.id,
            fullName: name,
            email: email,
            phone: phone,
            profileImageURL: currentUser.profileImageURL,
            isVerified: currentUser.isVerified,
            verificationStatus: currentUser.verificationStatus,
            renterRating: currentUser.renterRating,
            ownerRating: currentUser.ownerRating,
            totalRentals: currentUser.totalRentals,
            cashbackBalance: currentUser.cashbackBalance
        )
        
        self.user = currentUser
    }
}
