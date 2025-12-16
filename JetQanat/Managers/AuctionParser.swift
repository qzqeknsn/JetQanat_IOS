
import Foundation
import UIKit

// MARK: - Models

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

class AuctionParser {
    
    static let shared = AuctionParser()
    private init() {}
    
    // MARK: - API
    
    /// Fetches all brands from the main page
    func fetchBrands(completion: @escaping (Result<[Brand], Error>) -> Void) {
        let url = "https://motobay.su/brands"
        fetchHTML(url: url) { [weak self] result in
            switch result {
            case .success(let html):
                let brands = self?.parseBrands(from: html) ?? []
                completion(.success(brands))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Fetches models for a given brand
    func fetchModels(for brand: Brand, limit: Int = 10, completion: @escaping (Result<[BrandModel], Error>) -> Void) {
        fetchHTML(url: brand.url) { [weak self] result in
            switch result {
            case .success(let html):
                var models = self?.parseModels(from: html) ?? []
                if limit > 0 {
                    models = Array(models.prefix(limit))
                }
                completion(.success(models))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Fetches bikes for a specific model URL
    func fetchBikes(url: String, completion: @escaping (Result<[Bike], Error>) -> Void) {
        // Bypass CBR.ru due to SSL errors (-1200)
        // Use a fixed rate for stability (Approx 5.0 KZT per RUB)
        let rate = 5.0
        
        self.fetchHTML(url: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let html):
                let bikes = self.parseBikes(from: html, rate: rate)
                completion(.success(bikes))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Parsing Logic
    
    private func parseBrands(from html: String) -> [Brand] {
        var brands: [Brand] = []
        let pattern = "<li><a href=\"/brands/(\\d+)\">([^<]+)</a></li>"
        let matches = self.matches(for: pattern, in: html)
        
        for match in matches {
            let id = Int(match[1]) ?? 0
            let name = match[2].trimmingCharacters(in: .whitespacesAndNewlines)
            let url = "https://motobay.su/brands/\(id)"
            if id > 0 {
                brands.append(Brand(id: id, name: name, url: url))
            }
        }
        return brands
    }
    
    private func parseModels(from html: String) -> [BrandModel] {
        var models: [BrandModel] = []
        let pattern = "<a href=\"(/brands/\\d+/models/(\\d+))\">([^<]+)</a>"
        let matches = self.matches(for: pattern, in: html)
        
        for match in matches {
            let relativeUrl = match[1]
            let id = Int(match[2]) ?? 0
            let name = match[3].trimmingCharacters(in: .whitespacesAndNewlines)
            let url = "https://motobay.su" + relativeUrl
            if id > 0 {
                models.append(BrandModel(id: id, name: name, url: url))
            }
        }
        return models
    }
    
    private func parseBikes(from html: String, rate: Double) -> [Bike] {
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
            
            var year: String?
            if let yearMatch = firstMatch(for: "<td>(\\d{4})</td>", in: content) { year = yearMatch[1] }
            
            var engineVolume: String?
            if let engineMatch = firstMatch(for: "<td>(\\d{3,4})</td>", in: content) {
                if engineMatch[1] != year { engineVolume = engineMatch[1] }
            }
            
            let frame = extract(pattern: "<span class=\"chassis_n\">([^<]+)</span>")
            let mileage = extract(pattern: "class=\"mileage\">([^<]+)</td>")
            let rating = extract(pattern: "class=\"score\">([^<]+)</td>")
            
            var status: String?
            if let statusMatch = firstMatch(for: "<td>(SOLD|Unsold|Available)</td>", in: content) { status = statusMatch[1] }
            
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
    
    // MARK: - Networking
    
    private func fetchHTML(url: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let urlObj = URL(string: url) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        let session = URLSession(configuration: config)
        
        session.dataTask(with: urlObj) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data, let str = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "No Data", code: 0)))
                return
            }
            completion(.success(str))
        }.resume()
    }
    
    private func fetchCurrencyRate(completion: @escaping (Double) -> Void) {
        let defaultRate = 5.0
        guard let url = URL(string: "https://www.cbr.ru/scripts/XML_daily.asp") else {
            completion(defaultRate); return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { completion(defaultRate); return }
            let parserDelegate = CurrencyParserDelegate()
            let parser = XMLParser(data: data)
            parser.delegate = parserDelegate
            if parser.parse() {
                completion(parserDelegate.rubToKztRate)
            } else {
                completion(defaultRate)
            }
        }.resume()
    }
    
    // MARK: - Regex Helpers
    
    private func matches(for regex: String, in text: String) -> [[String]] {
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
    
    private func firstMatch(for regex: String, in text: String) -> [String]? {
        return matches(for: regex, in: text).first
    }
}

// MARK: - Currency Parser Delegate
private final class CurrencyParserDelegate: NSObject, XMLParserDelegate, @unchecked Sendable {
    var rubToKztRate: Double = 5.0
    private var foundRUB = false
    private var nominal: Double = 1.0
    private var tempValue = ""
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "Valute" { foundRUB = (attributeDict["ID"] == "R01335") }
        tempValue = ""
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if foundRUB { tempValue += string }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if foundRUB {
            if elementName == "Value" {
                let valStr = tempValue.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespacesAndNewlines)
                if let val = Double(valStr), val > 0 { self.rubToKztRate = self.nominal / val }
            } else if elementName == "Nominal" {
                if let nom = Double(tempValue.trimmingCharacters(in: .whitespacesAndNewlines)) { self.nominal = nom }
            }
        }
        if elementName == "Valute" && foundRUB { foundRUB = false }
    }
}
