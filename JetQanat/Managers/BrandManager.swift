
import Foundation

struct BrandItem {
    let id: Int
    let name: String
    let logoName: String
}

struct BrandModelItem {
    let id: Int
    let name: String
    let brandId: Int
}

class BrandManager {
    static let shared = BrandManager()
    private init() {}
    
    // Top Brands
    let brands: [BrandItem] = [
        BrandItem(id: 2, name: "Honda", logoName: "h.circle.fill"),
        BrandItem(id: 1, name: "Yamaha", logoName: "y.circle.fill"),
        BrandItem(id: 3, name: "Suzuki", logoName: "s.circle.fill"),
        BrandItem(id: 4, name: "Kawasaki", logoName: "k.circle.fill"),
        BrandItem(id: 7, name: "KTM", logoName: "k.circle.fill"),
        BrandItem(id: 13, name: "BMW", logoName: "b.circle.fill"),
        BrandItem(id: 7, name: "Ducati", logoName: "d.circle.fill")
    ]
    
    // Popular Models to fetch initially (guarantees images)
    // Structure: Motobay URL usually .../brands/{brandId}/models/{modelId}
    // Popular Models to fetch initially (guarantees images)
    // Expanded list for variety
    let popularModels: [BrandModelItem] = [
        // Honda
        BrandModelItem(id: 1430, name: "CB1000R", brandId: 2),
        BrandModelItem(id: 1432, name: "CBR1000RR", brandId: 2),
        BrandModelItem(id: 1419, name: "Africa Twin", brandId: 2),
        BrandModelItem(id: 1391, name: "Gold Wing", brandId: 2),
        // Yamaha
        BrandModelItem(id: 746, name: "YZF-R1", brandId: 1),
        BrandModelItem(id: 747, name: "YZF-R6", brandId: 1),
        BrandModelItem(id: 569, name: "MT-09", brandId: 1),
        BrandModelItem(id: 568, name: "MT-07", brandId: 1),
        // Suzuki
        BrandModelItem(id: 1586, name: "GSX-R1000", brandId: 3),
        BrandModelItem(id: 1560, name: "Hayabusa", brandId: 3),
        BrandModelItem(id: 1533, name: "V-Strom 650", brandId: 3),
        // Kawasaki
        BrandModelItem(id: 1830, name: "Ninja ZX-10R", brandId: 4),
        BrandModelItem(id: 1832, name: "Ninja ZX-6R", brandId: 4),
        BrandModelItem(id: 1888, name: "Z900RS", brandId: 4),
        // BMW
        BrandModelItem(id: 1317, name: "S1000RR", brandId: 13),
        BrandModelItem(id: 1311, name: "R1200GS", brandId: 13),
        // Ducati
        BrandModelItem(id: 1047, name: "Panigale", brandId: 7),
        BrandModelItem(id: 1060, name: "Monster", brandId: 7)
    ]
    
    // Default descriptions per brand
    let brandDescriptions: [String: String] = [
        "Honda": "Honda is the world's largest motorcycle manufacturer, known for reliability, quality, and a diverse range of bikes from commuters to superbikes.",
        "Yamaha": "Yamaha Motor Company produces motorcycles known for their performance, excitement, and innovative engineering, specifically in the sport and naked segments.",
        "Suzuki": "Suzuki offers a wide range of motorcycles, from the legendary Hayabusa to practical scooters, known for value and durability.",
        "Kawasaki": "Kawasaki motorcycles, often branded as 'Ninja', are famous for their high-performance engines, aggressive styling, and racing heritage.",
        "BMW": "BMW Motorrad manufactures premium motorcycles known for their technology, touring capabilities (GS series), and quality engineering.",
        "Ducati": "Ducati is an Italian manufacturer famous for its desmodromic valves, L-twin engines, and stunning design, often called the 'Ferrari of motorcycles'."
    ]
    
    func getModelUrl(brandId: Int, modelId: Int) -> String {
        return "https://motobay.su/brands/\(brandId)/models/\(modelId)"
    }
    
    // Fallback urls for demo - generated from popularModels
    var demoUrls: [String] {
        return popularModels.map { getModelUrl(brandId: $0.brandId, modelId: $0.id) }
    }
    
    func getDescription(for brandName: String) -> String {
        return brandDescriptions.first { brandName.contains($0.key) }?.value ?? "A premium motorcycle from a top manufacturer."
    }
}
