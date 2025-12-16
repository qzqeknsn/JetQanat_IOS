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
        
        let urls = BrandManager.shared.demoUrls.shuffled()
        // Fetch fewer sources for Home to keep it quick
        let targetUrls = Array(urls.prefix(8))
        
        Task {
            do {
                // Use a ThrowingTaskGroup to fetch concurrently
                var fetchedBikes: [Bike] = []
                
                await withTaskGroup(of: [Bike].self) { group in
                    for url in targetUrls {
                        group.addTask {
                            do {
                                // Calls the new async fetchBikes
                                let bikes = try await AuctionParser.shared.fetchBikes(url: url)
                                return Array(bikes.prefix(3)) // Take top 3
                            } catch {
                                print("HomeViewModel: Error fetching \(url): \(error)")
                                return [] 
                            }
                        }
                    }
                    
                    // Collect results
                    for await bikes in group {
                        fetchedBikes.append(contentsOf: bikes)
                    }
                }
                
                // Update UI on MainActor
                await MainActor.run {
                    self.isLoadingBikes = false
                    self.bikes = fetchedBikes.shuffled()
                }
                
            } catch {
                print("HomeViewModel: Critical error: \(error)")
                await MainActor.run { self.isLoadingBikes = false }
            }
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

