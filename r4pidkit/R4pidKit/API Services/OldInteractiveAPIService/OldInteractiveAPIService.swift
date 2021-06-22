//
//  OldInteractiveAPIService.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 15/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation

public struct OldInteractiveAPIRequest: APIRequestProtocol {
  public var scheme: String = "http"
  public var host: String = APIServiceConstant.isProduction ? "13.251.122.54": "3.1.102.82"
  public var port: Int? = APIServiceConstant.isProduction ? nil: 82
  public var base: String? = "/api/interactive"
  public var accessToken: String? = "D86DC6E60B0632E30F2A78ABE922C238E913DD5C74F76DF6DC935F1EC73A5DF6"
  public var overrideHeaders: [String : String]?
  
  public func authHeaders() -> [String : String] {
    if let overrideHeaders = overrideHeaders {
      return overrideHeaders
    } else {
      var authHeaders: [String: String] = [:]
      authHeaders["Content-type"] = "application/json"
      if let accessToken = accessToken {
        authHeaders["Authorization"] = accessToken
      }
      return authHeaders
    }
  }
}

private enum APIPath: APIPathProtocol {
  case rooms
  case forgotPassword
  case signIn
  case therapist
  case employee
  case branches
  case treatments
  case addOns
  case products
  case about
  
  var rawValue: String {
    switch self {
    case .rooms:
      return "/rooms"
    case .forgotPassword:
      return "/therapist/forgotPassword"
    case .signIn:
      return "/employee/signIn"
    case .therapist:
      return "/therapist"
    case .employee:
      return "/employee"
    case .branches:
      return "/porcelain/branches"
    case .treatments:
      return "/porcelain/treatments"
    case .addOns:
      return "/porcelain/addOns"
    case .products:
      return "/porcelain/products"
    case .about:
      return "/porcelain/about"
    }
  }
}

public struct OldInteractiveAPIService: APIServiceProtocol, APIServiceJSONCompletionProtocol {
  public var request: APIRequestProtocol = OldInteractiveAPIRequest()
  public var path: APIPathProtocol?
  public var method: HTTPMethod = .get
  public var requestBody: Any?
  public var queryParameters: [URLQueryItem]?
  public var debugName: String?
  public var jsonData: APIRequestJSONDataProtocol?
  public var bundle: Bundle?
}

extension OldInteractiveAPIService {
  public static func getRooms() -> OldInteractiveAPIService {
    var service = OldInteractiveAPIService()
    service.request.host = APIServiceConstant.isProduction ? "13.251.155.148": "13.228.83.66"
    service.request.base = "/api"
    service.request.port = 7000
    service.method = .get
    service.path = APIPath.rooms
    service.debugName = #function
    return service
  }
  
  public static func forgotPassword(email: String) -> OldInteractiveAPIService {
    var service = OldInteractiveAPIService()
    service.method = .post
    service.path = APIPath.forgotPassword
    var requestBody: [String: Any] = [:]
    requestBody["email"] = email
    service.requestBody = requestBody
    service.debugName = #function
    return service
  }
  
  public static func signIn(username: String, password: String, deviceID: String) -> OldInteractiveAPIService {
    var service = OldInteractiveAPIService()
    service.method = .post
    service.path = APIPath.signIn
    var requestBody: [String: Any] = [:]
    requestBody["username"] = username
    requestBody["password"] = password
    requestBody["deviceID"] = deviceID
    service.requestBody = requestBody
    service.debugName = #function
    return service
  }
  
  public static func getTherapists() -> OldInteractiveAPIService {
    var service = OldInteractiveAPIService()
    service.method = .get
    service.path = APIPath.therapist
    service.debugName = #function
    return service
  }
  
  public static func getEmployees() -> OldInteractiveAPIService {
    var service = OldInteractiveAPIService()
    service.method = .get
    service.path = APIPath.employee
    service.debugName = #function
    return service
  }
  
  public static func getBranches() -> OldInteractiveAPIService {
    var service = OldInteractiveAPIService()
    service.method = .get
    service.path = APIPath.branches
    service.debugName = #function
    return service
  }
  
  public static func getTreatments() -> OldInteractiveAPIService {
    var service = OldInteractiveAPIService()
    service.method = .get
    service.path = APIPath.treatments
    service.debugName = #function
    return service
  }
  
  public static func getAddOns() -> OldInteractiveAPIService {
    var service = OldInteractiveAPIService()
    service.method = .get
    service.path = APIPath.addOns
    service.debugName = #function
    return service
  }
  
  public static func getProducts() -> OldInteractiveAPIService {
    var service = OldInteractiveAPIService()
    service.method = .get
    service.path = APIPath.products
    service.debugName = #function
    return service
  }
  
  public static func getAbout() -> OldInteractiveAPIService {
    var service = OldInteractiveAPIService()
    service.method = .get
    service.path = APIPath.about
    service.debugName = #function
    return service
  }
}

extension OldInteractiveAPIService {
  public struct Customer {
  }
}
