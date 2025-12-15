import Foundation

enum OrderStatus: String, CaseIterable {
    case processing = "Processing"
    case warehouse = "At Warehouse (Japan)"
    case inTransit = "In Transit"
    case delivered = "Delivered"
    
    var progressValue: Double {
        switch self {
        case .processing: return 0.25
        case .warehouse: return 0.5
        case .inTransit: return 0.75
        case .delivered: return 1.0
        }
    }
    
    var color: String {
        switch self {
        case .processing: return "FFB800" // Yellow
        case .warehouse: return "10B981" // Green
        case .inTransit: return "FFB800" // Yellow
        case .delivered: return "10B981" // Green
        }
    }
}

struct Order: Identifiable {
    let id: UUID
    let orderCode: String // "MH-JP-00123"
    let productTitles: [String]
    let totalAmount: Double
    let cashbackUsed: Double
    let cashbackEarned: Double
    let shippingAddress: String
    let zipCode: String
    var status: OrderStatus
    let estimatedArrival: Date
    let createdAt: Date
    
    var formattedTotal: String {
        return "₸\(Int(totalAmount).formatted())"
    }
    
    var formattedCashbackUsed: String {
        return "₸\(Int(cashbackUsed).formatted())"
    }
    
    var formattedCashbackEarned: String {
        return "₸\(Int(cashbackEarned).formatted())"
    }
    
    static func generateOrderCode() -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let randomPart = Int.random(in: 10000...99999)
        return "MH-JP-\(timestamp % 100000)\(randomPart % 1000)"
    }
}
