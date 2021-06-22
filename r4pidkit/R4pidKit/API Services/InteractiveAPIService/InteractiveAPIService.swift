//
//  InteractiveAPIService.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 18/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation

public struct InteractiveAPIRequest: APIRequestProtocol {
  public var scheme: String = APIServiceConstant.isProduction ? "https": "http"
  public var host: String = APIServiceConstant.isProduction ? "api.porcelainskin.com": "13.228.83.66"
  public var port: Int? = APIServiceConstant.isProduction ? nil: 82
  public var base: String? = "/api/v2/interactive"
  public var accessToken: String? = APIServiceConstant.accessToken
  public var overrideHeaders: [String : String]?
  
  public func authHeaders() -> [String : String] {
    if let overrideHeaders = overrideHeaders {
      return overrideHeaders
    } else {
      var authHeaders: [String: String] = [:]
      authHeaders["Content-type"] = "application/json"
      if let accessToken = accessToken {
        authHeaders["Authorization"] = "Employee \(accessToken)"
      }
      return authHeaders
    }
  }
}

private enum APIPath: APIPathProtocol {
  case rooms
  case employees
  case signIn
  case signInPhoneNumber
  case dashboard
  case referralSources
  case countries
  case states(countryID: String)
  case searchUsers
  case products
  case productHTML(productID: String)
  case socketRooms
  case updateFCMToken(therapistID: String)
  case userAppointments(customerID: String)
  
  var rawValue: String {
    switch self {
    case .rooms:
      return "/rooms"
    case .employees:
      return "/employees"
    case .signIn:
      return "/signin"
    case .signInPhoneNumber:
      return "/phone_number_signin"
    case .dashboard:
      return "/dashboard"
    case .referralSources:
      return "/referral_sources"
    case .countries:
      return "/countries"
    case .states(let countryID):
      return "/country/\(countryID)/states"
    case .searchUsers:
      return "/user/search"
    case .products:
      return "/products"
    case .productHTML(let productID):
      return "/product/\(productID)/html_description"
    case .socketRooms:
      if APIServiceConstant.isProduction {
        return "/socket_rooms/live"
      } else {
        return "/socket_rooms/staging"
      }
    case .updateFCMToken(let therapistID):
      return "/firebase/token/\(therapistID)"
    case .userAppointments(let customerID):
        return "/user/\(customerID)/appointments"
    }
  }
}

public struct InteractiveAPIService: APIServiceProtocol {
  public var request: APIRequestProtocol = InteractiveAPIRequest()
  public var path: APIPathProtocol?
  public var method: HTTPMethod = .get
  public var requestBody: Any?
  public var queryParameters: [URLQueryItem]?
  public var accessToken: String?
  public var debugName: String?
}

extension InteractiveAPIService {
  public static func getRooms() -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.rooms
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getEmployees() -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.employees
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func signInEmployee(id: String, password: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.signIn
    service.method = .post
    service.requestBody = InteractiveAPIService.createRequestBody([
      .employeeID: id,
      .password: password])
    service.debugName = #function
    return service
  }
  
  public static func signInPhoneNumberEmployee(phone: String, password: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.signInPhoneNumber
    service.method = .post
    service.requestBody = InteractiveAPIService.createRequestBody([
      .phone: phone,
      .password: password])
    service.debugName = #function
    return service
  }
  
  public static func getDashboard(centerID: String?) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.dashboard
    service.queryParameters = [centerID].compactMap({ $0 }).map({ URLQueryItem(key: .centerID, value: $0) })
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getReferralSources() -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.referralSources
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getCountries() -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.countries
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getStates(countryID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.states(countryID: countryID)
    service.request.base = "/api/v2"
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func searchUsers(query: String?) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.searchUsers
    service.queryParameters = [
      URLQueryItem(key: .query, value: query)]
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getProducts() -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.products
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getProductHTML(productID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
     service.path = APIPath.productHTML(productID: productID)
     service.request.base = "/api/v2"
     service.method = .get
     service.debugName = #function
     return service
  }
  
  public static func getSocketRooms() -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.socketRooms
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func updateFCMToken(therapistID: String, fcmToken: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.updateFCMToken(therapistID: therapistID)
    service.method = .post
    service.debugName = #function
    service.requestBody = InteractiveAPIService.createRequestBody([
      .fcmToken: fcmToken,
      .platform: "ios",
      .userType: "employee"])
    return service
  }
  
  public static func getUserAppointments(customerID: String, fromDate: Date, toDate: Date, status: String?) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.userAppointments(customerID: customerID)
    service.request.base = "/api/v2"
    service.queryParameters = [
      URLQueryItem(key: .from, value: fromDate.toString(WithFormat: .ymdDateFormat)),
      URLQueryItem(key: .to, value: toDate.toString(WithFormat: .ymdDateFormat))]
    if let status = status {
      service.queryParameters?.append(URLQueryItem(key: .status, value: status))
    }
    service.method = .get
    service.debugName = #function
    return service
  }
}

extension InteractiveAPIService {
  public struct Employee {
  }
  public struct Customer {
  }
  public struct Center {
  }
  public struct Consultation {
  }
  public struct Thread {
  }
}
