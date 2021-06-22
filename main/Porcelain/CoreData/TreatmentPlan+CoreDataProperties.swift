//
//  TreatmentPlan+CoreDataProperties.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 11/5/19.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension TreatmentPlan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TreatmentPlan> {
        return NSFetchRequest<TreatmentPlan>(entityName: "TreatmentPlan")
    }

    @NSManaged public var createdByID: String?
    @NSManaged public var customerID: String?
    @NSManaged public var cycles: Int32
    @NSManaged public var dateCreated: Date?
    @NSManaged public var dateUpdated: Date?
    @NSManaged public var editedByID: String?
    @NSManaged public var estimateDuration: String?
    @NSManaged public var id: String?
    @NSManaged public var status: Bool
    @NSManaged public var templateID: String?
    @NSManaged public var treatmentPhase: String?
    @NSManaged public var customer: User?
    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for items
extension TreatmentPlan {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: TreatmentPlanItem)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: TreatmentPlanItem)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}
