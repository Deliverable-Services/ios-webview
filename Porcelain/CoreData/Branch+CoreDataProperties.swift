//
//  Branch+CoreDataProperties.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 11/5/19.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension Branch {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Branch> {
        return NSFetchRequest<Branch>(entityName: "Branch")
    }

    @NSManaged public var address1: String?
    @NSManaged public var address2: String?
    @NSManaged public var canBook: Bool
    @NSManaged public var centerCode: String?
    @NSManaged public var city: String?
    @NSManaged public var code: String?
    @NSManaged public var contactsRaw: String?
    @NSManaged public var email: String?
    @NSManaged public var id: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var operatingHoursRaw: String?
    @NSManaged public var organizationName: String?
    @NSManaged public var state: String?
    @NSManaged public var whatsapp: String?
    @NSManaged public var window: String?

}
