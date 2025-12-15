//
//  HomeViewModel.swift
//  JetQanat
//
//  Created by Zholdibay Abylay on 16.12.2025.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var bikes: [Bike] = []
    @Published var isLoadingBikes = false
    @Published var categories: [Category] = [
        Category(id: 1, name: "Motorcycles", icon: "bicycle"),
        Category(id: 2, name: "Parts", icon: "gearshape.fill"),
        Category(id: 3, name: "Accessories", icon: "star.fill"),
        Category(id: 4, name: "Rentals", icon: "calendar")
    ]
    
    @Published var cashbackBalance: Double = 0
    @Published var activeOrdersCount: Int = 0
    @Published var activeRentalsCount: Int = 0
    
    
    @Published var recentOrders: [Order] = []
    @Published var activeRentals: [(id: UUID, bikeModel: String, totalPrice: Double, rentalPeriodType: String, startDate: Date, endDate: Date, rentalStatus: String)] = []
    
    init() {
        fetchBikes()
        loadQuickStats()
        loadRecentActivity()
    }
    
    private var viewCancellables = Set<AnyCancellable>()
    
    func fetchBikes() {
        isLoadingBikes = true
        
        NetworkService.shared.fetchMotorcycles()
            .sink { [weak self] completion in
                self?.isLoadingBikes = false
                if case .failure(let error) = completion {
                    print("Error fetching bikes: \(error)")
                    
                }
            } receiveValue: { [weak self] bikes in
                self?.bikes = bikes
                print("Loadded \(bikes.count) bikes from API")
            }
            .store(in: &viewCancellables)
    }
    
    func loadQuickStats() {
        
        cashbackBalance = UserViewModel.shared.cashbackBalance
        activeOrdersCount = 2
        activeRentalsCount = 1
    }
    
    func loadRecentActivity() {
        
        recentOrders = []
        activeRentals = []
    }
    
    func refreshData() {
        fetchBikes()
        loadQuickStats()
        loadRecentActivity()
    }
}

