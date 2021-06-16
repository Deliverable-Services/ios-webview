//
//  BookAnAppointmentViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 22/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit

public struct RebookData: AppointmentProtocol {
  public var appointment: Appointment?
  
  public var selectedCenter: Center?
  public var selectedTreatment: Service?
  public var selectedAddons: [Service]?
  public var selectedTherapists: [Therapist]?
  public var notes: String?
}

extension RebookData {
  init(appointment: Appointment) {
    self.appointment = appointment
    selectedCenter = center
    selectedTreatment = treatment
    selectedAddons = addons
    if let therapist = therapist {
      selectedTherapists = [therapist]
    }
    notes = appointmentNote?.note
  }
}

public typealias RebookAppointmentCompletion = ((RebookData?) -> Void)

public protocol BookAnAppointmentView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func showError(message: String?)
  func showSuccess(message: String?)
}

public protocol BookAnAppointmentViewModelProtocol {
  var rebookData: RebookData? { get set }
  var selectedCenter: Center? { get set }
  var selectedTreatment: Service? { get set }
  var selectedAddons: [Service]? { get set }
  var selectedTherapists: [Therapist]? { get set }
  var notes: String? { get set }
  
  func attachView(_ view: BookAnAppointmentView)
  func initialize()
  func reload()
  func requestAppointment(data: BAATimeSlotsResultData)
}

public final class BookAnAppointmentViewModel: BookAnAppointmentViewModelProtocol {
  private weak var view: BookAnAppointmentView?
  
  public var rebookData: RebookData?
  public var selectedCenter: Center?
  public var selectedTreatment: Service?
  public var selectedAddons: [Service]?
  public var selectedTherapists: [Therapist]?
  public var notes: String?
}

extension BookAnAppointmentViewModel {
  public func attachView(_ view: BookAnAppointmentView) {
    self.view = view
  }
  
  public func initialize() {
    selectedCenter = CoreDataUtil.list(
      Center.self,
      sorts: [.custom(key: "name", isAscending: true)]).first
    if let rebookData = rebookData {
      selectedCenter = rebookData.selectedCenter
      selectedTreatment = rebookData.selectedTreatment
      selectedAddons = rebookData.selectedAddons
      selectedTherapists = rebookData.selectedTherapists
      notes = rebookData.notes
      self.rebookData = nil
    }
    view?.reload()
    guard selectedCenter == nil else { return }
    view?.showLoading()
    PPAPIService.Center.getCenters().call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          Center.parseCentersFromData(result.data, inMOC: moc)
        }, completion: { (_) in
          self.selectedCenter = CoreDataUtil.list(
            Center.self,
            sorts: [.custom(key: "name", isAscending: true)]).first
          self.view?.hideLoading()
          self.view?.reload()
        })
      case .failure(let error):
        self.view?.hideLoading()
        self.view?.showError(message: error.localizedDescription)
      }
    }
  }
  
  public func reload() {
    view?.reload()
  }
  
  public func requestAppointment(data: BAATimeSlotsResultData) {
    var request: [APIServiceConstant.Key: Any] = [:]
    request[.centerID] = data.centerID
    request[.serviceID] = data.treatmentID
    request[.therapistID] = data.therapistID
    request[.addonIDs] = data.addOnIDs
    if let date = data.date, let time = data.time {
      request[.timeSlot] = "\(date)T\(time):00.000Z"
    }
    request[.notes] = notes
    view?.showLoading()
    PPAPIService.Appointment.bookAnAppointment(request: request).call { (response) in
      switch response {
      case .success(let result):
        self.view?.hideLoading()
        self.view?.showSuccess(message: result.message)
      case .failure(let error):
        self.view?.hideLoading()
        self.view?.showError(message: error.localizedDescription)
      }
    }
  }
}
