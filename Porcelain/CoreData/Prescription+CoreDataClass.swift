//
//  Prescription+CoreDataClass.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 26/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON
import R4pidKit

@objc(Prescription)
public class Prescription: NSManagedObject {
  public static func getPrescriptions(prescriptionIDs: [String]? = nil, customerID: String, inMOC: NSManagedObjectContext = .main) -> [Prescription] {
    var predicates: [CoreDataRecipe.Predicate] = [.isEqual(key: "customer.id", value: customerID)]
    if let prescriptionIDs = prescriptionIDs, !prescriptionIDs.isEmpty {
      if prescriptionIDs.count == 1, let prescriptionID = prescriptionIDs.first {
        predicates.append(.isEqual(key: "id", value: prescriptionID))
      } else  {
        predicates.append(.isEqualIn(key: "id", values: prescriptionIDs))
      }
    }
    return CoreDataUtil.list(Prescription.self, predicate: .compoundAnd(predicates: predicates), inMOC: inMOC)
  }
  
  public static func getPrescription(id: String, customerID: String, inMOC: NSManagedObjectContext = .main) -> Prescription? {
    return getPrescriptions(prescriptionIDs: [id], customerID: customerID, inMOC: inMOC).first
  }
  
  public func updateFromData(_ data: JSON) {
    self.id = data.id.numberString
    self.afterNumberOfDays = data.afterNumberOfDays.int32 ?? self.afterNumberOfDays
    self.frequencyRaw = data.frequency.rawString() ?? self.frequencyRaw
    self.sequenceNumber = data.sequenceNumber.int32 ?? self.sequenceNumber
    self.productRaw = data.product.rawString() ?? self.productRaw
    self.therapistRaw = data.therapist.rawString() ?? self.therapistRaw
    self.numberOfPumps = data.numberOfPumps.int32 ?? self.numberOfPumps
  }
}

extension Prescription {
  public static func parsePrescriptionsFromData(_ data: JSON, customer: Customer, inMOC: NSManagedObjectContext) {
    let prescriptionArray = data.array ?? []
    let prescriptionIDs = prescriptionArray.compactMap({ $0.id.numberString })
    
    let deprecatedPrescriptions = CoreDataUtil.list(
      Prescription.self,
      predicate: .compoundAnd(predicates: [
        .isEqual(key: "customer.id", value: customer.id!),
        .notEqualIn(key: "id", values: prescriptionIDs)]),
      inMOC: inMOC)
    CoreDataUtil.deleteEntities(deprecatedPrescriptions, inMOC: inMOC)
    
    let prescriptions = getPrescriptions(prescriptionIDs: prescriptionIDs, customerID: customer.id!, inMOC: inMOC)
    prescriptionArray.forEach { (data) in
      parsePrescription(data, customer: customer, prescriptions: prescriptions, inMOC: inMOC)
    }
  }
  
  @discardableResult
  public static func parsePrescription(_ data: JSON, customer: Customer, prescriptions: [Prescription], inMOC: NSManagedObjectContext) -> Prescription? {
    guard let prescriptionID = data.id.numberString else { return nil }
    let currentPrescription = prescriptions.first(where: { $0.id == prescriptionID })
    let prescription = CoreDataUtil.createEntity(Prescription.self, fromEntity: currentPrescription, inMOC: inMOC)
    prescription.updateFromData(data)
    prescription.customer = customer
    return prescription
  }
}

extension Prescription {
  public struct Product {
    public var id: String?
    public var name: String?
    public var size: String?
    public var price: Double
    public var purchasedAt: Date?
    public var avgRating: Double
    public var totalReviews: Int
    public var images: [String]?
    
    public init?(data: JSON) {
      guard let productID = data.productID.numberString else { return nil }
      id = productID
      name = data.name.string
      size = data.size.string
      price = data.price.doubleValue
      purchasedAt = data.purchaseAt.toDate(format: .ymdhmsDateFormat)
      avgRating = data.avgRating.doubleValue
      totalReviews = data.totalReviews.intValue
      images = data.images.array?.compactMap({ $0.src.string })
    }
  }
  
  public var product: Product? {
    return Product(data: JSON(parseJSON: productRaw ?? ""))
  }
  
  public struct Therapist {
    public var id: String?
    public var name: String?
    public var image: String?
    
    public init?(data: JSON) {
      guard let therapistID = data.employeeID.string else { return nil }
      id = therapistID
      name = data.name.string
      image = data.image.string
    }
  }
  
  public var therapist: Therapist? {
    return Therapist(data: JSON(parseJSON: therapistRaw ?? ""))
  }
  
  public var frequency: [String]? {
    return JSON(parseJSON: frequencyRaw ?? "").array?.compactMap({ $0.string })
  }
}
