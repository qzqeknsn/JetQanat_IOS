import Foundation

struct Product: Identifiable {
    let id: Int
    let title: String
    let price: String 
    let priceValue: Double
    let category: String
    let imageName: String
    let description: String
    
    // Cashback calculation
    var cashbackAmount: Double {
        switch category {
        case "Motorcycles":
            return 15000
        case "Accessories", "Parts":
            return priceValue * 0.04 
        default:
            return 0
        }
    }
    
    var formattedCashback: String {
        return "₸\(Int(cashbackAmount).formatted())"
    }
    
    var cashbackDescription: String {
        switch category {
        case "Motorcycles":
            return "₸15,000 cashback bonus"
        case "Accessories", "Parts":
            return "4% cashback"
        default:
            return "No cashback"
        }
    }
}
