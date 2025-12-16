import Foundation

// Модель для мотиков
struct Bike: Codable, Identifiable {
    let id: Int
    let name: String
    let price: Int
    let category: String
    let type: String
    let image_url: String
    // Detailed Specs
    var lotNumber: String?
    var auction: String?
    var date: String?
    var year: String?
    var engineVolume: String?
    var frame: String?
    var mileage: String?
    var rating: String?
    var startPrice: String?
    var status: String?
    var color: String?
    
    // Отображение цен
    var formattedPrice: String {
        return "₸\(price.formatted())"
    }
    
    // Helper to generate description
    var generatedDescription: String {
        return """
        \(year ?? "") \(name)
        Mileage: \(mileage ?? "N/A") | Rating: \(rating ?? "N/A")
        frame: \(frame ?? "N/A")
        Volume: \(engineVolume ?? "N/A") cc
        """
    }
    
    func toProduct() -> Product {
        // Get generic brand description (e.g. "Honda is known for...")
        let brandDesc = BrandManager.shared.getDescription(for: name)
        
        // Combine with specific bike details
        let fullDescription = """
        \(brandDesc)
        
        --- Specification ---
        \(generatedDescription)
        """
        
        return Product(
            id: id,
            title: name,
            price: formattedPrice,
            priceValue: Double(price),
            category: "Motorcycles",
            imageName: image_url,
            description: fullDescription
        )
    }
}
