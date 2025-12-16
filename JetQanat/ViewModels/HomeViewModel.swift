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
        
        // Use BrandManager for consistent popular bikes on Home screen too (Real Data)
        let urls = BrandManager.shared.demoUrls.shuffled() // Shuffle for variety on home too
        let group = DispatchGroup()
        var allBikes: [Bike] = []
        
        // Fetch fewer sources for Home to keep it quick
        let targetUrls = Array(urls.prefix(8))
        
        for url in targetUrls {
            group.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                AuctionParser.shared.fetchBikes(url: url) { result in
                    defer { group.leave() }
                    switch result {
                    case .success(let bikes):
                        // Take top 3 from each
                        let topBikes = Array(bikes.prefix(3))
                        DispatchQueue.main.async {
                            allBikes.append(contentsOf: topBikes)
                        }
                    case .failure(let error):
                        print("HomeViewModel: Error fetching \(url): \(error)")
                    }
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.isLoadingBikes = false
            self?.bikes = allBikes.shuffled()
        }
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

