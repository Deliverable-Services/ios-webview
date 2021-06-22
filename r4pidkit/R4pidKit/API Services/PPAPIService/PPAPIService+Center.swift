//
//  PPAPIService+Center.swift
//  R4pidKit
//
//  Created by Justine Rangel on 05/08/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation

private enum APIPath: APIPathProtocol {
  case centers
  case treatments(centerID: String)
  case treatmentHTML(centerID: String, serviceID: String)
  case addons(centerID: String)
  case services
  case therapists
  case availableSlots(centerID: String)
  case availableSlotDates(centerID: String)
  
  var rawValue: String {
    switch self {
    case .centers:
      return "/centers"
    case .treatments(let centerID):
      return "/center/\(centerID)/services"
    case .treatmentHTML(let centerID, let serviceID):
      return "/center/\(centerID)/service/\(serviceID)/html_description"
    case .addons(let centerID):
      return "/center/\(centerID)/addons"
    case .services:
      return "/center/services"
    case .therapists:
      return "/therapists"
    case .availableSlots(let centerID):
      return "/center/\(centerID)/slots"
    case .availableSlotDates(let centerID):
      return "/center/\(centerID)/slotdates"
    }
  }
}


extension PPAPIService.Center {
  public static func getCenters() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.centers
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getTreatments(centerID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.treatments(centerID: centerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getTreatmentHTML(centerID: String, serviceID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.treatmentHTML(centerID: centerID, serviceID: serviceID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getAddons(centerID: String, serviceID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.addons(centerID: centerID)
    service.method = .get
    service.queryParameters = [
      URLQueryItem(key: .currentServiceID, value: serviceID)]
    service.debugName = #function
    return service
  }
  
  public static func getAllServices() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.services
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getTherapists(centerID: String, serviceID: String, addonIDs: [String]? = nil) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.therapists
    service.method = .get
    service.queryParameters = [
      URLQueryItem(key: .centerID, value: centerID),
      URLQueryItem(key: .serviceID, value: serviceID)]
    if let addonIDs = addonIDs, !addonIDs.isEmpty {
      service.queryParameters?.append(URLQueryItem(key: .addonIDs, value: addonIDs.joined(separator: ",")))
    }
    service.debugName = #function
    return service
  }
  
  public static func getAvailableSlots(centerID: String, treatmentID: String, addOnIDs: [String]?, therapistIDs: [String]?, date: Date) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.availableSlots(centerID: centerID)
    service.method = .get
    service.queryParameters = [
      URLQueryItem(key: .serviceID, value: treatmentID),
      URLQueryItem(key: .startDate, value: date.toString(WithFormat: "yyyy-MM-dd"))]
    if let addOnIDs = addOnIDs?.joined(separator: ",") {
      service.queryParameters?.append(URLQueryItem(key: .addonIDs, value: addOnIDs))
    }
    if let therapistIDs = therapistIDs?.joined(separator: ",") {
      service.queryParameters?.append(URLQueryItem(key: .therapistIDs, value: therapistIDs))
    }
    service.debugName = #function
    return service
  }
  
  public static func getAvailableSlotDates(centerID: String, treatmentID: String, addOnIDs: [String]?, therapistIDs: [String]?, startDate: Date, endDate: Date) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.availableSlotDates(centerID: centerID)
    service.method = .get
    service.queryParameters = [
      URLQueryItem(key: .serviceID, value: treatmentID),
      URLQueryItem(key: .startDate, value: startDate.toString(WithFormat: .ymdDateFormat)),
      URLQueryItem(key: .endDate, value: endDate.toString(WithFormat: .ymdDateFormat))]
    if let addOnIDs = addOnIDs?.joined(separator: ",") {
      service.queryParameters?.append(URLQueryItem(key: .addonIDs, value: addOnIDs))
    }
    if let therapistIDs = therapistIDs?.joined(separator: ",") {
      service.queryParameters?.append(URLQueryItem(key: .therapistIDs, value: therapistIDs))
    }
    service.debugName = #function
    return service
  }
}
