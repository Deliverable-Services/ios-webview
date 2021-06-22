//
//  InteractiveAPIService+Employee.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 14/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation

private enum APIPath: APIPathProtocol {
  case profile
  case notifications
  case notificationDetails(notificationID: String)
  case updateNotification(notificationID: String)
  case readNotification(notificationID: String)
  
  var rawValue: String {
    switch self {
    case .profile:
      return "/me"
    case  .notifications:
      return "/core_notifications"
    case .notificationDetails(let notificationID):
      return "/core_notification/\(notificationID)"
    case .updateNotification(let notificationID):
      return "/core_notification/\(notificationID)"
    case .readNotification(let notificationID):
      return "/core_notification/\(notificationID)/read"
    }
  }
}

extension InteractiveAPIService.Employee {
  public static func getProfile() -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.profile
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getNotifications(page: Int, noteType: Int?, assignedBy: String?, search: String?) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.notifications
    var queryParameters = [URLQueryItem(key: .page, value: String(format: "%d", page))]
    if let noteType = noteType {
      queryParameters.append(URLQueryItem(key: .noteType, value: String(format: "%d", noteType)))
    }
    if let assignedBy = assignedBy {
      queryParameters.append(URLQueryItem(key: .assignedBy, value: assignedBy))
    }
    if let search = search {
      queryParameters.append(URLQueryItem(key: .search, value: search))
    }
    service.queryParameters = queryParameters
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getNotificationDetails(notificationID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.notificationDetails(notificationID: notificationID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  //status: 1-complete 2-dismiss
  public static func updateNotificationStatus(notificationID: String, status: Int) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.notificationDetails(notificationID: notificationID)
    service.method = .post
    service.requestBody = InteractiveAPIService.createRequestBody([
      .status: status])
    service.debugName = #function
    return service
  }
  
  public static func readNotification(notificationID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.readNotification(notificationID: notificationID)
    service.method = .patch
    service.requestBody = InteractiveAPIService.createRequestBody([
      .status: 2])
    service.debugName = #function
    return service
  }
}
