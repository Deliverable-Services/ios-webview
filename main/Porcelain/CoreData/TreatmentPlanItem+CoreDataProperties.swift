//
//  TreatmentPlanItem+CoreDataProperties.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 11/20/19.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension TreatmentPlanItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TreatmentPlanItem> {
        return NSFetchRequest<TreatmentPlanItem>(entityName: "TreatmentPlanItem")
    }

    @NSManaged public var addonsRaw: String?
    @NSManaged public var appointmentID: String?
    @NSManaged public var booked: Bool
    @NSManaged public var id: String?
    @NSManaged public var interval: String?
    @NSManaged public var isLocked: Bool
    @NSManaged public var sequenceNumber: Int32
    @NSManaged public var serviceRaw: String?
    @NSManaged public var sessionsLeft: Int32
    @NSManaged public var status: Int32
    @NSManaged public var planID: String?
    @NSManaged public var plan: TreatmentPlan?

}
