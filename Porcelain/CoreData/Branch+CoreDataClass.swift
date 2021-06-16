//
//  Branch+CoreDataClass.swift
//  Porcelain
//
//  Created by Jean on 7/4/18.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON
import R4pidKit

public typealias Center = Branch

@objc(Branch)
public class Branch: NSManagedObject {
  public static func getCenters(centerIDs: [String]? = nil, inMOC: NSManagedObjectContext = .main) -> [Branch] {
    var predicates: [CoreDataRecipe.Predicate] = []
    
    if let centerIDs = centerIDs, !centerIDs.isEmpty {
      if centerIDs.count == 1, let centerID = centerIDs.first {
        predicates.append(.isEqual(key: "id", value: centerID))
      } else  {
        predicates.append(.isEqualIn(key: "id", values: centerIDs))
      }
    }
    return CoreDataUtil.list(Branch.self, predicate: .compoundAnd(predicates: predicates), inMOC: inMOC)
  }
  
  public static func getCenter(id: String, inMOC: NSManagedObjectContext = .main) -> Branch? {
    return getCenters(centerIDs: [id], inMOC: inMOC).first
  }
  
  public func updateFromData(_ data: JSON) {
    self.id = data.centerID.string ?? data.id.number?.stringValue
    self.name = data.name.string ?? self.name
    self.address1 = data.address1.string ?? self.address1
    self.address2 = data.address2.string ?? self.address2
    self.city = data.city.string ?? self.city
    self.state = data.state.string ?? self.state
    self.code = data.code.string ?? self.code
    self.organizationName = data.organizationName.string ?? self.organizationName
    self.email = data.email.string ?? self.email
    self.whatsapp = data.whatsapp.string ?? self.whatsapp
    self.canBook = data.canBook.bool ?? self.canBook
    self.centerCode = data.centerCode.string ?? self.centerCode
    self.latitude = data.lat.number?.doubleValue ?? self.latitude
    self.longitude = data.lon.number?.doubleValue ?? self.longitude
    self.window = data.window.string ?? self.window
    self.operatingHoursRaw = data.operatingHours.rawString() ?? self.operatingHoursRaw
    self.contactsRaw = data.contacts.rawString() ?? self.contactsRaw
  }
}

extension Center {
  public static func parseCentersFromData(_ data: JSON, inMOC: NSManagedObjectContext) {
    guard let centerArray = data.array else { return }
    let centerIDs = centerArray.compactMap({ $0.centerID.string })
    
    let deprecatedCenters = CoreDataUtil.list(
      Branch.self,
      predicate: .compoundAnd(predicates: [
        .notEqualIn(key: "id", values: centerIDs)]),
      inMOC: inMOC)
    CoreDataUtil.deleteEntities(deprecatedCenters, inMOC: inMOC)
    
    let centers = getCenters(centerIDs: centerIDs, inMOC: inMOC)
    centerArray.forEach { (data) in
      parseCenterFromData(data, centers: centers, inMOC: inMOC)
    }
  }
  
  @discardableResult
  public static func parseCenterFromData(_ data: JSON, centers: [Center], inMOC: NSManagedObjectContext) -> Center? {
    guard let centerID = data.centerID.string else { return nil }
    let currentCenter = centers.first(where: { $0.id == centerID })
    let center = CoreDataUtil.createEntity(Branch.self, fromEntity: currentCenter, inMOC: inMOC)
    center.updateFromData(data)
    return center
  }
}

extension Center {
  public struct OperatingHour {
    public var daysOpen: String?
    public var openAt: String?
    public var closeAt: String?
    
    init(data: JSON) {
      daysOpen = data.daysOpen.string
      openAt = data.openAt.string
      closeAt = data.closeAt.string
    }
  }
  
  public var operatingHours: [OperatingHour]? {
    return JSON(parseJSON: operatingHoursRaw ?? "").array?.compactMap({ OperatingHour(data: $0) })
  }
}

extension Center {
  public struct Contact {
    public var countryCode: String?
    public var number: String?
    public var displayNumber: String?
    
    init?(data: JSON) {
      guard let number = data.number.string else { return nil }
      countryCode = data.countryCode.string
      self.number = number
      displayNumber = data.displayNumber.string
    }
  }
  
  public var contact: Contact? {
    return JSON(parseJSON: contactsRaw ?? "").array?.compactMap({ Contact(data: $0) }).first
  }
}
