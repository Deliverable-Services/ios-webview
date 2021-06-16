//
//  CustomerProduct+CoreDataProperties.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 3/13/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension CustomerProduct {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CustomerProduct> {
        return NSFetchRequest<CustomerProduct>(entityName: "CustomerProduct")
    }

    @NSManaged public var categoryID: String?
    @NSManaged public var categoryName: String?
    @NSManaged public var customerID: String?
    @NSManaged public var datePurchased: Date?
    @NSManaged public var id: String?
    @NSManaged public var image: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var name: String?
    @NSManaged public var price: Double
    @NSManaged public var quantity: Int32
    @NSManaged public var size: String?
    @NSManaged public var usage: Double
    @NSManaged public var variationID: String?
    @NSManaged public var variationRaw: String?
    @NSManaged public var benefits: [String]?

}
