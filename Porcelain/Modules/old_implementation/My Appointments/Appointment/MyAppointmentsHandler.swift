//
//  MyAppointmentsHandler.swift
//  Porcelain
//
//  Created by Jean on 7/3/18.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import SwiftyJSON
import R4pidKit

enum MyAppointmentsAction {
  case getTreatmentPlan
  case getAppointments
  case cancelAppointment
  case confirmAppointment
}

protocol MyAppointmentsHandlerProtocol: class {
  var delegate: MyAppointmentsHandlerDelegate? { get }
}

protocol MyAppointmentsHandlerDelegate: class {
  func myAppointmentsHandlerWillStart(_ handler: MyAppointmentsHandler,action: MyAppointmentsAction)
  func myAppointmentsHandlerDidFail(_ handler: MyAppointmentsHandler,action: MyAppointmentsAction, error: Error?, msg: String?)
  func myAppointmentsHandlerSuccessful(_ handler: MyAppointmentsHandler, action: MyAppointmentsAction, response: JSON)
}

class MyAppointmentsHandler: MyAppointmentsHandlerProtocol {
  weak var delegate: MyAppointmentsHandlerDelegate?
  
  fileprivate lazy var networkRequest: PorcelainNetworkRequest = {
    let request = PorcelainNetworkRequest()
    request.delegate = self
    return request
  }()
  
  func getAppointments() {
//    guard let userId = AppUserDefaults.customer?.id else {
//      self.delegate?.myAppointmentsHandlerDidFail(self, action: .getAppointments, error: nil, msg: nil)
//      return
////      fatalError("No user session")
//    }
//    self.networkRequest.getMyAppointments(userId)
  }
  
  func getTreatmentPlan() {
//    guard let userId = AppUserDefaults.customer?.id else {
//      self.delegate?.myAppointmentsHandlerDidFail(self, action: .getTreatmentPlan, error: nil, msg: nil)
//      return
//      //      fatalError("No user session")
//    }
//    self.networkRequest.getTreatmentPlan(userId)
  }
  
  func cancelAppointment(appointmentID: String) {
    self.networkRequest.cancelAppointment(appointmentID)
  }
  
  func confirmAppointment(appointmentID: String) {
    self.networkRequest.confirmAppointment(appointmentID)
  }

  private func replaceAppointments(with response: JSON, completion: @escaping (() -> Void)) {
    guard let data = response.array?[0].dictionary?["data"]?.arrayValue
      else { return }
    CoreDataUtil.performBackgroundTask({ (moc) in
//      let userId = AppUserDefaults.customer?.id ?? ""
//      var recipe = CoreDataRecipe()
//      recipe.predicate = CoreDataRecipe.Predicate
//        .isEqual(key: "user.id", value: userId)
//        .rawValue
////        .compoundAnd(predicates: [
////          .isEqual(key: "user.id", value: userId)
////          ,.isEqual(key: "isFromNotification", value: false)])
////        .rawValue
//
//      guard let toDelete = CoreDataUtil
//        .listObjects(Appointment.self, recipe: recipe, inMOC: moc)
//        as? [Appointment] else { return }
//      CoreDataUtil.deleteEntities(toDelete, inMOC: moc)
    }) { (_) in
      CoreDataUtil.performBackgroundTask({ (moc) in
        let _ : [Appointment] = data
          .compactMap({ Appointment.object(from: $0, inMOC: moc) })
      }) { (_) in completion() }
    }
  }
}

extension MyAppointmentsHandler: PorcelainNetworkRequestDelegateProtocol {
  func requestWillStart(_ dataSource: PorcelainNetworkRequest,
                        action: PorcelainNetworkRequestAction) {
    guard let action = action as? MyAppointmentsRequestAction else { return }
    switch action {
    case .getTreatmentPlan:
      self.delegate?.myAppointmentsHandlerWillStart(self, action: .getTreatmentPlan)
    case .getAppointments:
      self.delegate?.myAppointmentsHandlerWillStart(self, action: .getAppointments)
    case .cancelAppointment:
      self.delegate?.myAppointmentsHandlerWillStart(self, action: .cancelAppointment)
    case .confirmAppointment:
      self.delegate?.myAppointmentsHandlerWillStart(self, action: .confirmAppointment)
    }
  }
  
  func requestDidFail(_ dataSource: PorcelainNetworkRequest,
                      action: PorcelainNetworkRequestAction,
                      error: Error?,
                      statusCode: Int?,
                      errorMessage: String?) {
    print("Failed: ", error ?? "")
    print(statusCode.debugDescription)
    guard let action = action as? MyAppointmentsRequestAction else { return }
    switch action {
    case .getTreatmentPlan:
      self.delegate?.myAppointmentsHandlerDidFail(self, action: .getTreatmentPlan, error: error, msg: errorMessage)
    case .getAppointments:
      self.delegate?.myAppointmentsHandlerDidFail(self, action: .getAppointments, error: error, msg: errorMessage)
    case .cancelAppointment:
      self.delegate?.myAppointmentsHandlerDidFail(self, action: .cancelAppointment, error: error, msg: errorMessage)
    case .confirmAppointment:
      self.delegate?.myAppointmentsHandlerDidFail(self, action: .confirmAppointment, error: error, msg: errorMessage)
    }
  }
  
  func requestSuccessful(_ dataSource: PorcelainNetworkRequest,
                         action: PorcelainNetworkRequestAction,
                         result: Any?) {
    guard let action = action as? MyAppointmentsRequestAction else { return }
    
    let json = JSON(result ?? "")
    switch action {
    case .getTreatmentPlan:
      self.delegate?.myAppointmentsHandlerSuccessful(self, action: .getTreatmentPlan, response: json)
    case .getAppointments:
      replaceAppointments(with: json) { [weak self] () in
        guard let strongSelf = self else { return }
        strongSelf.delegate?.myAppointmentsHandlerSuccessful(strongSelf, action: .getAppointments, response: json)
      }
    case .cancelAppointment:
      self.delegate?.myAppointmentsHandlerSuccessful(self, action: .cancelAppointment, response: json)
    case .confirmAppointment:
      self.delegate?.myAppointmentsHandlerSuccessful(self, action: .confirmAppointment, response: json)
    }
//    print(result)
  }
}
