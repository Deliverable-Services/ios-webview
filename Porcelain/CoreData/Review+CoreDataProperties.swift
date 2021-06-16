//
//  Review+CoreDataProperties.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 3/12/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension Review {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Review> {
        return NSFetchRequest<Review>(entityName: "Review")
    }

    @NSManaged public var dateCreated: Date?
    @NSManaged public var email: String?
    @NSManaged public var id: String?
    @NSManaged public var rate: Int32
    @NSManaged public var review: String?
    @NSManaged public var reviewer: String?
    @NSManaged public var status: String?
    @NSManaged public var wcID: String?
    @NSManaged public var productID: String?
    @NSManaged public var verified: Bool
    @NSManaged public var isActive: Bool

}
