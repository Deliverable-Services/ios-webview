//
//  Card+CoreDataProperties.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 2/27/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension Card {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card")
    }

    @NSManaged public var brandRaw: String?
    @NSManaged public var country: String?
    @NSManaged public var cvcCheck: String?
    @NSManaged public var expMonth: Int32
    @NSManaged public var expYear: Int32
    @NSManaged public var funding: String?
    @NSManaged public var id: String?
    @NSManaged public var isDefault: Bool
    @NSManaged public var last4: String?
    @NSManaged public var name: String?
    @NSManaged public var dateCreated: Date?
    @NSManaged public var customer: User?

}
