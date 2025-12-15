import Foundation

struct CartItem: Identifiable, Equatable {
    let id = UUID()
    let product: Product
    var quantity: Int
    var isSelected: Bool = true
    
    var totalPrice: Double {
        return product.priceValue * Double(quantity)
    }
    
    var formattedTotalPrice: String {
        return "₸\(Int(totalPrice).formatted())"
    }
    
    var totalCashback: Double {
        return product.cashbackAmount * Double(quantity)
    }
    
    var formattedTotalCashback: String {
        return "₸\(Int(totalCashback).formatted())"
    }
    
    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        return lhs.id == rhs.id
    }
}
