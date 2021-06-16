//
//  TreatmentPlan+CoreDataClass.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 11/5/19.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON
import R4pidKit

@objc(TreatmentPlan)
public class TreatmentPlan: NSManagedObject {
  public static func getTreatmentPlan(id: String, inMOC: NSManagedObjectContext = .main) -> TreatmentPlan? {
    return CoreDataUtil.get(TreatmentPlan.self, predicate: .isEqual(key: "id", value: id), inMOC: inMOC)
  }
  
  public func updateFromData(_ data: JSON) {
    templateID = data.treatmentPlanTemplateID.numberString
    customerID = data.userID.string
    treatmentPhase = data.treatmentPhase.string
    cycles = data.cycles.int32Value
    status = data.status.boolValue
    createdByID = data.createdBy.string
    editedByID = data.editedBy.string
    dateUpdated = data.updatedAt.toDate(format: .ymdhmsDateFormat)
    dateCreated = data.createdAt.toDate(format: .ymdhmsDateFormat)
    estimateDuration = data.estimateDuration.string
    if id == nil {
      id = data.id.numberString
      if let inMOC = managedObjectContext {
        TreatmentPlanItem.parseTreatmentPlanItems(data.services, treatmentPlan: self, inMOC: inMOC)
      }
    } else {
      if let inMOC = managedObjectContext {
        TreatmentPlanItem.parseTreatmentPlanItems(data.services, treatmentPlan: self, inMOC: inMOC)
      }
      id = data.id.numberString
    }
  }
  
  @discardableResult
  public static func parseTreatmentPlan(_ data: JSON, customer: Customer, inMOC: NSManagedObjectContext) -> TreatmentPlan? {
    guard !data.isEmpty else { return nil }
    let treatmentPlan = CoreDataUtil.createEntity(TreatmentPlan.self, fromEntity: customer.treatmentPlan, inMOC: inMOC)
    treatmentPlan.updateFromData(data)
    treatmentPlan.customer = customer
    return treatmentPlan
  }
}

extension TreatmentPlan {
  public var services: [TreatmentPlanItem]? {
    return items?.allObjects as? [TreatmentPlanItem]
  }
  public func generateAPIRequest() -> [APIServiceConstant.Key: Any] {
    var request: [APIServiceConstant.Key: Any] = [:]
    request[.treatmentPhase] = treatmentPhase ?? NSNull()
    request[.cycles] = cycles
    var services: [[APIServiceConstant.Key: Any]] = []
    self.services?.forEach { (data) in
      var service: [APIServiceConstant.Key: Any] = [:]
      service[.serviceID] = data.treatment?.id ?? NSNull()
      service[.addons] = data.addons?.compactMap({ $0.id }).joined(separator: ",").emptyToNil ?? NSNull()
      service[.interval] = data.interval ?? NSNull()
      service[.sequenceNumber] = data.sequenceNumber
      service[.status] = NSNumber(value: data.status).boolValue
      service[.isLocked] = data.isLocked
      services.append(service)
    }
    request[.services] = services
    return request
  }
}
