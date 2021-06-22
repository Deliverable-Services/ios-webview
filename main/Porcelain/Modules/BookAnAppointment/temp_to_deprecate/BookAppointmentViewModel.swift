//
//  BookAppointmentViewModel.swift
//  Porcelain
//
//  Created by Justine Rangel on 15/10/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct ReBookAppointmentData {
  var locationID: String?
  var treatmentID: String?
  var therapistID: String?
}

public enum BookAppointmentSection {
  case treatment
  case addOns
  case therapists
  case notes
  case calendar
  case schedule
  case request
}

public protocol BookAppointmentView: class {
  func reload()
  func forceUpdateNavigationTitle(name: String, subtitle: String)
  func showLoading()
  func hideLoading()
  func selectTreatmentsByLocation()
  func selectAddonsByLocation()
  func selectTherapistsByTreatment()
  func showError(message: String?)
  func showSuccess(message: String?)
}

public struct BookAppointmentData {
  var id: String?
  var name: String?
}

public protocol BookAppointmentViewModelProtocol: class {
  var isBookAppointmentWalkthroughDone: Bool { get set }
  var shownSections: [BookAppointmentSection] { get set }
  var locationData: BookAppointmentData? { get set }
  var treatmentData: BookAppointmentData? { get set }
  var addOnsData: [BookAppointmentData] { get set }
  var addOnsNoPreference: Bool { get set }
  var therapistsData: [BookAppointmentData] { get set }
  var therapistsNoPreference: Bool { get set }
  var locations: [Location] { get }
  var selectTreatmentViewModel: SelectTreatmentViewModel? { get }
  var addOns: [Addon] { get set }
  var therapists: [BAATherapistModel] { get set }
  var notes: String { get set }
  var calendarReferenceDate: Date { get set }
  var selectedCalendarReferenceDate: Date? { get set }
  var calendarScheduleDates: [BACalendarScheduleDate] { get set }
  var selectedCalendarScheduleDate: BACalendarScheduleDate? { get set }
  var selectedScheduleTime: BAScheduleTime? { get set }
  var selectedScheduleTherapist: BAScheduleTherapist? { get set }
  var scheduleIndicatorType: BAScheduleIndicatorType? { get set }
  var isRequestEnabled: Bool { get }
  var rebookData: ReBookAppointmentData? { get set }

  func attachView(_ view: BookAppointmentView)
  func initialize()
  func loadAndSelectTreatmentsByLocation(locationID: String?, completion: VoidCompletion?)
  func loadAndSelectAddOnsByLocation(locationID: String?)
  func loadAndSelectTherapistsByTreatment(treatmentID: String?)
  func loadAvailableSlots()
  func requestAppointment()
  func triggerRebookingIfNeeded()
}

extension BookAppointmentViewModelProtocol {
  public func generateSections() {
    shownSections = [.treatment, .addOns, .therapists]
    let canShowCalendar = therapistsNoPreference ||
      !therapistsData.isEmpty ||
      !isBookAppointmentWalkthroughDone //walkthrough flag
    if canShowCalendar {
      shownSections.append(.calendar)
    }
    shownSections.append(.schedule)
    shownSections.append(.request)
  }
  
  public func generateIndicatorType(isLoading: Bool) {
    if isLoading {
      scheduleIndicatorType = .activity(isLoading: true)
    } else {
      if selectedCalendarReferenceDate != nil {
        if !calendarScheduleDates.isEmpty {
          scheduleIndicatorType = nil
        } else if treatmentData?.id == nil {
          scheduleIndicatorType = .alert(message: "PLEASE SELECT A TREATMENT".localized())
        } else if locationData?.id == nil {
          scheduleIndicatorType = .alert(message: "PLEASE SELECT A LOCATION".localized())
        } else {
          scheduleIndicatorType = .alert(message: "NO SCHEDULE AVAILABLE".localized())
        }
      } else {
        scheduleIndicatorType = .alert(message: "PLEASE SELECT A DATE".localized())
      }
    }
  }
  
  public func defaultSettings() {
    shownSections = []
    addOnsData = []
    addOnsNoPreference = true
    therapistsData = []
    therapistsNoPreference = true
    addOns = []
    therapists = []
    notes = ""
    selectedCalendarReferenceDate = nil
    calendarScheduleDates = []
    selectedCalendarScheduleDate = nil
    selectedScheduleTime = nil
    selectedScheduleTherapist = nil
    generateIndicatorType(isLoading: false)
  }
  
