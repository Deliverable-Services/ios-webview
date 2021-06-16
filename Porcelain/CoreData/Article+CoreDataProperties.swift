//
//  Article+CoreDataProperties.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 06/10/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension Article {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Article> {
        return NSFetchRequest<Article>(entityName: "Article")
    }

    @NSManaged public var aType: String?
    @NSManaged public var category: String?
    @NSManaged public var dateCreated: Date?
    @NSManaged public var datePublish: Date?
    @NSManaged public var dateUpdated: Date?
    @NSManaged public var description_: String?
    @NSManaged public var id: String?
    @NSManaged public var img: String?
    @NSManaged public var sortIndex: Int32
    @NSManaged public var source: String?
    @NSManaged public var title: String?
    @NSManaged public var type: String?

}
