//
//  PPAPIService.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 16/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation

public struct PPAPIRequest: APIRequestProtocol {
  public var scheme: String = APIServiceConstant.isProduction ? "https": "http"
  public var host: String = APIServiceConstant.isProduction ? "api.porcelainskin.com": "13.228.83.66"
  public var port: Int? = APIServiceConstant.isProduction ? nil: 82
  public var base: String? = "/api/v2"
  public var accessToken: String? = APIServiceConstant.accessToken
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
  
  public init() {
  }
}

private  enum APIPath: APIPathProtocol {
  case weather
  case banners
  case articles
  case news
  case prologues
  case promotions
  case products
  case product(productID: String)
  case treatments
  
  var rawValue: String {
    switch self {
    case .weather:
      return "/weather"
    case .banners:
      return "/banners"
    case .articles:
      return "/articles"
    case .news:
      return "/news"
    case .prologues:
      return "/prologues"
    case .promotions:
      return "/promotions"
    case .product(let productID):
      return "/product/\(productID)"
    case .products:
      return "/products/category"
    case .treatments:
      return "/treatments/category"
    }
  }
}

public struct  PPAPIService: APIServiceProtocol  {
  public var request: APIRequestProtocol = PPAPIRequest()
  public var path: APIPathProtocol?
  public var method: HTTPMethod = .get
  public var requestBody: Any?
  public var queryParameters: [URLQueryItem]?
  public var debugName: String?
}

extension PPAPIService {
  public static func getWeather(latitude: String, longitude: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.weather
    service.method = .get
    service.queryParameters = [
      URLQueryItem(key: .latitude, value: latitude),
      URLQueryItem(key: .longitude, value: longitude)]
    service.debugName = #function
    return service
  }
  
  public static func getBanners(type: String, temperature: String?, humidity: String?, lastSessionTimestamp: String?) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.banners
    service.method = .get
    service.queryParameters = [
      URLQueryItem(key: .type, value: type)]
    if let temperature = temperature {
      service.queryParameters?.append(URLQueryItem(key: .temperature, value: temperature))
    }
    if let humidity = humidity {
      service.queryParameters?.append(URLQueryItem(key: .humidity, value: humidity))
    }
    if let lastSessionTimestamp = lastSessionTimestamp {
      service.queryParameters?.append(URLQueryItem(key: .lastSessionTimestamp, value: lastSessionTimestamp))
    }
    service.debugName = #function
    return service
  }
  
  public static func getArticles() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.articles
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getNews() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.news
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getPrologues() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.prologues
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getPromotions() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.promotions
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getProduct(id: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.product(productID: id)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getProducts() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.products
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getTreatments() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.treatments
    service.method = .get
    service.debugName = #function
    return service
  }
}

extension PPAPIService {
  public struct Authentication {
  }
  
  public struct User {
  }
  
  public struct Center {
  }
  
  public struct Appointment {
  }
  
  public struct Product {
  }
  
  public struct Checkout {
  }
  
  public struct Mirror {
  }
}
