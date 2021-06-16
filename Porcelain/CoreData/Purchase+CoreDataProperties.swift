//
//  Purchase+CoreDataProperties.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 5/12/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension Purchase {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Purchase> {
        return NSFetchRequest<Purchase>(entityName: "Purchase")
    }

    @NSManaged public var address: String?
    @NSManaged public var chargeID: String?
    @NSManaged public var city: String?
    @NSManaged public var contact: String?
    @NSManaged public var customerID: String?
    @NSManaged public var dateCreated: Date?
    @NSManaged public var datePaid: Date?
    @NSManaged public var dateUpdated: Date?
    @NSManaged public var discount: Double
    @NSManaged public var email: String?
    @NSManaged public var id: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var monthYear: Date?
    @NSManaged public var postal: String?
    @NSManaged public var purchasedItemsRaw: String?
    @NSManaged public var shipping: Double
    @NSManaged public var source: String?
    @NSManaged public var status: String?
    @NSManaged public var total: Double
    @NSManaged public var totalAmount: Double
    @NSManaged public var variationsRaw: String?
    @NSManaged public var wcOrderID: String?
    @NSManaged public var wcOrderNumber: String?

}
