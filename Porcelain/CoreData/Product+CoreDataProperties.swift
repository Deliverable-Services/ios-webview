//
//  Product+CoreDataProperties.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 5/13/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var application: String?
    @NSManaged public var attributesRaw: String?
    @NSManaged public var averageRating: Double
    @NSManaged public var categoryID: String?
    @NSManaged public var categoryIDs: String?
    @NSManaged public var categoryName: String?
    @NSManaged public var desc: String?
    @NSManaged public var featured: Bool
    @NSManaged public var id: String?
    @NSManaged public var imagesRaw: String?
    @NSManaged public var inStock: Bool
    @NSManaged public var isActive: Bool
    @NSManaged public var name: String?
    @NSManaged public var price: Double
    @NSManaged public var quote: String?
    @NSManaged public var review: String?
    @NSManaged public var shortContent: String?
    @NSManaged public var shortDesc: String?
    @NSManaged public var shortHeader: String?
    @NSManaged public var size: String?
    @NSManaged public var sku: String?
    @NSManaged public var status: String?
    @NSManaged public var totalReviews: Int32
    @NSManaged public var url: String?
    @NSManaged public var regularPrice: Double
    @NSManaged public var salePrice: Double
    @NSManaged public var purchasable: Bool
    @NSManaged public var stockStatus: String?
    @NSManaged public var onSale: Bool

}
