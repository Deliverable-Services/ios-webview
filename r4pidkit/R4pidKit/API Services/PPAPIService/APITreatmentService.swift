//
//  APITreatmentService.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 31/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation

private enum APITreatmentPath: APIPathProtocol {
  case treatment
  case treatments
  case treatmentDetails(treatmentID: String)
  
  var rawValue: String {
    switch self {
    case .treatment:
      return "/treatment"
    case .treatments:
      return "/treatments"
    case .treatmentDetails(let treatmentID):
      return "/treatment/\(treatmentID)"
    }
  }
}

public struct APITreatmentService: APIServiceProtocol {
  public var request: APIRequestProtocol = PPAPIRequest()
  public var path: APIPathProtocol?
  public var method: HTTPMethod = .get
  public var requestBody: Any?
  public var queryParameters: [URLQueryItem]?
  public var accessToken: String?
  public var debugName: String?
}

extension APITreatmentService {
  public static func getTreatments() -> APITreatmentService {
    var service = APITreatmentService()
    service.path = APITreatmentPath.treatments
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getTreatmentDetails(treatmentID: String) -> APITreatmentService {
    var service = APITreatmentService()
    service.path = APITreatmentPath.treatmentDetails(treatmentID: treatmentID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func updateTreatment() -> APITreatmentService {//TODO
    var service = APITreatmentService()
    service.path = APITreatmentPath.treatment
    service.method = .put
    service.debugName = #function
    return service
  }
  
  public static func deleteTreatment() -> APITreatmentService {//TODO
    var service = APITreatmentService()
    service.path = APITreatmentPath.treatment
    service.method = .delete
    service.debugName = #function
    return service
  }
}
