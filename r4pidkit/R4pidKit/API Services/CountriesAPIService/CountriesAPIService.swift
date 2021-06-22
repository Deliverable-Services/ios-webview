//
//  CountriesAPIService.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 24/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation

private enum APIPath: APIPathProtocol {
  case all
  
  var rawValue: String {
    switch self {
    case .all:
      return "/all"
    }
  }
}

public struct RestCountriesAPIRequest: APIRequestProtocol {
  public var scheme: String = "https"
  public var host: String = "restcountries.eu"
  public var port: Int?
  public var base: String? = "/rest/v2"
  public var accessToken: String?
  public var overrideHeaders: [String : String]?
  
  public func authHeaders() -> [String : String] {
    return [:]
  }
}

private struct APIRequestJSONData: APIRequestJSONDataProtocol {
  var filename: String
  var expectedResultCode: Int
}

public struct CountriesAPIService: APIServiceProtocol, APIServiceJSONCompletionProtocol {
  public var request: APIRequestProtocol = RestCountriesAPIRequest()
  public var path: APIPathProtocol?
  public var method: HTTPMethod = .get
  public var requestBody: Any?
  public var queryParameters: [URLQueryItem]?
  public var debugName: String?
  public var jsonData: APIRequestJSONDataProtocol?
  public var bundle: Bundle?
}

extension CountriesAPIService {
  public static func getAllCountries() -> CountriesAPIService {
    var service = CountriesAPIService()
    service.path = APIPath.all
    service.method = .get

    service.jsonData = APIRequestJSONData(filename: "countries", expectedResultCode: 200)
    service.bundle = .r4pidKit
    
    service.debugName = #function
    return service
  }
}
