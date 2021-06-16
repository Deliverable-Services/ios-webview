//
//  ShippingAddress+CoreDataClass.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 19/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON
import R4pidKit

@objc(ShippingAddress)
public class ShippingAddress: NSManagedObject {
  private static var seconds = 0
  public static func getAddresses(addressIDs: [String]? = nil, customerID: String, inMOC: NSManagedObjectContext = .main) -> [ShippingAddress] {
    var predicates: [CoreDataRecipe.Predicate] = [.isEqual(key: "customer.id", value: customerID)]
    if let addressIDs = addressIDs, !addressIDs.isEmpty {
      if addressIDs.count == 1, let addressID = addressIDs.first {
        predicates.append(.isEqual(key: "id", value: addressID))
      } else  {
        predicates.append(.isEqualIn(key: "id", values: addressIDs))
      }
    }
    return CoreDataUtil.list(ShippingAddress.self, predicate: .compoundAnd(predicates: predicates), inMOC: inMOC)
  }
  
  public static func getAddress(id: String, customerID: String, inMOC: NSManagedObjectContext = .main) -> ShippingAddress? {
    return getAddresses(addressIDs: [id], customerID: customerID, inMOC: inMOC).first
  }
  
  public func updateFromData(_ data: JSON) {
    id = data.id.numberString
    name = data.name.string
    address = data.address.string
    country = data.country.string
    state = data.state.string
    postalCode = data.postalCode.numberString
    type = data.type.numberString
    email = data.email.string
    phone = data.phone.string
    primary = data.primary.boolValue
    if dateCreated == nil {
      dateCreated = Date().dateByAdding(seconds: ShippingAddress.seconds)
      ShippingAddress.seconds += 1
    }
  }
}

extension ShippingAddress {
  public static func parseAddresses(_ data: JSON, customer: Customer, inMOC: NSManagedObjectContext) {
    let addressArray = data.array ?? []
    let addressIDs = addressArray.compactMap({ $0.id.numberString })
    
    let deprecatedAddresses = CoreDataUtil.list(
      ShippingAddress.self,
      predicate: .compoundAnd(predicates: [
        .isEqual(key: "customer.id", value: customer.id!),
        .notEqualIn(key: "id", values: addressIDs)]),
      inMOC: inMOC)
    CoreDataUtil.deleteEntities(deprecatedAddresses, inMOC: inMOC)
    
    let addresses = getAddresses(addressIDs: addressIDs, customerID: customer.id!, inMOC: inMOC)
    addressArray.forEach { (data) in
      parseAddressFromData(data, customer: customer, addresses: addresses, inMOC: inMOC)
    }
    ShippingAddress.seconds = 0//reset
  }
  
  @discardableResult
  public static func parseAddressFromData(_ data: JSON, customer: Customer, addresses: [ShippingAddress], inMOC: NSManagedObjectContext) -> ShippingAddress? {
    guard let addressID = data.id.numberString else { return nil }
    let currentAddress = addresses.first(where: { $0.id == addressID })
    let address = CoreDataUtil.createEntity(ShippingAddress.self, fromEntity: currentAddress, inMOC: inMOC)
    address.updateFromData(data)
    address.customer = customer
    return address
  }
}

extension ShippingAddress {
  public var countryCode: String? {
    return SelectCountryQuery.name(value: country).countryData?.alpha2Code
  }
}
