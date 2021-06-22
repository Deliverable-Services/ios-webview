//
//  AppNotification+CoreDataProperties.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 1/23/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension AppNotification {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AppNotification> {
        return NSFetchRequest<AppNotification>(entityName: "AppNotification")
    }

    @NSManaged public var action: String?
    @NSManaged public var commonID: String?
    @NSManaged public var commonIDType: String?
    @NSManaged public var dateCreated: Date?
    @NSManaged public var dateSent: Date?
    @NSManaged public var dateUpdated: Date?
    @NSManaged public var id: String?
    @NSManaged public var isRead: Bool
    @NSManaged public var message: String?
    @NSManaged public var title: String?
    @NSManaged public var userID: String?
    @NSManaged public var url: String?
    @NSManaged public var customer: User?

}