  public func walkthroughSettings() {
    shownSections = []
    addOnsData = []
    addOnsNoPreference = false
    therapistsData = []
    therapistsNoPreference = false
    addOns = []
    therapists = []
    notes = ""
    let minDate = calendarReferenceDate.startOfTheDay()
    let maxDate = minDate.dateByAdding(days: 6)
    selectedCalendarReferenceDate = minDate
    calendarScheduleDates = generateCalendarScheduleDates(minDate: minDate, maxDate: maxDate)
    selectedCalendarScheduleDate = calendarScheduleDates.last
    selectedScheduleTime = BAScheduleTime(rawTime: "13:45")
    selectedScheduleTherapist = BAScheduleTherapist(id: "12345678", name: "Justine Rangel", timeSlots: [])
    generateIndicatorType(isLoading: false)
  }
  
  private func generateCalendarScheduleDates(minDate: Date?, maxDate: Date?) -> [BACalendarScheduleDate] {
    guard let minDate = minDate, let maxDate = maxDate else { return [] }
    var scheduleDates: [BACalendarScheduleDate] = []
    var enumeratorDate = minDate
    var i = 0
    while enumeratorDate <= maxDate {
      if i%2 == 0 {
        var timeSlots: [BAScheduleTime] = []
        timeSlots.append(BAScheduleTime(
          rawTime: "10:00"))
        timeSlots.append(BAScheduleTime(
          rawTime: "10:15"))
        timeSlots.append(BAScheduleTime(
          rawTime: "10:30"))
        timeSlots.append(BAScheduleTime(
          rawTime: "10:45"))
        timeSlots.append(BAScheduleTime(
          rawTime: "13:30"))
        timeSlots.append(BAScheduleTime(
          rawTime: "13:45"))
        timeSlots.append(BAScheduleTime(
          rawTime: "14:00"))
        timeSlots.append(BAScheduleTime(
          rawTime: "14:15"))
        timeSlots.append(BAScheduleTime(
          rawTime: "14:30"))
        timeSlots.append(BAScheduleTime(
          rawTime: "14:45"))
        timeSlots.append(BAScheduleTime(
          rawTime: "15:00"))
        timeSlots.append(BAScheduleTime(
          rawTime: "18:00"))
        timeSlots.append(BAScheduleTime(
          rawTime: "18:15"))
        timeSlots.append(BAScheduleTime(
          rawTime: "18:30"))
        timeSlots.append(BAScheduleTime(
          rawTime: "18:45"))
        timeSlots.append(BAScheduleTime(
          rawTime: "19:00"))
        var therapists: [BAScheduleTherapist] = []
        therapists.append(BAScheduleTherapist(
          id: "12345678",
          name: "Justine Rangel 😛",
          timeSlots: timeSlots))
        therapists.append(BAScheduleTherapist(
          id: "87654321",
          name: "Jean Manas 😉",
          timeSlots: timeSlots))
        let location = BAScheduleLocation(
          id: "b287df33-d7bd-4a15-86e9-0764c6cfebff",
          name: "Porcelain Aesthetics",
          address: "277 Orchard Road, Orchard Gateway #03-13,",
          therapists: therapists)
        let scheduleDate = BACalendarScheduleDate(
          date: enumeratorDate,
          locations: [location])
        scheduleDates.append(scheduleDate)
      }
      i = i + 1
      enumeratorDate = enumeratorDate.dateByAdding(days: 1)
    }
    return scheduleDates
  }
}

public final class BookAppointmentViewModel: BookAppointmentViewModelProtocol {
  private lazy var networkRequest: PorcelainNetworkRequest = {
    let request = PorcelainNetworkRequest()
    request.delegate = self
    return request
  }()
  
  private lazy var networkRequestDispatchGroup = DispatchGroup()
  private lazy var networkRequestASDispatchGroup = DispatchGroup()
  
  private var view: BookAppointmentView?
  
  init() {
    shownSections = []
    addOnsData = []
    addOnsNoPreference = true
    therapistsData = []
    therapistsNoPreference = true
    addOns = []
    therapists = []
    notes = ""
    calendarReferenceDate = Date().dateByAdding(days: 1)
    calendarScheduleDates = []
    isBookAppointmentWalkthroughDone = AppUserDefaults.oneTimeBAWalkthrough
    generateIndicatorType(isLoading: false)
    if !isBookAppointmentWalkthroughDone {
      walkthroughSettings()
    }
  }
  
