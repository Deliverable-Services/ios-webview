//
//  OldInteractiveAPIService+Customer.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 19/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation

private enum APIPath: APIPathProtocol {
  case customers
  case visits(userID: String)
  
  var rawValue: String {
    switch self {
    case .customers:
      return "/customers"
    case .visits(let userID):
      return "/customers/visits/\(userID)"
    }
  }
}

extension OldInteractiveAPIService.Customer {
  public static func getCustomersByBranch(branchID: String, page: Int) -> OldInteractiveAPIService {
    var service = OldInteractiveAPIService()
    service.method = .get
    service.path = APIPath.customers
    service.queryParameters = [
      URLQueryItem(name: "branchID", value: branchID),
      URLQueryItem(key: .page, value: "\(page)")]
    service.debugName = #function
    return service
  }
  
  public static func searchCustomers(search: String?) -> OldInteractiveAPIService {
    var service = OldInteractiveAPIService()
    service.method = .get
    service.path = APIPath.customers
    service.queryParameters = [
      URLQueryItem(key: .search, value: search),
      URLQueryItem(key: .page, value: "1")]
    service.debugName = #function
    return service
  }
  
  public static func getCustomerVisits(userID: String) -> OldInteractiveAPIService {
    var service = OldInteractiveAPIService()
    service.method = .get
    service.path = APIPath.visits(userID: userID)
    service.debugName = #function
    return service
  }
}
