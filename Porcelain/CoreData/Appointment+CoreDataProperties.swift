//
//  Appointment+CoreDataProperties.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 10/23/19.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension Appointment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Appointment> {
        return NSFetchRequest<Appointment>(entityName: "Appointment")
    }

    @NSManaged public var centerID: String?
    @NSManaged public var dateApproved: Date?
    @NSManaged public var dateBooked: Date?
    @NSManaged public var dateEnd: Date?
    @NSManaged public var dateStart: Date?
    @NSManaged public var id: String?
    @NSManaged public var invoiceID: String?
    @NSManaged public var monthYear: Date?
    @NSManaged public var reservationID: String?
    @NSManaged public var sessionsLeft: Int32
    @NSManaged public var source: String?
    @NSManaged public var state: String?
    @NSManaged public var status: Int32
    @NSManaged public var therapistID: String?
    @NSManaged public var type: String?
    @NSManaged public var userID: String?
    @NSManaged public var serviceIDs: [String]?
    @NSManaged public var customer: User?
    @NSManaged public var note: Note?
    @NSManaged public var therapist: User?

}
