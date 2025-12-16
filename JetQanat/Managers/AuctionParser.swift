import Foundation
import UIKit

// MARK: - Models
// (Структуры Brand и BrandModel остаются без изменений)

struct Brand: Identifiable, Codable {
    let id: Int
    let name: String
    let url: String
}

struct BrandModel: Identifiable, Codable {
    let id: Int
    let name: String
    let url: String
}

// Предполагаем, что struct Bike у вас есть где-то еще, 
// так как в исходном коде его определения не было, но он использовался.

/// Используем `actor` вместо `class singleton` для потокобезопасности
actor AuctionParser {
    
    static let shared = AuctionParser()
    private init() {}
    
    // Создаем сессию с таймаутом один раз
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        return URLSession(configuration: config)
    }()
    
    // MARK: - API (Async)
    
    /// Fetches all brands from the main page
    func fetchBrands() async throws -> [Brand] {
        let url = "https://motobay.su/brands"
        let html = try await fetchHTML(url: url)
        
        // Парсинг переносим в отдельную задачу, чтобы не блокировать актор
        return await Task.detached(priority: .userInitiated) {
            return self.parseBrands(from: html)
        }.value
    }
    
    /// Fetches models for a given brand
    func fetchModels(for brand: Brand, limit: Int = 10) async throws -> [BrandModel] {
        let html = try await fetchHTML(url: brand.url)
        
        return await Task.detached(priority: .userInitiated) {
            var models = self.parseModels(from: html)
            if limit > 0 {
                models = Array(models.prefix(limit))
            }
            return models
        }.value
    }
    
    /// Fetches bikes for a specific model URL
    func fetchBikes(url: String) async throws -> [Bike] {
        // Стабильный курс, как у вас в коде
        let rate = 5.0
        
        let html = try await fetchHTML(url: url)
        
        return await Task.detached(priority: .userInitiated) {
            return self.parseBikes(from: html, rate: rate)
        }.value
    }
    
    // MARK: - Networking
    
    private func fetchHTML(url: String) async throws -> String {
        guard let urlObj = URL(string: url) else {
            throw URLError(.badURL)
        }
        
        // Используем современный async метод URLSession
        let (data, response) = try await session.data(from: urlObj)
        
        guard let httpResponse = response as? HTTPURLResponse, 
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        guard let str = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        return str
    }
    
    // MARK: - Parsing Logic (Non-isolated to run in detached tasks)
    
    // nonisolated позволяет вызывать эти методы из Task.detached без перехода обратно в актор
    private nonisolated func parseBrands(from html: String) -> [Brand] {
        var brands: [Brand] = []
        let pattern = "<li><a href=\"/brands/(\\d+)\">([^<]+)</a></li>"
        let matches = self.matches(for: pattern, in: html)
        
        for match in matches {
            if let id = Int(match[1]) {
                let name = match[2].trimmingCharacters(in: .whitespacesAndNewlines)
                let url = "https://motobay.su/brands/\(id)"
                if id > 0 {
                    brands.append(Brand(id: id, name: name, url: url))
                }
            }
        }
        return brands
    }
    
    private nonisolated func parseModels(from html: String) -> [BrandModel] {
        var models: [BrandModel] = []
        let pattern = "<a href=\"(/brands/\\d+/models/(\\d+))\">([^<]+)</a>"
        let matches = self.matches(for: pattern, in: html)
        
        for match in matches {
            let relativeUrl = match[1]
            if let id = Int(match[2]) {
                let name = match[3].trimmingCharacters(in: .whitespacesAndNewlines)
                let url = "https://motobay.su" + relativeUrl
                if id > 0 {
                    models.append(BrandModel(id: id, name: name, url: url))
                }
            }
        }
        return models
    }
    
    private nonisolated func parseBikes(from html: String, rate: Double) -> [Bike] {
        var bikes: [Bike] = []
        
        let rowPattern = "<tr[^>]*data-id=\"(\\d+)\"[^>]*>(.*?)</tr>"
        let rows = matches(for: rowPattern, in: html)
        
        for row in rows {
            let id = row[1]
            let content = row[2]
            
            func extract(pattern: String) -> String? {
                if let match = firstMatch(for: pattern, in: content) {
                    return match[1].trimmingCharacters(in: .whitespacesAndNewlines)
                        .replacingOccurrences(of: "&#13;", with: "")
                        .replacingOccurrences(of: "&nbsp;", with: " ")
                }
                return nil
            }
            
            var imageUrl = ""
            if let imgMatch = firstMatch(for: "<img[^>]+src=\"([^\"]+)\"", in: content) {
                imageUrl = imgMatch[1]
                if imageUrl.starts(with: "/") {
                    imageUrl = "https://motobay.su" + imageUrl
                }
            }
            
            let title = extract(pattern: "<span class=\"make\">([^<]+)</span>") ?? "Unknown Bike"
            let lotNumber = extract(pattern: "<span class=\"number\">([^<]+)</span>")
            let auction = extract(pattern: "<span class=\"area\">([^<]+)</span>")
            let date = extract(pattern: "<span class=\"date\">([^<]+)</span>")
            
            // Regex improvements for parsing fields that might have attributes or whitespace
            
            var year: String?
            // Match <td>YYYY</td> with optional attributes and whitespace
            if let yearMatch = firstMatch(for: "<td[^>]*>\\s*(\\d{4})\\s*</td>", in: content) { 
                year = yearMatch[1] 
            }
            
            var engineVolume: String?
            // Match 3-4 digits that isn't the year
            if let engineMatch = firstMatch(for: "<td[^>]*>\\s*(\\d{3,4})\\s*</td>", in: content) {
                if engineMatch[1] != year { engineVolume = engineMatch[1] }
            }
            
            let frame = extract(pattern: "class=\"chassis_n\"[^>]*>([^<]+)</span>")
            let mileage = extract(pattern: "class=\"mileage\"[^>]*>([^<]+)</td>")
            let rating = extract(pattern: "class=\"score\"[^>]*>([^<]+)</td>")
            
            var status: String?
            if let statusMatch = firstMatch(for: "<td[^>]*>\\s*(SOLD|Unsold|Available)\\s*</td>", in: content) { status = statusMatch[1] }
            
            var price = 0
            if let priceMatch = firstMatch(for: "<span>([\\d\\s]+) р\\.", in: content) {
                let pStr = priceMatch[1].replacingOccurrences(of: " ", with: "")
                                              .replacingOccurrences(of: "\u{00A0}", with: "")
                price = Int(pStr) ?? 0
            } else if let yenMatch = firstMatch(for: "<span class=\"price-total\">([\\d\\s]+) ¥</span>", in: content) {
                 let pStr = yenMatch[1].replacingOccurrences(of: " ", with: "")
                 _ = Double(pStr) ?? 0
            }
            
            var startPrice: String?
            if let startMatch = firstMatch(for: "<span class=\"price-start\">([\\d\\s]+ ¥)</span>", in: content) {
                startPrice = startMatch[1]
            }
            
            let convertedPrice = Int(Double(price) * rate)
            
            // ВАЖНО: Убедитесь, что struct Bike инициализируется верно
            var bike = Bike(
                id: Int(id) ?? 0,
                name: title,
                price: convertedPrice,
                category: "Motorcycles",
                type: "auction",
                image_url: imageUrl
            )
            
            bike.lotNumber = lotNumber
            bike.auction = auction
            bike.date = date
            bike.year = year
            bike.engineVolume = engineVolume
            bike.frame = frame
            bike.mileage = mileage
            bike.rating = rating
            bike.startPrice = startPrice
            bike.status = status
            
            bikes.append(bike)
        }
        
        return bikes
    }
    
    // MARK: - Regex Helpers
    
    private nonisolated func matches(for regex: String, in text: String) -> [[String]] {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [.dotMatchesLineSeparators])
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map { match in
                (0..<match.numberOfRanges).map {
                    let range = match.range(at: $0)
                    return range.location != NSNotFound ? String(text[Range(range, in: text)!]) : ""
                }
            }
        } catch { return [] }
    }
    
    private nonisolated func firstMatch(for regex: String, in text: String) -> [String]? {
        return matches(for: regex, in: text).first
    }
}