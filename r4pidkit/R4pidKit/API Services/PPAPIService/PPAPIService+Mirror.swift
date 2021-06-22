//
//  PPAPIService+Mirror.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 01/10/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation

private enum APIPath: APIPathProtocol {
  case teas
  case mirror
  case customerMirror(customerID: String)
  case orderTea(customerID: String, teaID: String)
  
  var rawValue: String {
    switch self {
    case .teas:
      return "/mirror/teas"
    case .mirror:
      return "/mirror"
    case .customerMirror(let customerID):
      return "/mirror/customer/\(customerID)"
    case .orderTea(let customerID, let teaID):
      return "/mirror/customer/\(customerID)/tea/\(teaID)/order"
    }
  }
}

extension PPAPIService.Mirror {
  public static func getTeas() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.teas
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getMirror() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.mirror
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getCustomerMirror(customerID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.customerMirror(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func orderTea(customerID: String, teaID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.orderTea(customerID: customerID, teaID: teaID)
    service.method = .post
    service.debugName = #function
    return service
  }
}
