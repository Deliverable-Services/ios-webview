//
//  Prescription+CoreDataProperties.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 06/10/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension Prescription {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Prescription> {
        return NSFetchRequest<Prescription>(entityName: "Prescription")
    }

    @NSManaged public var afterNumberOfDays: Int32
    @NSManaged public var frequencyRaw: String?
    @NSManaged public var id: String?
    @NSManaged public var numberOfPumps: Int32
    @NSManaged public var productRaw: String?
    @NSManaged public var sequenceNumber: Int32
    @NSManaged public var therapistRaw: String?
    @NSManaged public var customer: User?

}
