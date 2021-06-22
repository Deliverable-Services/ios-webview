//
//  CustomerProduct+CoreDataClass.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 3/12/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON
import R4pidKit

@objc(CustomerProduct)
public class CustomerProduct: NSManagedObject {
  public static func getProducts(productIDs: [String]? = nil, customerID: String, inMOC: NSManagedObjectContext = .main) -> [CustomerProduct] {
    var predicates: [CoreDataRecipe.Predicate] = [.isEqual(key: "customerID", value: customerID)]
    if let productIDs = productIDs, !productIDs.isEmpty {
      if productIDs.count == 1, let productID = productIDs.first {
        predicates.append(.isEqual(key: "id", value: productID))
      } else  {
        predicates.append(.isEqualIn(key: "id", values: productIDs))
      }
    }
    
    return CoreDataUtil.list(CustomerProduct.self, predicate: .compoundAnd(predicates: predicates), inMOC: inMOC)
  }
  
  public static func getProduct(id: String, customerID: String, inMOC: NSManagedObjectContext = .main) -> CustomerProduct? {
    return getProducts(productIDs: [id], customerID: customerID, inMOC: inMOC).first
  }
  
  public func updateFromData(_ data: JSON, customerID: String) {
    id = data.productID.numberString
    self.customerID = customerID
    name = data.name.string
    price = data.price.doubleValue
    quantity = data.quantity.int32Value
    datePurchased = data["purchase_date"].toDate(format: .ymdhmsDateFormat)
    image = data.image.string
    size = data.size.string
    usage = data.usage.doubleValue
    benefits = data.benefits.array?.compactMap({ $0.string ?? $0.name.string })
    categoryID = data.category.categoryID.numberString
    categoryName = data.category.name.string
    variationID = data.variation.variationID.numberString
    variationRaw = data.variation.rawString()
  }
  
  @discardableResult
  public static func parseProductFromData(_ data: JSON, customerID: String, products: [CustomerProduct], inMOC: NSManagedObjectContext) -> CustomerProduct? {
    guard let productID = data.productID.numberString else { return nil }
    let currentProduct = products.first(where: { $0.id == productID })
    let product = CoreDataUtil.createEntity(CustomerProduct.self, fromEntity: currentProduct, inMOC: inMOC)
    product.updateFromData(data, customerID: customerID)
    return product
  }
  
  public static func parseProductsFromData(_ data: JSON, customerID: String, inMOC: NSManagedObjectContext) {
    let productArray = data.array ?? []
    let productIDs = productArray.compactMap({ $0.productID.numberString })
    
    let deprecatedProducts = CoreDataUtil.list(
      CustomerProduct.self,
      predicate: .compoundAnd(predicates: [
        .isEqual(key: "isActive", value: true),
        .isEqual(key: "customerID", value: customerID),
        .notEqualIn(key: "id", values: productIDs)]),
      inMOC: inMOC)
    deprecatedProducts.forEach { (product) in
      product.isActive = false
    }
    
    let products = getProducts(productIDs: productIDs, customerID: customerID, inMOC: inMOC)
    productArray.forEach { (data) in
      guard let product = parseProductFromData(data, customerID: customerID, products: products, inMOC: inMOC) else { return }
      product.isActive = true
    }
  }
}
