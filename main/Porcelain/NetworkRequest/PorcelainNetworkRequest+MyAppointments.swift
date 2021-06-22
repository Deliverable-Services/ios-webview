//
//  PorcelainNetworkRequest+MyAppointments.swift
//  Porcelain
//
//  Created by Jean on 7/3/18.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation

enum MyAppointmentsRequestAction: PorcelainNetworkRequestAction {
  case getAppointmentsToday
  case getTreatmentPlan
  case getAppointments
  case cancelAppointment
  case confirmAppointment
}

/*************************************************/

extension RequestPath {
  public static let myAppointmentsToday = "/api/user/appointments_today/{user_id}"
  public static let myAppointments = "/api/user/appointments/{user_id}"
  public static let cancelAppointment = "/api/bookappointment/cancel"
  public static let confirmAppointment = "/api/bookappointment/confirm"
  public static let treatmentPlan = "/api/core/customer/treatmentPlans/{user_id}"
}

/*************************************************/

private struct Replaceable {
  static let userID = "{user_id}"
}

extension PorcelainNetworkRequest {
  public func getMyAppointmentsToday(_ userID: String) {
    var request = DefaultGetRequest()
    request.path = RequestPath.myAppointmentsToday
    request.path = request.path.replaceString(Replaceable.userID, with: userID)
    startRequest(request, action: MyAppointmentsRequestAction.getAppointmentsToday)
  }
  
  public func getMyAppointments(_ userID: String) {
    var request = DefaultGetRequest()
    request.path = RequestPath.myAppointments
    request.path = request.path.replaceString(Replaceable.userID, with: userID)
    startRequest(request, action: MyAppointmentsRequestAction.getAppointments)
  }
  
  func cancelAppointment(_ id: String) {
    var request = DefaultPostRequest()
    request.path = RequestPath.cancelAppointment
    var parameters: [String: Any] = [:]
    parameters[PorcelainAPIConstant.Key.data] = [PorcelainAPIConstant.Key.appointmentID: id]
    request.parameters = parameters
    startRequest(request, action: MyAppointmentsRequestAction.cancelAppointment)
  }
  
  func confirmAppointment(_ id: String) {
    var request = DefaultPostRequest()
    request.path = RequestPath.confirmAppointment
    var parameters: [String: Any] = [:]
    parameters[PorcelainAPIConstant.Key.data] = [PorcelainAPIConstant.Key.appointmentID: id]
    request.parameters = parameters
    startRequest(request, action: MyAppointmentsRequestAction.confirmAppointment)
  }
  
  public func getTreatmentPlan(_ userID: String) {
    var request = DefaultGetRequest()
    request.path = RequestPath.treatmentPlan
    request.path = request.path.replaceString(Replaceable.userID, with: userID)
    startRequest(request, action: MyAppointmentsRequestAction.getTreatmentPlan)
  }
}
