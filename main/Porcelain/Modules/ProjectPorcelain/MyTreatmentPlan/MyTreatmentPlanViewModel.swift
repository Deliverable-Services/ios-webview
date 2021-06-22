//
//  MyTreatmentPlanViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 02/10/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit

public enum MyTreatmentPlanSection {
  case upcomingAppointments
  case treatmentPlan
  case view
}

public protocol MyTreatmentPlanView: class {
  func reload()
  func showLoading(section: MyTreatmentPlanSection)
  func hideLoading(section: MyTreatmentPlanSection)
  func showMessage(section: MyTreatmentPlanSection, message: String?)
  func showError(section: MyTreatmentPlanSection, message: String?)
}

public protocol MyTreatmentPlanViewModelProtocol: class {
  var upcomingAppointmentsRecipe: CoreDataRecipe { get }
  var treatmentPlan: TreatmentPlan? { get }
  var treatmentPlanRecipe: CoreDataRecipe { get }
  
  func attachView(_ view: MyTreatmentPlanView)
  func initialize()
  func reloadUpcomingAppointments()
  func reloadMyTreatmentPlan()
}

public final class MyTreatmentPlanViewModel: MyTreatmentPlanViewModelProtocol {
  private weak var view: MyTreatmentPlanView?
  
  public var upcomingAppointmentsRecipe: CoreDataRecipe {
    var recipe = CoreDataRecipe()
    recipe.sorts = [.custom(key: "dateStart", isAscending: true)]
    let predicates: [CoreDataRecipe.Predicate] = [
      .isEqual(key: "customer.id", value: AppUserDefaults.customerID),
      .isEqual(key: "type", value: AppointmentType.upcoming.rawValue)]
    recipe.predicate = CoreDataRecipe.Predicate.compoundAnd(predicates: predicates).rawValue
    return recipe
  }
  
  public var treatmentPlan: TreatmentPlan? {
    return AppUserDefaults.customer?.treatmentPlan
  }
  
  public var treatmentPlanRecipe: CoreDataRecipe {
    var recipe = CoreDataRecipe()
    recipe.sorts = [.custom(key: "sequenceNumber", isAscending: true)]
    recipe.predicate = CoreDataRecipe.Predicate.compoundAnd(predicates: [
      .isEqual(key: "planID", value: treatmentPlan?.id)]).rawValue
    return recipe
  }
}

extension MyTreatmentPlanViewModel {
  public func attachView(_ view: MyTreatmentPlanView) {
    self.view = view
  }
  
  public func initialize() {
    CalendarEventUtil.load()
    view?.reload()
    reloadUpcomingAppointments()
    reloadMyTreatmentPlan()
  }
  
  public func reloadUpcomingAppointments() {
    view?.showLoading(section: .upcomingAppointments)
    PPAPIService.User.getMyAppointmentsUpcoming().call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customerID = AppUserDefaults.customerID else { return }
          guard let customer = User.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
          Appointment.parseAppointmentsFromData(result.data, customer: customer, type: .upcoming, inMOC: moc)
        }, completion: { (_) in
          let appointmentIDs = result.data.array?.compactMap({ $0.appointmentID.string }) ?? []
          self.updateUpcomingEventAppointments(appointmentIDs: appointmentIDs)
          self.view?.hideLoading(section: .upcomingAppointments)
          self.view?.showMessage(section: .upcomingAppointments, message: result.message)
        })
      case .failure(let error):
        self.view?.hideLoading(section: .upcomingAppointments)
        self.view?.showError(section: .upcomingAppointments, message: error.localizedDescription)
      }
    }
  }
  
  public func reloadMyTreatmentPlan() {
    guard let customerID = AppUserDefaults.customerID else { return }
    view?.showLoading(section: .treatmentPlan)
    PPAPIService.User.getMyTreatmentPlan().call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customer = User.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
          TreatmentPlan.parseTreatmentPlan(result.data, customer: customer, inMOC: moc)
        }, completion: { (_) in
          self.view?.reload()
          self.view?.hideLoading(section: .treatmentPlan)
          self.view?.showMessage(section: .treatmentPlan, message: result.message)
        })
      case .failure(let error):
        self.view?.hideLoading(section: .treatmentPlan)
        self.view?.showError(section: .treatmentPlan, message: error.localizedDescription)
      }
    }
  }
}

extension MyTreatmentPlanViewModel {
  private func updateUpcomingEventAppointments(appointmentIDs: [String]) {
    guard let customerID = AppUserDefaults.customerID else { return }
    let appointments = Appointment.getAppointments(appointmentIDs: appointmentIDs, customerID: customerID)
    deleteExistingAppointmentEventIfNeeded(appointmentIDs: appointmentIDs)
    appointments.forEach { (appointment) in
      updateExistingAppointmentEvent(appointment: AppointmentEvent(appointment: appointment))
    }
  }
  
  private func deleteExistingAppointmentEventIfNeeded(appointmentIDs: [String]) {
    guard let customerID = AppUserDefaults.customerID else { return }
    CalendarEventUtil.searchEvent(queries: [customerID]) { (events) in
      events.forEach { (event) in
        var toDelete = true
        appointmentIDs.forEach { (appointmentID) in
          if event.notes?.contains(appointmentID) ?? false {
            toDelete = false
          }
        }
        if toDelete {
          CalendarEventUtil.deleteEvent(event.eventIdentifier)
        }
      }
    }
  }
  
  private func updateExistingAppointmentEvent(appointment: AppointmentEvent) {
    guard let customerID = AppUserDefaults.customerID else { return }
    guard let appointmentID = appointment.appointment?.id else { return }
    guard let startDate = appointment.startDate else { return }
    guard let endDate = appointment.endDate else { return }
    CalendarEventUtil.searchEvent(queries: [customerID, appointmentID]) { (events) in
      events.forEach { (event) in
        CalendarEventUtil.saveOrUpdateEvent(
          event,
          eventModel: CalendarEventItem(
            title: appointment.treatment?.name ?? "",
            startDate: startDate,
            endDate: endDate,
            alarms: [.onTime, .oneHourBefore],
            notes: [customerID, appointmentID, appointment.appointmentNote?.note ?? ""].joined(separator: "\n"))) { (_) in
        }
      }
    }
  }
}
