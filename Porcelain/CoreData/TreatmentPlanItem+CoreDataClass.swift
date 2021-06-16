//
//  TreatmentPlanItem+CoreDataClass.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 02/10/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON
import R4pidKit

@objc(TreatmentPlanItem)
public class TreatmentPlanItem: NSManagedObject {
  public static func getTreatmentPlanItems(ids: [String]? = nil, treatmentPlanID: String, inMOC: NSManagedObjectContext = .main) -> [TreatmentPlanItem] {
    var predicates: [CoreDataRecipe.Predicate] = [.isEqual(key: "plan.id", value: treatmentPlanID)]
    if let ids  = ids, !ids.isEmpty {
      if ids.count == 1, let id = ids.first {
        predicates.append(.isEqual(key: "id", value: id))
      } else  {
        predicates.append(.isEqualIn(key: "id", values: ids))
      }
    }
    return CoreDataUtil.list(TreatmentPlanItem.self, predicate: .compoundAnd(predicates: predicates), inMOC: inMOC)
  }
  
  public static func getTreatmentPlanItem(id: String, treatmentPlanID: String, inMOC: NSManagedObjectContext = .main) -> TreatmentPlanItem? {
    return getTreatmentPlanItems(ids: [id], treatmentPlanID: treatmentPlanID, inMOC: inMOC).first
  }
  
  public func updateFromData(_ data: JSON, id: String) {
    self.id = id
    serviceRaw = data.service.rawString()
    addonsRaw = data.addons.rawString()
    interval = data.interval.string
    status = data.status.int32Value
    sequenceNumber = data.sequenceNumber.int32Value
    isLocked = data.isLocked.boolValue
    sessionsLeft = data.sessionLeft.int32Value
    appointmentID = data.appointmentID.string
    booked = data.booked.boolValue
    planID = data.treatmentPlanID.numberString
  }
  
  public static func parseTreatmentPlanItems(_ data: JSON, treatmentPlan: TreatmentPlan, inMOC: NSManagedObjectContext) {
    guard let treatmentPlanID = treatmentPlan.id else { return }
    let itemArray = data.array ?? []
    let itemIDs = itemArray.enumerated().map({ "\(treatmentPlanID)-\($0.offset)" })
    let deprecatedItems = CoreDataUtil.list(
      TreatmentPlanItem.self,
      predicate: .compoundAnd(predicates: [
        .isEqual(key: "plan.id", value: treatmentPlanID),
        .notEqualIn(key: "id", values: itemIDs)]),
      inMOC: inMOC)
    CoreDataUtil.deleteEntities(deprecatedItems, inMOC: inMOC)
    let items = CoreDataUtil.list(
    TreatmentPlanItem.self,
      predicate: .compoundAnd(predicates: [
        .isEqual(key: "plan.id", value: treatmentPlanID),
        .isEqualIn(key: "id", values: itemIDs)]),
      inMOC: inMOC)
    itemArray.enumerated().forEach { (indx, data) in
      parseTreatmentPlanItem(data, id: "\(treatmentPlanID)-\(indx)", treatmentPlan: treatmentPlan, items: items, inMOC: inMOC)
    }
  }
  
  @discardableResult
  public static func parseTreatmentPlanItem(_ data: JSON, id: String, treatmentPlan: TreatmentPlan, items: [TreatmentPlanItem], inMOC: NSManagedObjectContext) -> TreatmentPlanItem {
    let currentItem = items.first(where: { $0.id == id })
    let item = CoreDataUtil.createEntity(TreatmentPlanItem.self, fromEntity: currentItem, inMOC: inMOC)
    item.updateFromData(data, id: id)
    item.plan = treatmentPlan
    return item
  }
}

extension TreatmentPlanItem {
  public struct Service {
    public var id: String?
    public var name: String?
    
    public init?(id: String?, name: String?) {
      guard let id = id else { return nil }
      self.id = id
      self.name = name
    }
    
    public init?(data: JSON) {
      guard let id = data.serviceID.string else { return nil }
      self.id = id
      name = data.name.string
    }
  }
  
  public var treatment: Service? {
    get {
      return Service(data: JSON(parseJSON: serviceRaw ?? ""))
    }
    set {
      serviceRaw = JSON(["service_id": newValue?.id, "name": newValue?.name]).rawString()
    }
  }
  
  public var addons: [Service]? {
    get {
      return JSON(parseJSON: addonsRaw ?? "").array?.compactMap({ Service(data: $0) })
    }
    set {
      if let array = newValue?.compactMap({ ["service_id": $0.id, "name": $0.name] }) {
        addonsRaw = JSON(array).rawString()
      } else {
        addonsRaw = nil
      }
    }
  }
}
