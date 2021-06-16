//
//  ShippingAddress+CoreDataProperties.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 3/3/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension ShippingAddress {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShippingAddress> {
        return NSFetchRequest<ShippingAddress>(entityName: "ShippingAddress")
    }

    @NSManaged public var address: String?
    @NSManaged public var country: String?
    @NSManaged public var email: String?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var phone: String?
    @NSManaged public var postalCode: String?
    @NSManaged public var primary: Bool
    @NSManaged public var state: String?
    @NSManaged public var type: String?
    @NSManaged public var dateCreated: Date?
    @NSManaged public var customer: User?

}
