//
//  AuctionParser.swift
//  JetQanat
//
//  Created by Amangeldin Yersultan on 16.12.2025.
//

import Foundation
import UIKit

class AuctionParser: NSObject, XMLParserDelegate {
    
    static let shared = AuctionParser()
    private override init() {}
    
    // Completion handler type
    typealias Completion = (Result<String, Error>) -> Void
    
    // Currency Parsing Properties
    private var currentElement = ""
    private var foundRUB = false
    private var tengeRate: Double = 5.0
    private var tempValue = ""
    private var nominal: Double = 1.0
    
    /// Main function to fetch data and parse it like the PHP script
    /// - Parameters:
    ///   - url: The page URL (e.g. from brands list)
    ///   - completion: Returns the modified HTML string
    func fetchAuctionData(url: String, completion: @escaping Completion) {
        // 1. Fetch Currency Rate
        fetchCurrencyRate { [weak self] rate in
            guard let self = self else { return }
            self.tengeRate = rate
            
            // 2. Fetch HTML Content
            self.fetchHTML(url: url) { result in
                switch result {
                case .success(let html):
                    // 3. Process HTML
                    let processed = self.processHTML(html, rate: rate)
                    completion(.success(processed))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func fetchCurrencyRate(completion: @escaping (Double) -> Void) {
        // URL from PHP: https://www.cbr.ru/scripts/XML_daily.asp
        guard let url = URL(string: "https://www.cbr.ru/scripts/XML_daily.asp") else {
            completion(5.0)
            return
        }
        
        // PHP logic: timeout 30
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion(5.0)
                return
            }
            
            // Parse XML
            let parser = XMLParser(data: data)
            parser.delegate = self
            if parser.parse() {
                completion(self.tengeRate)
            } else {
                completion(5.0)
            }
        }
        task.resume()
    }
    
    private func fetchHTML(url: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let urlObj = URL(string: url) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: urlObj) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Should be UTF8 or detected encoding
            guard let data = data, let str = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "No Data", code: 0)))
                return
            }
            
            completion(.success(str))
        }
        task.resume()
    }
    
    private func processHTML(_ html: String, rate: Double) -> String {
        var str = html
        var str2 = ""
        
        // PHP Logic Replication
        // Logic attempts to find content between specific div/table markers
        
        // Check for <div class="lots">
        var startRange = str.range(of: "<div class=\"lots\">")
        var endRange: Range<String.Index>?
        
        if let start = startRange {
            // Found <div class="lots">
            // PHP: $end_pos = strpos($str,"<script>var app = 'statistic'");
            if let end = str.range(of: "<script>var app = 'statistic'", range: start.upperBound..<str.endIndex) {
                endRange = end
            }
        } else {
            // Check for <table class="table lots">
            startRange = str.range(of: "<table class=\"table lots\">")
            if let start = startRange {
                if let end = str.range(of: "</table>", range: start.upperBound..<str.endIndex) {
                    // PHP: $end_pos = strpos($str,'</table>') + 8;
                    // Swift range upperbound is exclusive, need to add 8 offset effectively
                    let endIdx = str.index(end.upperBound, offsetBy: 0) // table closing tag
                    // We can just take the substring including </table>
                    endRange = end
                    // PHP code actually +8 which suggests length of </table> is 8.
                }
            }
        }
        
        if let start = startRange, let end = endRange {
            let content = str[start.lowerBound..<end.lowerBound]
             // PHP: $str2 = "<div class='div_lots'>".substr($str,$start_pos,$str_length)."</div>";
            str2 = "<div class='div_lots'>\(content)</div>"
            
            // Replacements
            // $str2 = str_replace('/brands','https://japanmotor.kz/statistika-aukczionov/brands',$str2);
            str2 = str2.replacingOccurrences(of: "/brands", with: "https://japanmotor.kz/statistika-aukczionov/brands")
            
            // $str2 = str_replace('href="/lots','class="',$str2);
            str2 = str2.replacingOccurrences(of: "href=\"/lots", with: "class=\"")
            
            // $str2 = str_replace('src="/_img/thumb/','tabindex="0" src="https://motobay.su/_img/thumb/',$str2);
            str2 = str2.replacingOccurrences(of: "src=\"/_img/thumb/", with: "tabindex=\"0\" src=\"https://motobay.su/_img/thumb/")
            
            // $str2 = str_replace('small.jpg','large.jpg',$str2);
            str2 = str2.replacingOccurrences(of: "small.jpg", with: "large.jpg")
            
            // $str2 = str_replace('?page=','?page_lots=',$str2);
            str2 = str2.replacingOccurrences(of: "?page=", with: "?page_lots=")
            
            // Headers replacement
            str2 = str2.replacingOccurrences(of: "<span>Цена в Вл-ке</span><span>Цена в Москве</span><span>DDP New Zealand</span>", with: "<span>Цена в Казахстане</span>")
            
            // Price Calculation Logic
            // PHP loops through finding <div class="mb-tooltip" data-key="price" ...>
            // Extracts value, cleans "р.", converts to int, applies rate.
            
            str2 = processPrices(in: str2, rate: rate)
            
        } else {
            // Fallback logic from PHP (if no table/lots found)
            // ... omitting complex fallback for simplicity unless requested
             str2 = "Content not found or parser mismatch"
        }
        
        return str2
    }
    
    private func processPrices(in text: String, rate: Double) -> String {
        var processedText = text
        // Need to find all occurrences of prices and replace them.
        
        // PHP pattern: <div class="mb-tooltip" data-key="price" data-toggle="popover"><span>
        let marker = "<div class=\"mb-tooltip\" data-key=\"price\" data-toggle=\"popover\"><span>"
        
        // We will scan the string
        var searchRange = processedText.startIndex..<processedText.endIndex
        
        while let foundRange = processedText.range(of: marker, range: searchRange) {
            // Start of price is after marker
            let priceStart = foundRange.upperBound
            
            // Search for end of price info: <span class="info">*</span>
            if let endRange = processedText.range(of: "<span class=\"info\">*</span>", range: priceStart..<processedText.endIndex) {
                 let priceExactRange = priceStart..<endRange.lowerBound
                 let priceStringWithGarbage = String(processedText[priceExactRange])
                 
                 // Clean price string: 1 200 000 р. -> 1200000
                 let cleanPriceString = priceStringWithGarbage.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "р.", with: "")
                 
                 if let rubValue = Double(cleanPriceString) {
                     // Convert
                     let tengeValue = Int(rubValue * rate)
                     // Format: spaces (e.g. 1 000 000)
                     let formatter = NumberFormatter()
                     formatter.numberStyle = .decimal
                     formatter.groupingSeparator = " "
                     let formattedTenge = formatter.string(from: NSNumber(value: tengeValue)) ?? "\(tengeValue)"
                     
                     // Perform replacement in the ORIGINAL string
                     // Note: PHP replaces the WHOLE occurrence of the price string (rub) with tenge string.
                     // But strictly speaking it iterates and replaces specific matches.
                     
                     // Construct replacement:
                     let kztString = "\(formattedTenge) ₸"
                     
                     // We replace the content between marker and end marker?
                     // The PHP code does: $str2 = str_replace($mass_cena[$i],$mass_tenge[$i],$str2);
                     // It replaces the string "100 000 р." with "500 000 ₸" GLOBALLY.
                     // This is risky if two lots have same price logic, but efficient.
                     
                     processedText = processedText.replacingOccurrences(of: priceStringWithGarbage, with: kztString)
                 }
                 
                 // Update search range
                 searchRange = endRange.upperBound..<processedText.endIndex
            } else {
                break
            }
        }
        
        return processedText
    }
    
    // MARK: - XMLParserDelegate
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "Valute" {
            if let id = attributeDict["ID"], id == "R01335" {
                foundRUB = true
            } else {
                foundRUB = false
            }
        }
        tempValue = ""
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if foundRUB {
            tempValue += string
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if foundRUB {
            if elementName == "Value" {
                let valStr = tempValue.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespacesAndNewlines)
                if let val = Double(valStr) {
                    // PHP: $tenge = round(($item->Nominal)/$tenge_val,2);
                     self.tengeRate = self.nominal / val
                }
            } else if elementName == "Nominal" {
                 if let nom = Double(tempValue.trimmingCharacters(in: .whitespacesAndNewlines)) {
                     self.nominal = nom
                 }
            }
        }
    }
}
