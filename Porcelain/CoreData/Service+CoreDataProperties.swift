//
//  Service+CoreDataProperties.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 11/6/19.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension Service {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Service> {
        return NSFetchRequest<Service>(entityName: "Service")
    }

    @NSManaged public var afterCare: [String]?
    @NSManaged public var award: [String]?
    @NSManaged public var benefits: [String]?
    @NSManaged public var centerID: String?
    @NSManaged public var desc: String?
    @NSManaged public var displayName: String?
    @NSManaged public var duration: String?
    @NSManaged public var id: String?
    @NSManaged public var image: String?
    @NSManaged public var isVisible: Bool
    @NSManaged public var name: String?
    @NSManaged public var notSuitableFor: [String]?
    @NSManaged public var permalink: String?
    @NSManaged public var price: String?
    @NSManaged public var procedure: [String]?
    @NSManaged public var suitableFor: [String]?
    @NSManaged public var type: String?
    @NSManaged public var categoryName: String?
    @NSManaged public var categoryID: String?

}
