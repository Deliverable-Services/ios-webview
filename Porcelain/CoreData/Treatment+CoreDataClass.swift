//
//  Treatment+CoreDataClass.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 11/6/19.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData
import R4pidKit
import SwiftyJSON

@objc(Treatment)
public class Treatment: NSManagedObject {
  /// get services not from branch or appointemnt
  public static func getTreatments(serviceIDs: [String]? = nil, inMOC: NSManagedObjectContext = .main) -> [Treatment] {
    var predicates: [CoreDataRecipe.Predicate] = []

    if let serviceIDs = serviceIDs, !serviceIDs.isEmpty {
      if serviceIDs.count == 1, let serviceID = serviceIDs.first {
        predicates.append(.isEqual(key: "serviceID", value: serviceID))
      } else  {
        predicates.append(.isEqualIn(key: "serviceID", values: serviceIDs))
      }
    }
    return CoreDataUtil.list(Treatment.self, predicate: .compoundAnd(predicates: predicates), sorts: [.custom(key: "name", isAscending: true)], inMOC: inMOC)
  }
  
  /// get service not from branch or appointment
  public static func getTreatment(id: String, inMOC: NSManagedObjectContext = .main) -> Treatment? {
    return getTreatments(serviceIDs: [id], inMOC: inMOC).first
  }
  
  /// generic update from json data
  public func updateFromData(_ data: JSON) {
    serviceID = data.serviceID.string
    name = data.name.string
    displayName = data.displayName.string
    price = data.price.string
    duration = data.duration.string
    categoryID = data.categoryID.string
    categoryName = data.category.name.string
    isVisible = data.visible.boolValue
    image = data.imageCustomerapp.string
    desc = data.description.string
    award = data.award.array?.compactMap({ $0.string })
    afterCare = data.afterCare.array?.compactMap({ $0.string })
    benefits = data.benefits.array?.compactMap({ $0.string })
    procedure = data.procedure.array?.compactMap({ $0.string })
    notSuitableFor = data.notSuitableFor.array?.compactMap({ $0.string })
    suitableFor = data.suitableFor.array?.compactMap({ $0.string })
    permalink = data.permalink.string
  }


  public static func parseTreatmentsFromData(_ data: JSON, inMOC: NSManagedObjectContext) {
    var treatmentCenters: [String: [String]] = [:] // [serviceID: [centerID]]
    var treatmentArray: [JSON] = []
    var centerTreatments: [String: [Any]] = [:]
    data.array?.forEach { (data) in
      guard let serviceID = data.serviceID.string else { return }
      if let centerID = data.centerID.string {
        //parse treatment
        if var centerIDs = treatmentCenters[serviceID] {
          centerIDs.append(centerID)
          treatmentCenters[serviceID] = centerIDs
        } else {
          treatmentCenters[serviceID] = [centerID]
        }
        //parse service treatment
        if var services = centerTreatments[centerID] {
          services.append(data.rawValue)
          centerTreatments[centerID] = services
        } else {
          centerTreatments[centerID] = [data.rawValue]
        }
      }
      guard !treatmentArray.contains(where: { $0.serviceID.string == serviceID }) else { return }
      treatmentArray.append(data)
    }
    //parse treatment
    let serviceIDs = treatmentArray.compactMap({ $0.serviceID.string })

    let deprecatedServices = CoreDataUtil.list(Treatment.self, predicate: .notEqualIn(key: "serviceID", values: serviceIDs), inMOC: inMOC)
    CoreDataUtil.deleteEntities(deprecatedServices, inMOC: inMOC)
    
    let treatments = CoreDataUtil.list(Treatment.self, predicate: .isEqualIn(key: "serviceID", values: serviceIDs), inMOC: inMOC)
    treatmentArray.forEach { (data) in
      guard let serviceID = data.serviceID.string else { return }
      guard let treatment = parseTreatmentFromData(data, treatments: treatments, inMOC: inMOC) else { return }
      treatment.centerIDs = treatmentCenters[serviceID]
    }
    //parse service treatment
    centerTreatments.keys.forEach { (centerID) in
      guard let services = centerTreatments[centerID] else { return }
      Service.parseCenterServicesFromData(JSON(services), centerID: centerID, type: .treatment, inMOC: inMOC)
    }
  }
  
  @discardableResult
  public static func parseTreatmentFromData(_ data: JSON, treatments: [Treatment], inMOC: NSManagedObjectContext) -> Treatment? {
    guard let serviceID = data.serviceID.string else { return  nil }
    let currentTreatment = treatments.first(where: { $0.serviceID == serviceID })
    let treatment = CoreDataUtil.createEntity(Treatment.self, fromEntity: currentTreatment, inMOC: inMOC)
    treatment.updateFromData(data)
    return treatment
  }
}
