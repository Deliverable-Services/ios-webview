//
//  PPAPIService+Checkout.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 18/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation

private enum APIPath: APIPathProtocol {
  case calculateShipping
  case calculateShippingNew
  case paymentGateways
  case shippingMethods
  case validateCoupon(code: String)
  case validateCouponNew(code: String)
  case checkout
  case checkoutNew
  
  var rawValue: String {
    switch self {
    case .calculateShipping:
      return "/shipping/calculate"
    case .calculateShippingNew:
      return "/shipping/calculatenew"
    case .validateCoupon(let code):
      return "/checkout/coupon/validate/\(code)"
    case .validateCouponNew(let code):
      return "/checkout/coupon/validatenew/\(code)"
    case .paymentGateways:
      return "/checkout/payment_gateways"
    case .shippingMethods:
      return "/checkout/shipping_methods"
    case .checkout:
      return "/checkout"
    case .checkoutNew:
      return "/checkoutnew"
    }
  }
}

extension PPAPIService.Checkout {
  public static func calculateShipping(countryCode: String, shippingMethod: String, discountType: String?, discountValue: String?) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.calculateShipping
    service.queryParameters = [
      URLQueryItem(key: .countryCode, value: countryCode),
      URLQueryItem(key: .shippingMethod, value: shippingMethod)]
    if let discountType = discountType {
      service.queryParameters?.append(URLQueryItem(key: .shippingDiscountType, value: discountType))
    }
    if let discountValue = discountValue {
      service.queryParameters?.append(URLQueryItem(key: .shippingDiscountValue, value: discountValue))
    }
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func calculateShippingNew(countryCode: String, shippingMethod: String, discountType: String?, discountValue: String?) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.calculateShippingNew
    service.queryParameters = [
      URLQueryItem(key: .countryCode, value: countryCode),
      URLQueryItem(key: .shippingMethod, value: shippingMethod)]
    if let discountType = discountType {
      service.queryParameters?.append(URLQueryItem(key: .shippingDiscountType, value: discountType))
    }
    if let discountValue = discountValue {
      service.queryParameters?.append(URLQueryItem(key: .shippingDiscountValue, value: discountValue))
    }
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func validateCoupon(code: String, request: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.validateCoupon(code: code)
    service.method = .post
    service.requestBody = PPAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func validateCouponNew(code: String, request: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.validateCouponNew(code: code)
    service.method = .post
    service.requestBody = PPAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func getPaymentGateways() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.paymentGateways
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getShippingMethods(countryCode: String, amount: String?, realAmounnt: String, couponCode: String?) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.shippingMethods
    service.queryParameters = [URLQueryItem(key: .countryCode, value: countryCode), URLQueryItem(key: .realAmount, value: realAmounnt)]
    if let amount = amount {
      service.queryParameters?.append(URLQueryItem(key: .amount, value: amount))
    }
    if let couponCode = couponCode {
      service.queryParameters?.append(URLQueryItem(key: .couponCode, value: couponCode))
    }
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func checkout(request: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.checkout
    service.method = .post
    service.requestBody = PPAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func checkoutNew(request: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.checkoutNew
    service.method = .post
    service.requestBody = PPAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
}
