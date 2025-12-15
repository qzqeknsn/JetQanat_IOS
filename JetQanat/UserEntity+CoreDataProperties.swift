//
//  UserEntity+CoreDataProperties.swift
//  project_ios
//
//  Created by Abylay Zholdybay on 15.12.2025.
//
//

public import Foundation
public import CoreData


@objc(UserEntity)
public class UserEntity: NSManagedObject {

}

public typealias UserEntityCoreDataPropertiesSet = NSSet

extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    @NSManaged public var email: String?
    @NSManaged public var fullName: String?
    @NSManaged public var id: UUID?
    @NSManaged public var isVerified: Bool
    @NSManaged public var password: String?
    @NSManaged public var phone: String?

}

extension UserEntity : Identifiable {

}
