//
//  OrderEntity+CoreDataProperties.swift
//  project_ios
//
//  Created by Abylay Zholdybay on 15.12.2025.
//
//

public import Foundation
public import CoreData


@objc(OrderEntity)
public class OrderEntity: NSManagedObject {

}

public typealias OrderEntityCoreDataPropertiesSet = NSSet

extension OrderEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OrderEntity> {
        return NSFetchRequest<OrderEntity>(entityName: "OrderEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var orderCode: String?
    @NSManaged public var status: String?
    @NSManaged public var totalAmount: Double
    @NSManaged public var type: String?
    @NSManaged public var createdAt: Date?

}

extension OrderEntity : Identifiable {

}