  public var isBookAppointmentWalkthroughDone: Bool
  public var shownSections: [BookAppointmentSection]
  public var locationData: BookAppointmentData?
  public var treatmentData: BookAppointmentData?
  public var addOnsData: [BookAppointmentData]
  public var addOnsNoPreference: Bool
  public var therapistsData: [BookAppointmentData]
  public var therapistsNoPreference: Bool
  public var locations: [Location] {
    return CoreDataUtil.list(
      Location.self,
      predicate: .compoundAnd(
        predicates: [
          .isEqual(key: "isActive", value: true),
          .isEqual(key: "type", value: LocationType.appointment.rawValue)]),
      sorts: [.custom(key: "name", isAscending: true)])
  }
  public var selectTreatmentViewModel: SelectTreatmentViewModel?
  public var addOns: [Addon]
  public var therapists: [BAATherapistModel]
  public var notes: String
  public var calendarReferenceDate: Date
  public var selectedCalendarReferenceDate: Date?
  public var calendarScheduleDates: [BACalendarScheduleDate]
  public var selectedCalendarScheduleDate: BACalendarScheduleDate?
  public var selectedScheduleTime: BAScheduleTime?
  public var selectedScheduleTherapist: BAScheduleTherapist?
  public var scheduleIndicatorType: BAScheduleIndicatorType?
  public var isRequestEnabled: Bool {
    guard selectedScheduleTime != nil else { return false }
    guard selectedScheduleTherapist != nil else { return false }
    return true
  }
  public var rebookData: ReBookAppointmentData?
}

extension BookAppointmentViewModel {
  public func attachView(_ view: BookAppointmentView) {
    self.view = view
  }
  
  public func initialize() {
    view?.showLoading()
    networkRequest.getAppointmentLocations()
    networkRequest.getAppointmentTreatments()
    networkRequest.getAppointmentAddons()
    networkRequestDispatchGroup.notify(queue: .main) { [weak self] in
      guard let `self` = self else { return }
      self.view?.hideLoading()
      self.view?.reload()
      self.triggerRebookingIfNeeded()
    }
  }
  
  public func loadAndSelectTreatmentsByLocation(locationID: String?, completion: VoidCompletion? = nil) {
    var treatmentCategories: [SelectTreatmentCategoryViewModel] = []
    CoreDataUtil.performBackgroundTask({ (moc) in
      var categoryRecipe = CoreDataRecipe()
      categoryRecipe.predicate = CoreDataRecipe.Predicate.compoundAnd(
        predicates: [.isEqual(key: "type", value: TreatmentType.appointment.rawValue),
                     .isEqual(key: "isActive", value: true)]).rawValue
      
      categoryRecipe.distinctProperties = ["category"]
      
      let categoryObjects = CoreDataUtil.listObjects(Treatment.self, recipe: categoryRecipe, inMOC: moc) as! [[String: String]]
      let categories = categoryObjects.map({ $0["category"]! }).sorted { (s1, s2) -> Bool in
        guard let sort1 = CategorySort(rawValue: s1), let sort2 = CategorySort(rawValue: s2) else { return false }
        return sort1.sortValue < sort2.sortValue
      }
      
      categories.forEach { (category) in
        var previousTreatmentID: String?
        var predicates: [CoreDataRecipe.Predicate] = [
          .isEqual(key: "type", value: TreatmentType.appointment.rawValue),
          .isEqual(key: "isActive", value: true),
          .isEqual(key: "category", value: category)]
        
        if let locationID = locationID {
          predicates.append(.isEqual(key: "location.id", value: locationID))
        }
        
        let treatments: [Treatment] = CoreDataUtil.list(
          Treatment.self,
          predicate: .compoundAnd(predicates: predicates),
          sorts: [.custom(key: "name", isAscending: true)],
          inMOC: moc).filter({ (treatment) -> Bool in
            let isValid = previousTreatmentID != treatment.id
            previousTreatmentID = treatment.id
            return isValid
          })
        
        let treatmentCategory = SelectTreatmentCategoryViewModel(
          title: category.localized(),
          treatments: treatments.map({ TreatmentModel(treatment: $0) }))
        treatmentCategories.append(treatmentCategory)
      }
      self.selectTreatmentViewModel = SelectTreatmentViewModel(treatmentCategories: treatmentCategories)
    }, completion: { (_) in
      if let completion = completion {
        completion()
      } else {
        self.view?.selectTreatmentsByLocation()
      }
    })
  }
  
