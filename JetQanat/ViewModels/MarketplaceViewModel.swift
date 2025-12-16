import Foundation
import Combine

// MARK: - Sort Option Enum
enum SortOption: String, CaseIterable {
    case priceAsc = "Price: Low to High"
    case priceDesc = "Price: High to Low"
    case newest = "Newest First"
    case popular = "Most Popular"
}

class MarketplaceViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var searchText: String = ""
    @Published var selectedFilter: String = "All"
    @Published var isLoading = false
    
    @Published var selectedBrands: Set<String> = []
    @Published var selectedRidingStyles: Set<String> = []
    @Published var selectedPartTypes: Set<String> = []
    @Published var selectedAccessoryTypes: Set<String> = []
    @Published var sortOption: SortOption = .newest
    @Published var priceRange: ClosedRange<Double> = 0...15_000_000
    @Published var showFilterSheet: Bool = false
    
    let filters = ["All", "Motorcycles", "Parts", "Accessories"]
    
    // MARK: - Static Filter Options
    static let motorcycleBrands = [
        "Yamaha", "Honda", "Kawasaki", "Suzuki",
        "BMW", "Ducati", "Harley-Davidson", "KTM", "Triumph"
    ]
    
    static let ridingStyles = [
        "Sport", "Cruiser", "Touring", "Adventure",
        "Street", "Off-Road", "Scooter"
    ]
    
    static let partTypes = [
        "Brakes", "Exhaust", "Engine", "Suspension",
        "Electrical", "Body", "Wheels", "Drivetrain"
    ]
    
    static let accessoryTypes = [
        "Helmets", "Jackets", "Gloves", "Boots",
        "Bags", "Electronics", "Security", "Tools"
    ]
    
    init() {
        fetchProducts()
    }
    
    func fetchProducts() {
        isLoading = true
        self.products = [] // Clear existing
        
        // 1. Shuffle URLs to ensure we get a random mix of Brands/Models (Honda, Yamaha, BMW, etc.) immediately
        // 2. Limit to top 2 bikes per model to prevent one model (e.g. CB1000R) from dominating the feed
        let urls = BrandManager.shared.demoUrls.shuffled()
        
        print("MarketplaceViewModel: Starting concurrent fetch for \(urls.count) sources...")
        
        let group = DispatchGroup()
        
        for url in urls {
            group.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                AuctionParser.shared.fetchBikes(url: url) { [weak self] result in
                    defer { group.leave() }
                    
                    switch result {
                    case .success(let bikes):
                        guard let self = self else { return }
                        
                        // Limit to 2 bikes per model -> Maximum variety in the feed
                        let newProducts = bikes.prefix(2).map { bike -> Product in
                            return bike.toProduct()
                        }
                        
                        DispatchQueue.main.async {
                            // Append new items to existing list to show progress
                            self.products.append(contentsOf: newProducts)
                        }
                        
                    case .failure(let error):
                        print("Error fetching \(url): \(error)")
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            self.isLoading = false
            print("MarketplaceViewModel: Finished loading. Total count: \(self.products.count)")
        }
    }
    
    private func loadMockBikes() {
        products = [
            Product(id: 1, title: "Yamaha R1 2023", price: "₸8,500,000", priceValue: 8500000, category: "Motorcycles", imageName: "motorcycle.fill", description: "Sport bike"),
            Product(id: 2, title: "Honda CBR 600RR", price: "₸6,200,000", priceValue: 6200000, category: "Motorcycles", imageName: "motorcycle.fill", description: "Sport bike"),
            Product(id: 3, title: "Kawasaki Ninja 400", price: "₸4,500,000", priceValue: 4500000, category: "Motorcycles", imageName: "motorcycle.fill", description: "Sport bike"),
            Product(id: 4, title: "Suzuki GSX-R750", price: "₸5,800,000", priceValue: 5800000, category: "Motorcycles", imageName: "motorcycle.fill", description: "Sport bike"),
            Product(id: 5, title: "BMW S1000RR", price: "₸12,000,000", priceValue: 12000000, category: "Motorcycles", imageName: "motorcycle.fill", description: "Sport bike")
        ]
    }
    
    // MARK: - Filter Toggle Methods
    func toggleBrand(_ brand: String) {
        if selectedBrands.contains(brand) {
            selectedBrands.remove(brand)
        } else {
            selectedBrands.insert(brand)
        }
    }
    
    func toggleRidingStyle(_ style: String) {
        if selectedRidingStyles.contains(style) {
            selectedRidingStyles.remove(style)
        } else {
            selectedRidingStyles.insert(style)
        }
    }
    
    func togglePartType(_ partType: String) {
        if selectedPartTypes.contains(partType) {
            selectedPartTypes.remove(partType)
        } else {
            selectedPartTypes.insert(partType)
        }
    }
    
    func toggleAccessoryType(_ accessoryType: String) {
        if selectedAccessoryTypes.contains(accessoryType) {
            selectedAccessoryTypes.remove(accessoryType)
        } else {
            selectedAccessoryTypes.insert(accessoryType)
        }
    }
    
    func clearAllFilters() {
        selectedBrands.removeAll()
        selectedRidingStyles.removeAll()
        selectedPartTypes.removeAll()
        selectedAccessoryTypes.removeAll()
        priceRange = 0...15_000_000
        sortOption = .newest
    }
    
    // MARK: - Active Filter Count
    var activeFilterCount: Int {
        var count = 0
        if !selectedBrands.isEmpty { count += selectedBrands.count }
        if !selectedRidingStyles.isEmpty { count += selectedRidingStyles.count }
        if !selectedPartTypes.isEmpty { count += selectedPartTypes.count }
        if !selectedAccessoryTypes.isEmpty { count += selectedAccessoryTypes.count }
        if priceRange != 0...15_000_000 { count += 1 }
        return count
    }
    
    // MARK: - Filtered Products
    var filteredProducts: [Product] {
        var result = products
        if selectedFilter != "All" {
            result = result.filter { $0.category == selectedFilter }
        }
        if !searchText.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        if !selectedBrands.isEmpty {
            result = result.filter { product in
                selectedBrands.contains { brand in
                    product.title.contains(brand)
                }
            }
        }
        
        if !selectedPartTypes.isEmpty && selectedFilter == "Parts" {
            result = result.filter { product in
                selectedPartTypes.contains { partType in
                    product.title.localizedCaseInsensitiveContains(partType)
                }
            }
        }
        
        
        if !selectedAccessoryTypes.isEmpty && selectedFilter == "Accessories" {
            result = result.filter { product in
                selectedAccessoryTypes.contains { accessoryType in
                    product.title.localizedCaseInsensitiveContains(accessoryType)
                }
            }
        }
        
        result = result.filter { product in
            let priceString = product.price.replacingOccurrences(of: "₸", with: "")
                .replacingOccurrences(of: ",", with: "")
            if let price = Double(priceString) {
                return priceRange.contains(price)
            }
            return true
        }
        
        
        switch sortOption {
        case .priceAsc:
            result.sort { 
                getPriceValue($0.price) < getPriceValue($1.price)
            }
        case .priceDesc:
            result.sort { 
                getPriceValue($0.price) > getPriceValue($1.price)
            }
        case .newest:

            result.sort { $0.id > $1.id }
        case .popular:
            break
        }
        
        return result
    }
    
    private func getPriceValue(_ priceString: String) -> Double {
        let cleaned = priceString.replacingOccurrences(of: "₸", with: "")
            .replacingOccurrences(of: ",", with: "")
        return Double(cleaned) ?? 0
    }
}


