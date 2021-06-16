//
//  AppointmentPopupViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 11/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit

public enum AppointmentPopupSection {
  case calendar
  case notes
  case view
}

public protocol AppointmentPopupView: class {
  func reload()
  func showLoading(section: AppointmentPopupSection)
  func hideLoading(section: AppointmentPopupSection)
  func showError(message: String?)
}

public protocol AppointmentPopupViewModelProtocol: class, AppointmentProtocol {
  var type: AppointmentType { get }
  
  func attachView(_ view: AppointmentPopupView)
  func initialize()
  func addToCalendar()
  func saveNote(text: String)
}

public final class AppointmentPopupViewModel: AppointmentPopupViewModelProtocol {
  private weak var view: AppointmentPopupView?
  
  init(appointment: Appointment) {
    self.appointment = appointment
    self.type = AppointmentType(rawValue: appointment.type ?? "") ?? .upcoming
  }
  
  public var appointment: Appointment?
  public var type: AppointmentType
}

extension AppointmentPopupViewModel {
  public func attachView(_ view: AppointmentPopupView) {
    self.view = view
  }
  
  public func initialize() {
    view?.reload()
  }
  
  public func addToCalendar() {
    guard let customerID = AppUserDefaults.customerID else { return }
    guard let appointmentID = appointment?.id else { return }
    guard let startDate = startDate, let endDate = endDate else { return }
    view?.showLoading(section: .calendar)
    CalendarEventUtil.saveOrUpdateEvent(eventModel:
      CalendarEventItem(
        title: self.treatment?.name ?? "",
        startDate: startDate,
        endDate: endDate,
        alarms: [.onTime, .oneHourBefore],
        notes: [customerID, appointmentID, appointment?.note?.note ?? ""].joined(separator: "\n"))) { (_) in
          self.view?.hideLoading(section: .calendar)
    }
  }
  
  public func saveNote(text: String) {
    guard let appointmentID = appointment?.id, let customerID = appointment?.customer?.id else { return }
    if let noteID = appointmentNote?.id {
      view?.showLoading(section: .notes)
      PPAPIService.User.updateMyAppointmentNote(appointmentID: appointmentID, noteID: noteID, notes: text).call { (response) in
        switch response {
        case .success(let result):
          CoreDataUtil.performBackgroundTask({ (moc) in
            guard let appointment = Appointment.getAppointment(id: appointmentID, customerID: customerID, inMOC: moc) else { return }
            Note.parseNoteFromData(result.data, appointment: appointment, inMOC: moc)
          }, completion: { (_) in
            self.view?.hideLoading(section: .notes)
          })
        case .failure(let error):
          self.view?.hideLoading(section: .notes)
          self.view?.showError(message: error.localizedDescription)
        }
      }
    } else {
      guard !text.isEmpty else { return }
      view?.showLoading(section: .notes)
      PPAPIService.User.createMyAppointmentNote(appointmentID: appointmentID, notes: text).call { (response) in
        switch response {
        case .success(let result):
          CoreDataUtil.performBackgroundTask({ (moc) in
            guard let appointment = Appointment.getAppointment(id: appointmentID, customerID: customerID, inMOC: moc) else { return }
            Note.parseNoteFromData(result.data, appointment: appointment, inMOC: moc)
          }, completion: { (_) in
            self.view?.hideLoading(section: .notes)
          })
        case .failure(let error):
          self.view?.hideLoading(section: .notes)
          self.view?.showError(message: error.localizedDescription)
        }
      }
    }
  }
}
