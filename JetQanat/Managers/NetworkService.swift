//
//  NetworkService.swift
//  JetQanat
//
//  Created by Zholdibay Abylay on 16.12.2025.
//

import Foundation
import Combine

class NetworkService {
    
    static let shared = NetworkService()
    
    private let urlString = "http://127.0.0.1:8000/motorcycles"
    
    func fetchMotorcycles() -> AnyPublisher<[Bike], Error> {
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Bike].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