  public func loadAndSelectAddOnsByLocation(locationID: String?) {
    var previousAddonID: String?
    var predicates: [CoreDataRecipe.Predicate] = [
      .isEqual(key: "type", value: AddonType.appointment.rawValue),
      .isEqual(key: "isActive", value: true)]
    
    if let locationID = locationID {
      predicates.append(.isEqual(key: "location.id", value: locationID))
    }
    
    let addOns = CoreDataUtil.list(
      Addon.self,
      predicate: .compoundAnd(predicates: predicates),
      sorts: [.custom(key: "name", isAscending: true)]).filter({ (addon) -> Bool in
        let isValid = previousAddonID != addon.id
        previousAddonID = addon.id
        return isValid
      })
    self.addOns = addOns
    self.view?.selectAddonsByLocation()
  }
  
  public func loadAndSelectTherapistsByTreatment(treatmentID: String?) {
    if let treatmentID = treatmentID {
      networkRequest.getAppointmentTherapistsByTreatment(treatmentID)
    } else {
      view?.showError(message: "Please select a treatment first")
    }
  }
  
  public func loadAvailableSlots() {
    guard let treatmentID = treatmentData?.id else {
      generateIndicatorType(isLoading: false)
      return
    }
    guard let locationID = locationData?.id else {
      generateIndicatorType(isLoading: false)
      return
    }
    if !addOnsNoPreference && addOnsData.isEmpty { return }
    if !therapistsNoPreference && therapistsData.isEmpty { return }
    guard let selectedCalendarReferenceDate = selectedCalendarReferenceDate else { return }
    var therapistIDs: String?
    if !therapistsData.isEmpty {
      therapistIDs = therapistsData.map({ $0.id! }).joined(separator: ",")
    }
    let minDateString = selectedCalendarReferenceDate.toString(WithFormat: "yyyy-MM-dd")
    let maxDateString = selectedCalendarReferenceDate.toString(WithFormat: "yyyy-MM-dd")
    networkRequest.getAppointmentAvailableSlotsByTreatment(
      treatmentID: treatmentID,
      locationsIDs: locationID,
      therapistIDs: therapistIDs,
      startDate: minDateString,
      endDate: maxDateString)
    generateIndicatorType(isLoading: true)
    networkRequestASDispatchGroup.notify(queue: .main) { [weak self] in
      guard let `self` = self else { return }
      self.generateIndicatorType(isLoading: false)
      self.view?.reload()
      self.triggerRebookingIfNeeded()
    }
  }
  
  public func requestAppointment() {
    guard let userID = AppUserDefaults.userID else { return }
    guard let treatmentID = treatmentData?.id else { return }
    guard let therapistID = selectedScheduleTherapist?.id else { return }
    guard let locationID = locationData?.id else { return }
    guard let dateString = selectedCalendarReferenceDate?.toString(WithFormat: "YYYY-MM-dd") else { return }
    guard let timeString = selectedScheduleTime?.rawTime else { return }
    
    var parameters: [String: Any] = [:]
    parameters[PorcelainAPIConstant.Key.userID] = userID
    parameters[PorcelainAPIConstant.Key.treatmentID] = treatmentID
    parameters[PorcelainAPIConstant.Key.therapistID] = therapistID
    parameters[PorcelainAPIConstant.Key._locationID] = locationID
    let addOnIDs = addOnsData.map({ $0.id! })
    if !addOnIDs.isEmpty {
      parameters[PorcelainAPIConstant.Key.addonIDs] = addOnIDs
    }
    parameters[PorcelainAPIConstant.Key.timeSlot] = concatenate(dateString, "T", timeString, ":00Z")
    networkRequest.createAppointment([PorcelainAPIConstant.Key.data: parameters])
  }
  
  public func triggerRebookingIfNeeded() {
    guard let rebookData = rebookData, isBookAppointmentWalkthroughDone else { return }
    if let locationID = rebookData.locationID, let location = locations.first(where: { $0.id == locationID }) {
      locationData = BookAppointmentData(id: locationID, name: location.locationName ?? location.address!)
      view?.forceUpdateNavigationTitle(name: location.name!, subtitle: location.locationName ?? location.address!)
    }
    if let treatmentID = rebookData.treatmentID {
      loadAndSelectTreatmentsByLocation(locationID: rebookData.locationID) {
        self.selectTreatmentViewModel?.treatmentCategories.forEach({ (treatmentCategory) in
          treatmentCategory.treatments.forEach({ (treatment) in
            if treatment.id == treatmentID {
              self.treatmentData = BookAppointmentData(id: treatmentID, name: treatment.title)
              self.view?.reload()
              if !self.therapistsData.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                  self.loadAndSelectTherapistsByTreatment(treatmentID: treatmentID)
                }
              }
            }
          })
        })
      }
    }
  }
}

