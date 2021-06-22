//
//  AppointmentStruct.swift
//  Porcelain
//
//  Created by Jean on 7/24/18.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import SwiftyJSON
import R4pidKit

public struct AppointmentStruct {
  var id: String
  var name: String
  var preferredTherapists: String
  var sessionsDone: Int
  var sessionsLeft: Int
  var timeEnd: Date?
  var timeStart: Date?
  var type: String
  var branchID: String
  var userID: String
  var isFromNotification: Bool
  var addOns: [String]
  
  func branch() -> Branch? {
    return CoreDataUtil
      .get(Branch.self,
           predicate: CoreDataRecipe.Predicate
            .isEqual(key: "id", value: branchID))
  }
  
  func user() -> User? {
    return CoreDataUtil
      .get(User.self,
           predicate: CoreDataRecipe.Predicate
            .isEqual(key: "id", value: userID))
  }
  
  static func object(from app: Appointment) -> AppointmentStruct {
    return AppointmentStruct(
      id: app.id!,
      name: app.name ?? "",
      preferredTherapists: app.preferredTherapists ?? "",
      sessionsDone: Int(app.sessionsDone),
      sessionsLeft: Int(app.sessionsLeft),
      timeEnd: app.timeEnd as Date?,
      timeStart: app.timeStart as Date?,
      type: app.type ?? "",
      branchID: app.branch?.id ?? "",
      userID: app.customer?.id ?? "",
      isFromNotification: app.isFromNotification,
      addOns: app.addOns ?? []
    )
  }
  
  static func object(from json: JSON) -> AppointmentStruct {
    return AppointmentStruct(
      id: json[PorcelainAPIConstant.Key.id].stringValue,
      name: json[PorcelainAPIConstant.Key.name].stringValue,
      preferredTherapists: json[PorcelainAPIConstant.Key.preferredTherapists].stringValue,
      sessionsDone: json[PorcelainAPIConstant.Key.sessionsDone].int ?? 0,
      sessionsLeft: json[PorcelainAPIConstant.Key.sessionsLeft].int ?? 0,
      timeEnd: json[PorcelainAPIConstant.Key.timeEnd].string?
        .toDate(format: Appointment.dateFormat) as Date?,
      timeStart: json[PorcelainAPIConstant.Key.timeStart].string?
        .toDate(format: Appointment.dateFormat) as Date?,
      type: json[PorcelainAPIConstant.Key.type].stringValue,
      branchID: json[PorcelainAPIConstant.Key.branch]
        .dictionaryValue[PorcelainAPIConstant.Key.id]?.string ?? "",
      userID: AppUserDefaults.customer?.id ?? "",
      isFromNotification: false,
      addOns: (json[PorcelainAPIConstant.Key.addOns].arrayObject as? [String]) ?? []
    )
  }
}
