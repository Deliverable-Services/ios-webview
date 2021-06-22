//
//  Note+CoreDataProperties.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 06/10/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var id: String?
    @NSManaged public var isPrivate: Bool
    @NSManaged public var note: String?
    @NSManaged public var userID: String?
    @NSManaged public var appointment: Appointment?

}
