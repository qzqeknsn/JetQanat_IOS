import Foundation
import MapKit
import Combine

import CoreData

class ServicesViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.238949, longitude: 76.889709),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @Published var isRequesting = false
    @Published var requestStatus: RequestStatus = .idle
    
    enum RequestStatus {
        case idle
        case searching
        case confirmed
        case arrived
    }
    
    func requestAssistance() {
        isRequesting = true
        requestStatus = .searching
        
        saveServiceRequest()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.requestStatus = .confirmed
        }
    }
    
    private func saveServiceRequest() {
        let context = CoreDataManager.shared.context
        guard let entity = NSEntityDescription.entity(forEntityName: "OrderEntity", in: context) else { return }
        
        let order = NSManagedObject(entity: entity, insertInto: context)
        let code = String(UUID().uuidString.prefix(8)).uppercased()
        
        order.setValue(UUID(), forKey: "id")
        order.setValue("SOS-\(code)", forKey: "orderCode")
        order.setValue(15000.0, forKey: "totalAmount") 
        order.setValue("Requested", forKey: "status")
        order.setValue("Service", forKey: "type")
        order.setValue(Date(), forKey: "createdAt")
        
        CoreDataManager.shared.saveContext()
    }
    
    func cancelRequest() {
        isRequesting = false
        requestStatus = .idle
    }
}
