//
//  RentalBike.swift
//  JetQanat
//
//  Created by Zholdibay Abylay on 16.12.2025.
//

import Foundation

struct RentalBike: Identifiable {
    let id = UUID()
    let model: String
    let imageName: String
    let pricePerPeriod: Double 
    let rating: Double
    let reviewCount: Int
    let location: String
    let ownerName: String
}
