//
//  MyAppointmentsViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 08/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit

public struct AppointmentEvent: AppointmentProtocol {
  public var appointment: Appointment?
}

public enum MyAppointmentsSection {
  case upcomingAppointments
  case pendingAppointments
  case sessionPackages
  case view
}

public protocol MyAppointmentsView: class {
  func reload()
  func showLoading(section: MyAppointmentsSection)
  func hideLoading(section: MyAppointmentsSection)
  func showMessage(section: MyAppointmentsSection, message: String?)
  func showError(section: MyAppointmentsSection, message: String?)
}

public protocol MyAppointmentsViewModelProtocol {
  var upcomingAppointmentsRecipe: CoreDataRecipe { get }
  var pendingAppointmentsRecipe: CoreDataRecipe { get }
  var isGrouped: Bool { get set }
  var packages: [PackageData]? { get }
  
  func attachView(_ view: MyAppointmentsView)
  func initialize()
  func reloadUpcomingAppointments()
  func reloadPendingAppointments()
  func reloadSessionPackages()
}

public final class  MyAppointmentsViewModel: MyAppointmentsViewModelProtocol {
  private weak var view: MyAppointmentsView?
  
  public var upcomingAppointmentsRecipe: CoreDataRecipe {
    var recipe = CoreDataRecipe()
    recipe.sorts = [.custom(key: "dateStart", isAscending: true)]
    let predicates: [CoreDataRecipe.Predicate] = [
      .isEqual(key: "customer.id", value: AppUserDefaults.customerID),
      .isEqual(key: "type", value: AppointmentType.upcoming.rawValue)]
    recipe.predicate = CoreDataRecipe.Predicate.compoundAnd(predicates: predicates).rawValue
    return recipe
  }
  
  public var pendingAppointmentsRecipe: CoreDataRecipe {
    var recipe = CoreDataRecipe()
    recipe.sorts = [.custom(key: "dateStart", isAscending: true)]
    let predicates: [CoreDataRecipe.Predicate] = [
      .isEqual(key: "customer.id", value: AppUserDefaults.customerID),
      .isEqual(key: "type", value: AppointmentType.pending.rawValue)]
    recipe.predicate = CoreDataRecipe.Predicate.compoundAnd(predicates: predicates).rawValue
    return recipe
  }
  
  public var isGrouped: Bool = true {
    didSet {
      generatePackages()
    }
  }
  public var packages: [PackageData]?
}

extension MyAppointmentsViewModel {
  public func attachView(_ view: MyAppointmentsView) {
    self.view = view
  }
  
  public func initialize() {
    CalendarEventUtil.load()
    view?.reload()
    reloadUpcomingAppointments()
    reloadPendingAppointments()
    reloadSessionPackages()
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
  
  public func reloadPendingAppointments() {
    view?.showLoading(section: .pendingAppointments)
    PPAPIService.User.getMyAppointmentsPending().call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customerID = AppUserDefaults.customerID else { return }
          guard let customer = User.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
          Appointment.parseAppointmentsFromData(result.data, customer: customer, type: .pending, inMOC: moc)
        }, completion: { (_) in
          self.view?.hideLoading(section: .pendingAppointments)
          self.view?.showMessage(section: .pendingAppointments, message: result.message)
        })
      case .failure(let error):
        self.view?.hideLoading(section: .pendingAppointments)
        self.view?.showError(section: .pendingAppointments, message: error.localizedDescription)
      }
    }
  }
  
  public func reloadSessionPackages() {
    view?.showLoading(section: .sessionPackages)
    PPAPIService.User.getMyPackages().call { (response) in
      switch response {
      case  .success(let result):
        AppUserDefaults.customerPackageData = result.data
        self.generatePackages()
        self.view?.hideLoading(section: .sessionPackages)
        self.view?.showMessage(section: .sessionPackages, message: result.message)
      case .failure(let error):
        self.packages = nil
        self.view?.hideLoading(section: .sessionPackages)
        self.view?.showError(section: .sessionPackages, message: error.localizedDescription)
      }
    }
  }
}

extension MyAppointmentsViewModel {
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
  
  private func generatePackages() {
    if let packageData = AppUserDefaults.customerPackageData {
      let packages = PackageData.parseData(packageData)
      if isGrouped {
        self.packages = packages?.filter({ !($0.treatments?.isEmpty ?? true) }) //filter out package without treatments
      } else {
        if var packageData = packages?.first {
          var individualsDict: [String: IndividualData] = [:]
          packages?.forEach { (packageData) in
            packageData.treatments?.forEach { (individualData) in
              guard let id = individualData.id else { return }
              if var individualDataDict = individualsDict[id] {
                individualDataDict.sessionsLeft += individualData.sessionsLeft
                individualDataDict.sessionsTotal += individualData.sessionsLeft
                individualsDict[id] = individualDataDict
              } else {
                individualsDict[id] = individualData
              }
            }
          }
          packageData.treatments = individualsDict.map({ $0.value }).sorted(by: { $0.sessionsLeft > $1.sessionsLeft })
          self.packages = [packageData]
        } else {
          self.packages = nil
        }
      }
    } else {
      self.packages = nil
    }
  }
}

import SwiftyJSON

extension AppUserDefaults {
  public static var customerPackageData: JSON? {
    get {
      guard let jsonString = R4pidDefaults.shared[.init(value: "\(AppUserDefaults.customerID ?? "")0459D3D6E908BCA9C1AVMO5ZURX3KBZ5C")]?.string else { return nil }
      return JSON(parseJSON: jsonString)
    }
    set {
      R4pidDefaults.shared[.init(value: "\(AppUserDefaults.customerID ?? "")0459D3D6E908BCA9C1AVMO5ZURX3KBZ5C")] = .init(value: newValue?.rawString())
    }
  }
}
