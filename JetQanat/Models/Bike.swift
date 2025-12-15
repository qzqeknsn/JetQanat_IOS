import Foundation

// Модель данных для мотоциклов
struct Bike: Codable, Identifiable {
    let id: Int
    let name: String
    let price: Int
    let category: String // "scooter", "sport"
    let type: String     // "sale" или "rent" - для фильтра!
    let image_url: String
    
    // Форматированная цена для отображения
    var formattedPrice: String {
        return "₸\(price.formatted())"
    }
    
    func toProduct() -> Product {
        return Product(
            id: id,
            title: name,
            price: formattedPrice,
            priceValue: Double(price),
            category: "Motorcycles",
            imageName: image_url,
            description: "Premium motorcycle ready for the road."
        )
    }
}
