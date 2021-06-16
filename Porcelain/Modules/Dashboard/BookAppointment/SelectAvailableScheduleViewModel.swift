//
//  SelectAvailableScheduleViewModel.swift
//  Porcelain
//
//  Created by Justine Rangel on 30/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum AvailableScheduleDay: String {
  case monday = "Monday"
  case tuesday = "Tuesday"
  case wednesday = "Wednesday"
  case thursday = "Thursday"
  case friday = "Friday"
  case saturday = "Saturday"
  case sunday = "Sunday"
}

public protocol SelectAvailableScheduleView: class {
  func showLoading()
  func hideLoading()
  func reload()
  func showSuccess(_ message: String?)
  func showError(_ message: String?)
  func updateFooter()
  func bookNow()
}

public struct AvailableScheduleDate {
  var title: String?
  var day: AvailableScheduleDay?
  var locations: [AvailableScheduleLocationViewModel]
}

extension AvailableScheduleDate {
  public static func parseAvailableSchedule(_ schedules: Any?) -> [AvailableScheduleDate] {
    guard let schedules = schedules else { return [] }
    guard let scheduleArray = JSON(schedules)[0].dictionaryValue[PorcelainAPIConstant.Key.data]?.array else { return [] }
    return scheduleArray.map { (json) -> AvailableScheduleDate in
      let dateString = json[PorcelainAPIConstant.Key.date].string
      let date = dateString?.toDate(format: "yyyy-MM-dd")
      let dayString = date?.toString(WithFormat: "EEEE") ?? ""
      var title = date?.toString(WithFormat: "MMMM dd, yyyy")
      title?.append(contentsOf: concatenate(" | ", dayString))
      var locations = json[PorcelainAPIConstant.Key.locations].arrayValue.map({ (locationJSON) -> AvailableScheduleLocationViewModel in
        return AvailableScheduleLocationViewModel(json: locationJSON, dateString: dateString ?? "")
      })
      
      locations = locations.filter({ return $0.therapists.count > 0 })
      return AvailableScheduleDate(title: title?.uppercased(), day: AvailableScheduleDay(rawValue: dayString), locations: locations)
    }
  }
}

public protocol SelectAvailableScheduleViewModelProtocol: class, SelectAvailableScheduleFooterViewModelProtocol {
  var treatmentID: String { get }
  var addOnIDs: [String]? { get }
  var dayFilter: [AvailableScheduleDay] { get set }
  var selectedAvailableSchedule: SelectedAvailableSchedule? { get set }
  var availableScheduleDates: [AvailableScheduleDate] { get }
  var filteredAvailableScheduleDates: [AvailableScheduleDate] { get set }
  
  func attachView(_ view: SelectAvailableScheduleView)
  func updateFooter()
}

extension SelectAvailableScheduleViewModelProtocol {
  public func generateFilteredAvailableSchedule() {
    let filteredAvailableScheduleDates = availableScheduleDates.filter { (availableScheduleDate) -> Bool in
      guard let day = availableScheduleDate.day else { return false }
      return dayFilter.contains(day)
    }
    self.filteredAvailableScheduleDates = filteredAvailableScheduleDates
  }
}

public class SelectAvailableScheduleViewModel: SelectAvailableScheduleViewModelProtocol {
  private lazy var networkRequest: PorcelainNetworkRequest = {
    let request = PorcelainNetworkRequest()
    request.delegate = self
    return request
  }()
  
  private weak var view: SelectAvailableScheduleView?
  
  init(treatmentID: String, addOnIDs: [String]?, availableScheduleDates: [AvailableScheduleDate]) {
    self.treatmentID = treatmentID
    self.addOnIDs = addOnIDs
    dayFilter = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    self.availableScheduleDates = availableScheduleDates
    filteredAvailableScheduleDates = availableScheduleDates
    self.selectedAvailableSchedule = nil
  }
  
  public var treatmentID: String
  
  public var addOnIDs: [String]?
  
  public var dayFilter: [AvailableScheduleDay]
  
  public var selectedAvailableSchedule: SelectedAvailableSchedule?
  
  public private(set) var availableScheduleDates: [AvailableScheduleDate]
  
  public var filteredAvailableScheduleDates: [AvailableScheduleDate]
  
  public var isBookNowEnabled: Bool {
    return selectedAvailableSchedule != nil
  }
}

extension SelectAvailableScheduleViewModel {
  public func attachView(_ view: SelectAvailableScheduleView) {
    self.view = view
  }
  
  public func bookNowTapped() {
    var parameters: [String: Any] = [:]
    parameters[PorcelainAPIConstant.Key.userID] = AppUserDefaults.userID!
    parameters[PorcelainAPIConstant.Key.treatmentID] = treatmentID
    parameters[PorcelainAPIConstant.Key.therapistID] = selectedAvailableSchedule!.therapistID
    parameters[PorcelainAPIConstant.Key._locationID] = selectedAvailableSchedule!.locationID
    if let addOnIDs = addOnIDs {
      parameters[PorcelainAPIConstant.Key.addonIDs] = addOnIDs
    }
    parameters[PorcelainAPIConstant.Key.timeSlot] = concatenate(selectedAvailableSchedule!.dateString, "T", selectedAvailableSchedule!.timeString, ":00Z")
    networkRequest.createAppointment([PorcelainAPIConstant.Key.data: parameters])
  }
  
  public func updateFooter() {
    view?.updateFooter()
  }
}

extension SelectAvailableScheduleViewModel: PorcelainNetworkRequestDelegateProtocol {
  internal func requestWillStart(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction) {
    guard let bookAppointmentRequestAction = action as? BookAppointmentRequestAction else { return }
    switch bookAppointmentRequestAction {
    case .createAppointment:
      view?.showLoading()
    default: break
    }
  }
  
  internal func requestDidFail(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction, error: Error?, statusCode: Int?, errorMessage: String?) {
    guard let bookAppointmentRequestAction = action as? BookAppointmentRequestAction else { return }
    switch bookAppointmentRequestAction {
    case .createAppointment:
      view?.hideLoading()
      view?.showError(errorMessage)
    default: break
    }
  }
  
  internal func requestSuccessful(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction, result: Any?) {
    guard let bookAppointmentRequestAction = action as? BookAppointmentRequestAction else { return }
    switch bookAppointmentRequestAction {
    case .createAppointment:
      view?.hideLoading()
      AppNotificationCenter
        .default.post(name: AppNotificationNames.appointmentsDidChange, object: nil)
      if let result = result {
        view?.showSuccess(JSON(result).getMessage())
      } else {
        view?.showSuccess(nil)
      }
    default: break
    }
  }
}
