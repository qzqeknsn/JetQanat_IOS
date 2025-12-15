//
//  CartItemEntity+CoreDataProperties.swift
//  project_ios
//
//  Created by Abylay Zholdybay on 15.12.2025.
//
//

public import Foundation
public import CoreData


@objc(CartItemEntity)
public class CartItemEntity: NSManagedObject {

}

public typealias CartItemEntityCoreDataPropertiesSet = NSSet

extension CartItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CartItemEntity> {
        return NSFetchRequest<CartItemEntity>(entityName: "CartItemEntity")
    }

    @NSManaged public var productCategory: String?
    @NSManaged public var productId: Int64
    @NSManaged public var productImage: String?
    @NSManaged public var productPriceValue: Double
    @NSManaged public var productTitle: String?
    @NSManaged public var quantity: Int16

}

extension CartItemEntity : Identifiable {

}
