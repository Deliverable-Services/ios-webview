//
//  PPAPIService+Product.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 11/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation

private enum APIPath: APIPathProtocol {
  case createProductReview(productID: String)
  case productReviews(productID: String)
  case productHTML(productID: String)
  case productVariation(productID: String)
  case productExtraInfo(productID: String)
  
  var rawValue: String {
    switch self {
    case .createProductReview(let productID):
      return "/product/\(productID)/review"
    case .productReviews(let productID):
      return "/product/\(productID)/reviews"
    case .productHTML(let productID):
      return "/product/\(productID)/html_description"
    case .productVariation(let productID):
      return "/product/\(productID)/variations"
    case .productExtraInfo(let productID):
      return "/product/\(productID)/extra_info"
    }
  }
}

extension PPAPIService.Product {
  public static func createProductReview(productID: String, request: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.createProductReview(productID: productID)
    service.method = .post
    service.requestBody = PPAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func getProductReviews(productID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.productReviews(productID: productID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getProductHTML(productID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.productHTML(productID: productID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getProductVariations(productID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.productVariation(productID: productID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getProductExtraInfo(productID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.productExtraInfo(productID: productID)
    service.method = .get
    service.debugName = #function
    return service
  }
}
