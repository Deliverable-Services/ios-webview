//
//  AppNotification+CoreDataClass.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 10/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData
import R4pidKit
import SwiftyJSON

@objc(AppNotification)
public class AppNotification: NSManagedObject {
  public static func getNotifications(notificationIDs: [String]? = nil, customerID: String, inMOC: NSManagedObjectContext = .main) -> [AppNotification] {
    var predicates: [CoreDataRecipe.Predicate] = [.isEqual(key: "customer.id", value: customerID)]
    if let notificationIDs = notificationIDs, !notificationIDs.isEmpty {
      if notificationIDs.count == 1, let notificationID = notificationIDs.first {
        predicates.append(.isEqual(key: "id", value: notificationID))
      } else  {
        predicates.append(.isEqualIn(key: "id", values: notificationIDs))
      }
    }
    return CoreDataUtil.list(AppNotification.self, predicate: .compoundAnd(predicates: predicates), inMOC: inMOC)
  }
  
  public static func getNotification(id: String, customerID: String, inMOC: NSManagedObjectContext = .main) -> AppNotification? {
    return getNotifications(notificationIDs: [id], customerID: customerID, inMOC: inMOC).first
  }
  
  public func updateFromData(_ data: JSON) {
    id = data.id.numberString
    userID = data.userID.string
    title = data.title.string
    message = data.message.string
    commonID = data.commonID.string
    commonIDType = data.commonIDType.string
    action = data.action.string
    url = data.url.string
    isRead = data.isRead.boolValue
    dateSent = data.dateSent.toDate(format: .ymdhmsDateFormat)
    dateUpdated = data.updatedAt.toDate(format: .ymdhmsDateFormat)
    dateCreated = data.createdAt.toDate(format: .ymdhmsDateFormat)
  }
}

extension AppNotification {
  public static func parseNotificationsFromData(_ data: JSON, customer: Customer, inMOC: NSManagedObjectContext) {
    let notificationArray = data.array ?? []
    let notificationIDs = notificationArray.compactMap({ $0.id.numberString })
    
    let deprecatedNotifications = CoreDataUtil.list(
      AppNotification.self,
      predicate: .compoundAnd(predicates: [
        .isEqual(key: "customer.id", value: customer.id!),
        .notEqualIn(key: "id", values: notificationIDs)]),
      inMOC: inMOC)
    CoreDataUtil.deleteEntities(deprecatedNotifications, inMOC: inMOC)
    
    let notifications = getNotifications(notificationIDs: notificationIDs, customerID: customer.id!, inMOC: inMOC)
    notificationArray.forEach { (data) in
      parseNotificationFromData(data, customer: customer, notifications: notifications, inMOC: inMOC)
    }
  }
  
  @discardableResult
  public static func parseNotificationFromData(_ data: JSON, customer: Customer, notifications:[AppNotification], inMOC: NSManagedObjectContext) -> AppNotification? {
    guard let notificationID = data.id.numberString else { return nil }
    let currentNotification = notifications.first(where: { $0.id == notificationID })
    let notification = CoreDataUtil.createEntity(AppNotification.self, fromEntity: currentNotification, inMOC: inMOC)
    notification.updateFromData(data)
    notification.customer = customer
    return notification
  }
}
