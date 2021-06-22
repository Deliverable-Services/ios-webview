//
//  InteractiveAPIService+Center.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 18/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation

private enum APIPath: APIPathProtocol {
  case centerTherapists(centerID: String)
  case centerTreatments(centerID: String)
  case centerTreatmentHTML(centerID: String, serviceID: String)
  case centerAddons(centerID: String)
  case centers
  
  var rawValue: String {
    switch self {
    case .centerTherapists(let centerID):
      return "/center/\(centerID)/therapists"
    case .centerTreatments(let centerID):
      return "/center/\(centerID)/services"
    case .centerTreatmentHTML(let centerID, let serviceID):
      return "/center/\(centerID)/service/\(serviceID)/html_description"
    case .centerAddons(let centerID):
      return "/center/\(centerID)/addons"
    case .centers:
      return "/centers"
    }
  }
}

extension InteractiveAPIService.Center {
  public static func getCenterTherapists(centerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.centerTherapists(centerID: centerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getCenterTreatments(centerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.centerTreatments(centerID: centerID)
    service.request.base = "/api/v2"
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getCenterTreatmentHTML(centerID: String, serviceID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.centerTreatmentHTML(centerID: centerID, serviceID: serviceID)
    service.request.base = "/api/v2"
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getCenterAddons(centerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.centerAddons(centerID: centerID)
    service.request.base = "/api/v2"
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getCenters() -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.centers
    service.method = .get
    service.debugName = #function
    return service
  }
}