// MARK: - PorcelainNetworkRequestDelegateProtocol
extension BookAppointmentViewModel: PorcelainNetworkRequestDelegateProtocol {
  internal func requestWillStart(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction) {
    guard let bookAppointmentRequestAction = action as? BookAppointmentRequestAction else { return }
    switch bookAppointmentRequestAction {
    case .getAppointmentLocations:
      networkRequestDispatchGroup.enter()
    case .getAppointmentTreatments:
      networkRequestDispatchGroup.enter()
    case .getAppointmentAddons:
      networkRequestDispatchGroup.enter()
    case .getAppointmentTherapistsByTreatment:
      view?.showLoading()
    case .getAppointmentAvailableSlots:
      networkRequestASDispatchGroup.enter()
    case .createAppointment:
      view?.showLoading()
    default: break
    }
  }
  
  internal func requestDidFail(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction, error: Error?, statusCode: Int?, errorMessage: String?) {
    guard let bookAppointmentRequestAction = action as? BookAppointmentRequestAction else { return }
    switch bookAppointmentRequestAction {
    case .getAppointmentLocations:
      networkRequestDispatchGroup.leave()
      view?.showError(message: errorMessage)
    case .getAppointmentTreatments:
      networkRequestDispatchGroup.leave()
      view?.showError(message: errorMessage)
    case .getAppointmentAddons:
      networkRequestDispatchGroup.leave()
      view?.showError(message: errorMessage)
    case .getAppointmentTherapistsByTreatment:
      view?.hideLoading()
      view?.showError(message: errorMessage)
    case .getAppointmentAvailableSlots:
      networkRequestASDispatchGroup.leave()
      view?.showError(message: errorMessage)
    case .createAppointment:
      view?.hideLoading()
      view?.showError(message: errorMessage)
      loadAvailableSlots() //update to reload available slots if create appointment failed
    default: break
    }
  }
    
  
  internal func requestSuccessful(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction, result: Any?) {
    guard let bookAppointmentRequestAction = action as? BookAppointmentRequestAction else { return }
    switch bookAppointmentRequestAction {
    case .getAppointmentLocations:
      CoreDataUtil.performBackgroundTask({ (moc) in
        Location.parseAppointmentLocations(result, inMOC: moc)
      }, completion: { (_) in
        self.networkRequestDispatchGroup.leave()
      })
    case .getAppointmentTreatments:
      CoreDataUtil.performBackgroundTask({ (moc) in
        Treatment.parseAppointmentTreatmentsByLocation(result, inMOC: moc)
      }, completion: { (_) in
        self.networkRequestDispatchGroup.leave()
      })
    case .getAppointmentAddons:
      CoreDataUtil.performBackgroundTask({ (moc) in
        Addon.parseAppointmentAddonsByLocation(result, inMOC: moc)
      }, completion: { (_) in
        self.networkRequestDispatchGroup.leave()
      })
    case .getAppointmentTherapistsByTreatment:
      view?.hideLoading()
      therapists = BAATherapistModel.parseTherapists(result, locationID: locationData?.id)
      if let therapistID = rebookData?.therapistID {
        rebookData = nil
        therapists.forEach { (therapistsModel) in
          if therapistsModel.id == therapistID, let therapistName = therapistsModel.name {
            self.therapistsData = [BookAppointmentData(id: therapistID, name: therapistName)]
            self.view?.reload()
          }
        }
      } else {
        if therapists.isEmpty {
          view?.showError(message: "No therapists available")
        } else {
          view?.selectTherapistsByTreatment()
        }
      }
    case .getAppointmentAvailableSlots:
      calendarScheduleDates = BACalendarScheduleDate.parseAvailableSchedules(result)
      selectedCalendarScheduleDate = calendarScheduleDates.first
      selectedScheduleTime = nil
      selectedScheduleTherapist = nil
      networkRequestASDispatchGroup.leave()
    case .createAppointment:
      view?.hideLoading()
      AppNotificationCenter
        .default.post(name: AppNotificationNames.appointmentsDidChange, object: nil)
      if let result = result {
        view?.showSuccess(message: JSON(result).getMessage())
      } else {
        view?.showSuccess(message: nil)
      }
    default: break
    }
  }
}
