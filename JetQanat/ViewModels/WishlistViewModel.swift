//
//  WishlistViewModel.swift
//  JetQanat
//
//  Created by Zholdibay Abylay on 15.12.2025.
//

import Foundation
import Combine

class WishlistViewModel: ObservableObject {
    @Published var wishlistItems: Set<Int> = []
    
    static let shared = WishlistViewModel()
    
    init() {
    }
    
    func toggleWishlist(bikeId: Int) {
        if wishlistItems.contains(bikeId) {
            wishlistItems.remove(bikeId)
        } else {
            wishlistItems.insert(bikeId)
        }
    }
    
    func isInWishlist(bikeId: Int) -> Bool {
        return wishlistItems.contains(bikeId)
    }
    
    var wishlistCount: Int {
        return wishlistItems.count
    }
}
