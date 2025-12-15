import Foundation

// Модель для мотиков
struct Bike: Codable, Identifiable {
    let id: Int
    let name: String
    let price: Int
    let category: String
    let type: String
    let image_url: String
    
    // Отображение цен
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
