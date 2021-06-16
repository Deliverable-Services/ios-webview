//
//  Purchase+CoreDataClass.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 04/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON
import R4pidKit

public enum PurchaseStatus: String {
  case pendingPayment = "pending"
  case processing
  case onHold = "on-hold"
  case completed
  case cancelled
  case refunded
  case failed
  case trash
  case deleted
  
  public var title: String {
    switch self {
    case .pendingPayment:
      return "Pending"
    case .processing:
      return "Order Processing"
    case .onHold:
      return "On-Hold"
    case .completed:
      return "Completed"
    case .cancelled:
      return "Cancelled"
    case .refunded:
      return "Refunded"
    case .failed:
      return "Failed"
    case .trash:
      return "Trash"
    case .deleted:
      return "Deleted"
    }
  }
}

@objc(Purchase)
public class Purchase: NSManagedObject {
  public static func getPurchases(purchaseIDs: [String]? = nil, customerID: String, inMOC: NSManagedObjectContext = .main) -> [Purchase] {
    var predicates: [CoreDataRecipe.Predicate] = [.isEqual(key: "customerID", value: customerID)]
    if let purchaseIDs = purchaseIDs, !purchaseIDs.isEmpty {
      if purchaseIDs.count == 1, let purchaseID = purchaseIDs.first {
        predicates.append(.isEqual(key: "id", value: purchaseID))
      } else  {
        predicates.append(.isEqualIn(key: "id", values: purchaseIDs))
      }
    }
    return CoreDataUtil.list(Purchase.self, predicate: .compoundAnd(predicates: predicates), inMOC: inMOC)
  }
  
  public static func getPurchase(id: String, customerID: String, inMOC: NSManagedObjectContext = .main) -> Purchase? {
    return getPurchases(purchaseIDs: [id], customerID: customerID, inMOC: inMOC).first
  }
  
  public func updateFromData(_ data: JSON) {
    id = data.id.numberString
    customerID = data.userID.string
    total = data.total.doubleValue
    shipping = data.shipping.doubleValue
    discount = data.discount.doubleValue
    totalAmount = data.totalAmount.doubleValue
    email = data.email.string
    contact = data.contact.string
    address = data.address.string
    city = data.city.string
    status = data.status.string
    postal = data.postal.string
    chargeID = data.chargeID.string
    source = data.source.string
    datePaid = data.datePaid.toDate(format: .ymdhmsDateFormat)
    wcOrderID = data.wcOrderID.string
    wcOrderNumber = data.wcOrderNumber.string
    dateCreated = data.createdAt.toDate(format: .ymdhmsDateFormat)
    dateUpdated = data.updatedAt.toDate(format: .ymdhmsDateFormat)
    monthYear = data.createdAt.toDate(format: .ymdhmsDateFormat)?.startOfMonth()
    purchasedItemsRaw = data.purchasedItems.rawString()
  }
}

extension Purchase {
  public static func parsePurchasesFromData(_ data: JSON, customerID: String, inMOC: NSManagedObjectContext) {
    let purchaseArray = data.array ?? []
    let purchaseIDs = purchaseArray.compactMap({ $0.id.numberString })
    
    let deprecatedPurchases = CoreDataUtil.list(
      Purchase.self,
      predicate: .compoundAnd(predicates: [
        .isEqual(key: "isActive", value: true),
        .isEqual(key: "customerID", value: customerID),
        .notEqualIn(key: "id", values: purchaseIDs)]),
      inMOC: inMOC)
    deprecatedPurchases.forEach { (purchase) in
      purchase.isActive = false
    }
    
    let purchases = getPurchases(purchaseIDs: purchaseIDs, customerID: customerID, inMOC: inMOC)
    var productsRaw: [Any] = []
    purchaseArray.forEach { (data) in
      guard let purchase = parsePurchaseFromData(data, purchases: purchases, inMOC: inMOC) else { return }
      var variations: [Any] = []
      data.purchasedItems.array?.forEach { (purchasedItem) in
        if let variation = ProductVariation(data: purchasedItem.variation) {
          variations.append(variation.rawValue)
        }
        productsRaw.append(purchasedItem.product.rawValue)
      }
      if !variations.isEmpty {
        purchase.variationsRaw = JSON(variations).rawString()
      } else {
        purchase.variationsRaw = nil
      }
      purchase.isActive = true
    }
    let productsData = JSON(productsRaw)
    Product.parsePurchasedProductsFromData(productsData, inMOC: inMOC)
  }
  
  @discardableResult
  public static func parsePurchaseFromData(_ data: JSON, purchases: [Purchase], inMOC: NSManagedObjectContext) -> Purchase? {
    guard let purchaseID = data.id.numberString else { return nil }
    let currentPurchase = purchases.first(where: { $0.id == purchaseID })
    let purchase = CoreDataUtil.createEntity(Purchase.self, fromEntity: currentPurchase, inMOC: inMOC)
    purchase.updateFromData(data)
    return purchase
  }
}

extension Purchase {
  public struct Item {
    public var id: String?
    public var productID: String?
    public var variationID: String?
    public var name: String?
    public var quantity: Int
    public var price: Double?
    public var dateUpdated: Date?
    public var dateCreated: Date?
    public var product: Product?
    
    init?(data: JSON) {
      guard let purchaseID = data.purchaseID.string else { return nil }
      id = purchaseID
      productID = data.productID.numberString
      variationID = data.variationID.numberString
      name = data.name.string
      quantity = data.quantity.intValue
      price = data.price.string?.toNumber().doubleValue
      dateCreated = data.createdAt.toDate(format: .ymdhmsDateFormat)
      dateUpdated = data.updatedAt.toDate(format: .ymdhmsDateFormat)
      if let productID = productID {
        product = Product.getProduct(id: productID)
      }
    }
  }
  
  public var purchasedItems: [Item]? {
    return JSON(parseJSON: purchasedItemsRaw ?? "").array?.compactMap({ Item(data: $0) })
  }
  
  public var purchaseStatus: PurchaseStatus? {
    return PurchaseStatus(rawValue: status ?? "")
  }
  
  public var productVariations: [ProductVariation]? {
    return JSON(parseJSON: variationsRaw ?? "").array?.compactMap({ ProductVariation(data: $0) })
  }
}
