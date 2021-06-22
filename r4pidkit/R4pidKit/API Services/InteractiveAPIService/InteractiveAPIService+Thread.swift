//
//  InteractiveAPIService+Thread.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 1/30/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation

private enum APIPath: APIPathProtocol {
  case thread(moduleID: String)
  case createThreadItem(moduleID: String)
  
  var rawValue: String {
    switch self {
    case .thread(let moduleID):
      return "/thread/\(moduleID)"
    case  .createThreadItem(let moduleID):
      return "/thread/\(moduleID)/create"
    }
  }
}

extension InteractiveAPIService.Thread {
  public static func getThread(moduleID: String, moduleType: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.thread(moduleID: moduleID)
    service.queryParameters = [URLQueryItem(key: .moduleType, value: moduleType)]
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func createThreadItem(moduleID: String, moduleType: String, message: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.createThreadItem(moduleID: moduleID)
    service.method = .post
    service.requestBody = InteractiveAPIService.createRequestBody([
      .moduleType: moduleType,
      .note: message])
    service.debugName = #function
    return service
  }
}
