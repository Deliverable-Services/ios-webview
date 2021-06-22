//
//  PPAPIService+Authentication.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 21/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation

private enum APIPath: APIPathProtocol {
  case sendOTP
  case resendOTP(phone: String)
  case verifyOTP
  case debugVerifyOTP
  case signUp
  case signUpValidate
  case signIn
  case signInCredential
  case signInSocial
  case signInDebug

  var rawValue: String {
    switch self {
    case .sendOTP:
      return "/otp/send"
    case .resendOTP(let phone):
      return "/otp/\(phone)/resend"
    case .verifyOTP:
      return "/otp/verify"
    case .debugVerifyOTP:
      return "/otp/debug_verify"
    case .signUp:
      return "/register"
    case .signUpValidate:
      return "/register/validate"
    case .signIn:
      return "/signin"
    case .signInCredential:
      return "/signin/credential"
    case .signInSocial:
      return "/signin/social"
    case .signInDebug:
      return "/signin/debuger"
    }
  }
}

extension PPAPIService.Authentication {
  public static func sendOTP(phone: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.sendOTP
    service.method = .post
    service.requestBody = PPAPIService.createRequestBody([.phone: "\(phone)"])
    service.debugName = #function
    return service
  }
  
  public static func resendOTP(phone: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.resendOTP(phone: phone)
    service.method = .post
    service.debugName = #function
    return service
  }
  
  public static func signInSendOTP(phone: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.signIn
    service.method = .post
    service.requestBody = PPAPIService.createRequestBody([
      .phone: "\(phone)"])
    service.debugName = #function
    return service
  }
  
  public static func signInVerifyOTP(phone: String, otp: String, debug: Bool = false) -> PPAPIService {
    var service = PPAPIService()
    if debug {
      service.path = APIPath.debugVerifyOTP
    } else {
      service.path = APIPath.verifyOTP
    }
    service.method = .post
    service.requestBody = PPAPIService.createRequestBody([
      .phone: "\(phone)",
      .otp: otp])
    service.debugName = #function
    return service
  }
  
  public static func signUp(request: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.signUp
    service.method = .post
    service.requestBody = PPAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func signUpValidate(email: String, phone: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.signUpValidate
    service.method = .post
    service.requestBody = PPAPIService.createRequestBody([
      .email: email,
      .phone: phone])
    service.debugName = #function
    return service
  }
  
  public static func signInSocial(request: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.signInSocial
    service.method = .post
    service.requestBody = PPAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func signInDebug(phone: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.signInDebug
    service.method = .post
    service.requestBody = PPAPIService.createRequestBody([
      .phone: "\(phone)"])
    service.debugName = #function
    return service
  }
}
