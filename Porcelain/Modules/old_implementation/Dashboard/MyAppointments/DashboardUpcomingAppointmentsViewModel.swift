//
//  DashboardUpcomingAppointmentsViewModel.swift
//  Porcelain
//
//  Created by Jean on 7/5/18.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import SwiftyJSON
import KRProgressHUD
import R4pidKit

class DashboardUpcomingAppointmentsViewModel:
DashboardUpcomingAppointmentsViewModelProtocol {
  // MARK: - Protocol properties
  var upcomingAppointments: [AppointmentStruct] = []
  var previousAppointments: [TreatmentHistory] = []
  
  // MARK: - Private properties
  fileprivate lazy var historyHandler: TreatmentHistoryHandler = {
    let request = TreatmentHistoryHandler()
    request.delegate = self
    return request
  }()
  
  fileprivate lazy var appointmentsHandler: MyAppointmentsHandler = {
    let request = MyAppointmentsHandler()
    request.delegate = self
    return request
  }()
  
  fileprivate var networkDispatchGroup = DispatchGroup()
  fileprivate weak var view: DashboardUpcomingAppointmentsCell?
  
  // MARK: - Protocol methods
  // Fetch content from coredata
  func fetchContent() {
    
    upcomingAppointments = []
    previousAppointments = []
    fetchUpcomingAppointments()
    fetchPreviousAppointments()
    view?.reloadData()
  }
  
  // Fetch content from server, save then fetch content from coredata
  @objc func reloadContent() {
    guard AppUserDefaults.isLoggedIn else { return }
    fetchContent()
    historyHandler.getTreatmentHistory()
    appointmentsHandler.getAppointments()
  }
  
  func attachView(_ view: DashboardUpcomingAppointmentsCell) {
    AppNotificationCenter.default
      .addObserver(self, selector: #selector(DashboardUpcomingAppointmentsViewModel.reloadContent),
                   name: AppNotificationNames.appointmentsDidChange, object: nil)
    self.view = view
  }
  
  deinit {
    AppNotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Private methods
  private func fetchUpcomingAppointments() {
    upcomingAppointments = Appointment.myUpcomingAppointments()
  }
  
  private func fetchPreviousAppointments() {
    let userid = AppUserDefaults.customer?.id ?? ""
    var prevRecipe = CoreDataRecipe()
    prevRecipe.predicate = CoreDataRecipe.Predicate.isEqual(key: "user.id", value: userid).rawValue
    prevRecipe.sorts = [
      .custom(key: "startDate", isAscending: true),
      .custom(key: "endDate", isAscending: true),
      .custom(key: "name", isAscending: true)
    ]
    self.previousAppointments = CoreDataUtil
      .listObjects(TreatmentHistory.self, recipe: prevRecipe) as? [TreatmentHistory] ?? []
  }
}

// MARK: - Network Returns
// MARK: Upcoming Appointments
extension DashboardUpcomingAppointmentsViewModel: MyAppointmentsHandlerDelegate {
  func myAppointmentsHandlerWillStart(_ handler: MyAppointmentsHandler,
                                      action: MyAppointmentsAction) {
    
    guard action == .getAppointments else { return }
    networkDispatchGroup.enter()
    networkDispatchGroup.notify(queue: .main) { [weak self] () in
      guard let strongSelf = self else { return }
      strongSelf.fetchContent()
      KRProgressHUD.hideHUD()
    }
    
    KRProgressHUD.showHUD()
  }
  
  func myAppointmentsHandlerSuccessful(_ handler: MyAppointmentsHandler,
                                       action: MyAppointmentsAction,
                                       response: JSON) {
    
    guard action == .getAppointments else { return }
    networkDispatchGroup.leave()
  }
  
  func myAppointmentsHandlerDidFail(_ handler: MyAppointmentsHandler,
                                    action: MyAppointmentsAction,
                                    error: Error?,
                                    msg: String?) {

    guard action == .getAppointments else { return }
    networkDispatchGroup.leave()
    view?.displayError()
  }
}

// MARK: Treatment History
extension DashboardUpcomingAppointmentsViewModel: TreatmentHistoryHandlerDelegate {
  func treatmentHistoryHandlerWillStart(_ handler: TreatmentHistoryHandler,
                                        action: TreatmentHistoryAction) {
    networkDispatchGroup.enter()
  }
  
  func treatmentHistoryHandlerSuccessful(_ handler: TreatmentHistoryHandler,
                                         action: TreatmentHistoryAction, response: JSON) {
    print("response \(response)")
    guard let responseData = response.array?[0].dictionary?["data"]
      else {
        self.treatmentHistoryHandlerDidFail(handler, action: action, error: nil)
        return
      }
    
    CoreDataUtil.performBackgroundTask({ (moc) in
      CoreDataUtil.truncateEntity(TreatmentHistory.self, inMOC: moc)
      for monthData in responseData.arrayValue {
        let history = JSON(monthData["treatments"]).arrayValue
        let _ = history.compactMap({ TreatmentHistory.object(from: $0, inMOC: moc) })
      }
    }) { (_) in
      self.networkDispatchGroup.leave()
    }
  }
  
  func treatmentHistoryHandlerDidFail(_ handler: TreatmentHistoryHandler,
                                      action: TreatmentHistoryAction,
                                      error: Error?) {
    
    networkDispatchGroup.leave()
    switch action {
    case .getTreatmentHistory: view?.displayError()
    }
  }
}
