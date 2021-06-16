//
//  Service+CoreDataClass.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 09/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON
import R4pidKit

public enum ServiceType: String {
  case treatment
  case addon
}

@objc(Service)
public class Service: NSManagedObject {
  /// get services not from branch or appointemnt
  public static func getServices(serviceIDs: [String]? = nil, type: ServiceType?, centerID: String?, inMOC: NSManagedObjectContext = .main) -> [Service] {
    var predicates: [CoreDataRecipe.Predicate] = []
    if let centerID = centerID {
      predicates.append(.isEqual(key: "centerID", value: centerID))
    }
    if let type = type {
      predicates.append(.isEqual(key: "type", value: type.rawValue))
    }
    if let serviceIDs = serviceIDs, !serviceIDs.isEmpty {
      if serviceIDs.count == 1, let serviceID = serviceIDs.first {
        predicates.append(.isEqual(key: "id", value: serviceID))
      } else  {
        predicates.append(.isEqualIn(key: "id", values: serviceIDs))
      }
    }
    return CoreDataUtil.list(Service.self, predicate: .compoundAnd(predicates: predicates), inMOC: inMOC)
  }
  
  /// get service not from branch or appointment
  public static func getService(id: String, type: ServiceType?, centerID: String, inMOC: NSManagedObjectContext = .main) -> Service? {
    return getServices(serviceIDs: [id], type: type, centerID: centerID, inMOC: inMOC).first
  }
  
  /// generic update from json data
  public func updateFromData(_ data: JSON, type: ServiceType) {
    id = data.serviceID.string
    centerID = data.centerID.string
    name = data.name.string
    displayName = data.displayName.string
    price = data.price.string
    duration = data.duration.string
    categoryID = data.categoryID.string
    categoryName = data.category.name.string ?? self.categoryName
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
    self.type = type.rawValue
  }
  
  @discardableResult
  public static func parseServiceFromData(_ data: JSON, type: ServiceType, services: [Service], inMOC: NSManagedObjectContext) -> Service? {
    guard let serviceID = data.serviceID.string, let centerID = data.centerID.string else { return  nil }
    let currentService = services.first(where: { $0.id == serviceID && $0.centerID == centerID })
    let service = CoreDataUtil.createEntity(Service.self, fromEntity: currentService, inMOC: inMOC)
    service.updateFromData(data, type: type)
    return service
  }
}

// MARK: - Center services parsing
extension Service {
  public static func parseCenterServicesFromData(_ data: JSON, centerID: String, type: ServiceType, inMOC: NSManagedObjectContext) {
    let serviceArray = data.array ?? []
    let serviceIDs = serviceArray.compactMap({ $0.serviceID.string })
    
    let deprecatedServices = CoreDataUtil.list(
      Service.self,
      predicate: .compoundAnd(predicates: [
        .isEqual(key: "centerID", value: centerID),
        .isEqual(key: "type", value: type.rawValue),
        .notEqualIn(key: "id", values: serviceIDs)]),
      inMOC: inMOC)
    CoreDataUtil.deleteEntities(deprecatedServices, inMOC: inMOC)
    
    let services = CoreDataUtil.list(
      Service.self,
      predicate: .compoundAnd(predicates: [
        .isEqual(key: "centerID", value: centerID),
        .isEqual(key: "type", value: type.rawValue),
        .isEqualIn(key: "id", values: serviceIDs)]),
      inMOC: inMOC)
    serviceArray.forEach { (data) in
      parseServiceFromData(data, type: type, services: services, inMOC: inMOC)
    }
  }
}
