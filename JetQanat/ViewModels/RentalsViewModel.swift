import Foundation
import Combine

class RentalsViewModel {
    @Published var rentals: [RentalBike] = []
    
    init() {
        loadRentals()
    }
    
    func loadRentals() {
        self.rentals = [
            RentalBike(model: "Yamaha R1", imageName: "r1_rental", pricePerPeriod: 150, rating: 4.8, reviewCount: 124, location: "Tokyo, Shibuya", ownerName: "Mike R."),
            RentalBike(model: "Honda CBR1000RR", imageName: "cbr_rental", pricePerPeriod: 140, rating: 4.7, reviewCount: 98, location: "Osaka, Kita", ownerName: "Kenji S."),
            RentalBike(model: "Kawasaki Ninja 400", imageName: "ninja400_rental", pricePerPeriod: 80, rating: 4.9, reviewCount: 210, location: "Kyoto, Central", ownerName: "Sakura M."),
            RentalBike(model: "Ducati Monster", imageName: "monster_rental", pricePerPeriod: 120, rating: 4.6, reviewCount: 85, location: "Tokyo, Shinjuku", ownerName: "Luigi P."),
            RentalBike(model: "BMW S1000RR", imageName: "s1000rr_rental", pricePerPeriod: 180, rating: 5.0, reviewCount: 64, location: "Yokohama", ownerName: "Hans G.")
        ]
    }
}
