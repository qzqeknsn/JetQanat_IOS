//
//  LoginViewController.swift
//  JetQanat
//
//  Created by Zholdybay Abylay on 15.12.2025.
//

import Foundation
import Combine
import CoreData

class AuthenticationViewModel: ObservableObject {
    static let shared = AuthenticationViewModel()
    
    @Published var isAuthenticated = false
    @Published var currentStep: RegistrationStep = .welcome
    @Published var isVerificationPending = false
    @Published var currentUser: User?
    
    @Published var loginError: String?
    
    // ... (existing properties)

    func login(email: String, password: String) {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "UserEntity")
        // Case insensitive email check
        request.predicate = NSPredicate(format: "email ==[c] %@ AND password == %@", cleanEmail, cleanPassword)
        
        do {
            let results = try context.fetch(request)
            if let userEntity = results.first {
                // Map Entity to Model
                self.currentUser = User(
                    id: userEntity.value(forKey: "id") as? UUID ?? UUID(),
                    fullName: userEntity.value(forKey: "fullName") as? String ?? "",
                    email: userEntity.value(forKey: "email") as? String ?? "",
                    phone: userEntity.value(forKey: "phone") as? String ?? "",
                    isVerified: userEntity.value(forKey: "isVerified") as? Bool ?? false
                )
                self.isAuthenticated = true
                self.loginError = nil
            } else {
                print("Login failed: User not found or wrong password")
                self.loginError = "Invalid email or password"
            }
        } catch {
            print("Login error: \(error)")
            self.loginError = "An error occurred. Please try again."
        }
    }
    @Published var email = ""
    @Published var password = ""
    @Published var phone = ""
    @Published var fullName = ""
    
    enum RegistrationStep {
        case welcome
        case registration
        case verification
        case pending
    }
    
    func proceedToRegistration() {
        currentStep = .registration
    }
    

    
    func submitRegistration() {
        // Trim inputs
        let cleanName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Create user object with registration data
        let newUser = User(
            fullName: cleanName,
            email: cleanEmail,
            phone: cleanPhone,
            isVerified: false,
            verificationStatus: .pending
        )
        self.currentUser = newUser
        
        // Save to Core Data
        let context = CoreDataManager.shared.context
        if let entity = NSEntityDescription.entity(forEntityName: "UserEntity", in: context) {
            let userObj = NSManagedObject(entity: entity, insertInto: context)
            userObj.setValue(newUser.id, forKey: "id")
            userObj.setValue(newUser.fullName, forKey: "fullName")
            userObj.setValue(newUser.email, forKey: "email")
            userObj.setValue(cleanPassword, forKey: "password") // Plaintext for demo, hash in prod
            userObj.setValue(newUser.phone, forKey: "phone")
            userObj.setValue(false, forKey: "isVerified")
            
            CoreDataManager.shared.saveContext()
        }
        
        // Proceed to verification
        currentStep = .verification
    }
    
    func submitVerification() {
        // Update user verification status
        if var user = currentUser {
            user.verificationStatus = .pending
            currentUser = user
        }
        
        // Simulate document upload
        currentStep = .pending
        isVerificationPending = true
        
        // Simulate approval after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if var user = self.currentUser {
                user.isVerified = true
                user.verificationStatus = .verified
                self.currentUser = user
                
                // Update in Core Data
                self.updateUserVerificationInCoreData(userId: user.id)
            }
            self.isAuthenticated = true
            self.isVerificationPending = false
        }
    }
    
    private func updateUserVerificationInCoreData(userId: UUID) {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "UserEntity")
        request.predicate = NSPredicate(format: "id == %@", userId as CVarArg)
        
        do {
            let results = try context.fetch(request)
            if let userEntity = results.first {
                userEntity.setValue(true, forKey: "isVerified")
                CoreDataManager.shared.saveContext()
            }
        } catch {
            print("Update error: \(error)")
        }
    }
    
    func skipToApp() {
        // Limited access with guest user
        if currentUser == nil {
            currentUser = User(
                id: UUID(),
                fullName: "Guest User",
                email: "guest@motorhub.com",
                phone: "",
                profileImageURL: nil,
                isVerified: false,
                verificationStatus: .unverified,
                renterRating: 0.0,
                ownerRating: 0.0,
                totalRentals: 0,
                cashbackBalance: 0.0
            ) 
        }
        isAuthenticated = true
    }
    
    func checkVerificationStatus() {
        // This was used for mock, now login handles it. 
        // We can keep it or remove it.
    }
    
    func logout() {
        self.currentUser = nil
        self.isAuthenticated = false
        self.currentStep = .welcome
    }
}
