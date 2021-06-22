//
//  BookAnAppointmentViewModel.swift
//  Porcelain
//
//  Created by Justine Rangel on 09/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import R4pidKit

public enum CategorySort: String {
  case equipmentFacial = "Equipment Facial"
  case extractionFacial = "Extraction Facial"
  case skinDiscovery = "Skin Discovery"
  case illuminate = "Illuminate"
  case ipl = "IPL"
  case proionic = "Proionic"
  case addOns = "Add Ons"
  case miscellaneous = "Miscellaneous"
  case others = "Others"
  
  public var sortValue: Int {
    switch self {
    case .equipmentFacial: return 1
    case .extractionFacial: return 2
    case .skinDiscovery: return 3
    case .illuminate: return 4
    case .ipl: return 5
    case .proionic: return 6
    case .addOns: return 7
    case .miscellaneous: return 8
    case .others: return 9
    }
  }
}

public enum BookAnAppointmentViewType: Int {
  case location = 0, therapist
  
  public var title: String {
    switch self {
    case .location:
      return "Location"
    case .therapist:
      return "Therapist"
    }
  }
}

public enum BookAnAppointmentSection: Int {
  case treatment = 0, addOns, therapists, branches, prefferedDate, notes
}

public enum BookAnAppointmentCalloutType {
  case action // >
  case add // +
  case calendar
  case actionDown
  case none
}

public struct MultiSelectedObject {
  public var id: String
  public var title: String
}

public protocol BookAnAppointmentCellModelProtocol {
  var title: String { get }
  var placeholder: String { get }
  var calloutType: BookAnAppointmentCalloutType { get }
  var content: String? { get set }
  var subcontent: String? { get }
  var info: String? { get }
  var subInfo: String? { get }
  var saveInfo: Any? { get set }
  var multiSelectedObjects: [MultiSelectedObject] { get set }
  
  func actionTapped()
  func triggerReload()
}

public class BookAnAppointmentCellModel: BookAnAppointmentCellModelProtocol {
  init(
    title: String,
    placeholder: String,
    calloutType: BookAnAppointmentCalloutType,
    content: String? = nil,
    subcontent: String? = nil,
    info: String? = nil,
    subInfo: String? = nil) {
    
    self.title = title
    self.placeholder = placeholder
    self.calloutType = calloutType
    self.content = content
    self.subcontent = subcontent
    self.info = info
    self.subInfo = subInfo
    self.multiSelectedObjects = []
  }
  
  public var actionDidTapped: VoidCompletion?
  
  public var didTriggerReload: VoidCompletion?
  
  public private(set) var title: String
  
  public private(set) var placeholder: String
  
  public private(set) var calloutType: BookAnAppointmentCalloutType
  
  public var content: String?
  
  public var subcontent: String?
  
  public var info: String?
  
  public var subInfo: String?
  
  public var saveInfo: Any?
  
  public var multiSelectedObjects: [MultiSelectedObject]
  
  public func actionTapped() {
    actionDidTapped?()
  }
  
  public func triggerReload() {
    didTriggerReload?()
  }
}

public protocol BookAnAppointmentView: class {
  func showLoading()
  func hideLoading()
  func reload()
  func selectBranches()
  func selectTreatmentsByLocation()
  func selectTherapistsByTreatment()
  func selectAddOnsByLocation()
  func selectPrefferedDate()
  func addNotes()
  func updateTable()
  func updateActionFooter()
  func checkAvailability(_ availableDates: [AvailableScheduleDate])
  func showError(_ message: String?)
}

public protocol BookAnAppointmentViewModelProtocol: BookAnAppointmentHeaderModelProtocol, BookAnAppointmentFooterModelProtocol {
  var treatmentViewModel: SelectTreatmentViewModel? { get }
  var branchList: [Location] { get }
  var branches: BookAnAppointmentCellModel { get }
  var treatmentTherapists: [BAATherapistModel] { get set }
  var treatment: BookAnAppointmentCellModel { get }
  var therapistLocations: [BAALocationModel] { get set }
  var therapists: BookAnAppointmentCellModel { get }
  var addOnList: [Addon] { get }
  var addOns: BookAnAppointmentCellModel { get }
  var prefferedDate: BookAnAppointmentCellModel { get }
  var notes: BookAnAppointmentCellModel { get }
  var shownSections: [BookAnAppointmentSection] { get }
  
  func attachView(_ view: BookAnAppointmentView)
  func generateSections()
  func initializeContent()
}

extension BookAnAppointmentViewModelProtocol where Self: BookAnAppointmentViewModel {
  public func generateSections() {
    switch viewType {
    case .location:
      shownSections = [.branches, .treatment, .addOns, .therapists, .prefferedDate]
    case .therapist:
      shownSections = [.treatment, .branches, .therapists, .prefferedDate]
    }
  }
}

public class BookAnAppointmentViewModel: BookAnAppointmentViewModelProtocol {
  private lazy var networkRequest: PorcelainNetworkRequest = {
    let request = PorcelainNetworkRequest()
    request.delegate = self
    return request
  }()
  
  private lazy var networkRequestDispathGroup = DispatchGroup()
  
  private weak var view: BookAnAppointmentView?
  
  init(viewType: BookAnAppointmentViewType) {
    self.viewType = viewType
    
    branches = BookAnAppointmentCellModel(title: "Select Location", placeholder: "Select Location", calloutType: .actionDown)
    treatment = BookAnAppointmentCellModel(title: "What are you looking for?", placeholder: "Select Treatment", calloutType: .action)
    addOns = BookAnAppointmentCellModel(title: "ADD-ONS", placeholder: "No Preference", calloutType: .add)
    therapists = BookAnAppointmentCellModel(title: "Select Therapist(s)", placeholder: "No Preference", calloutType: .add)
    prefferedDate = BookAnAppointmentCellModel(title: "Preferred Date", placeholder: "MM/DD/YY - MM/DD/YY", calloutType: .calendar)
    notes = BookAnAppointmentCellModel(title: "Add note", placeholder: "Enter a message", calloutType: .action)
    
    branches.actionDidTapped = { [weak self] in
      guard let `self` = self else { return }
      self.view?.selectBranches()
    }
    
    treatment.actionDidTapped = { [weak self] in
      guard let `self` = self else { return }
      self.loadAndSelectTreatmentsByLocation(locationID: self.branches.saveInfo as? String)
    }
    
    therapists.actionDidTapped = { [weak self] in
      guard let `self` = self else { return }
      if self.branches.saveInfo == nil {
        self.view?.showError("Please select a location first")
      } else if let treatmentID = self.treatment.saveInfo as? String {
        self.networkRequest.getAppointmentTherapistsByTreatment(treatmentID, addOnIDs: self.addOns.saveInfo as? String)
      } else {
        self.view?.showError("Please select a treatment first")
      }
    }
    
    therapists.didTriggerReload = { [weak self] in
      guard let `self` = self else { return }
      let therapistIDs = self.therapists.multiSelectedObjects.map({ $0.id })
      let selectedTherapists = self.treatmentTherapists.filter({ therapistIDs.contains($0.id!) })
      var therapistsLocations: [BAALocationModel] = []
      selectedTherapists.forEach { (therapistModel) in
        therapistModel.locations?.forEach { (locationModel) in
          if therapistsLocations.index(where: { $0.id == locationModel.id }) == nil {
            therapistsLocations.append(locationModel)
          }
        }
      }
      self.therapistLocations = therapistsLocations
      self.view?.reload()
    }
    
    addOns.actionDidTapped = { [weak self] in
      guard let `self` = self else { return }
      self.loadAndSelectAddons(locationID: self.branches.saveInfo as? String)
    }
    
    addOns.didTriggerReload = { [weak self] in
      guard let `self` = self else { return }
      self.view?.reload()
    }
    
    prefferedDate.actionDidTapped = { [weak self] in
      guard let `self` = self else { return }
      self.view?.selectPrefferedDate()
    }
    
    prefferedDate.didTriggerReload = { [weak self] in
      guard let `self` = self else { return }
      self.view?.reload()
    }
    
    notes.actionDidTapped = { [weak self] in
      guard let `self` = self else { return }
      self.view?.addNotes()
    }
    
    generateSections()
  }
  
  public var viewType: BookAnAppointmentViewType {
    didSet {
      view?.reload()
    }
  }
  
  public var treatmentViewModel: SelectTreatmentViewModel?
  
  public var branchList: [Location] {
    return CoreDataUtil.list(
      Location.self,
      predicate: .compoundAnd(
        predicates: [
          .isEqual(key: "isActive", value: true),
          .isEqual(key: "type", value: LocationType.appointment.rawValue)]),
      sorts: [.custom(key: "name", isAscending: true)])
  }
  
  public var branches: BookAnAppointmentCellModel
  
  public var treatmentTherapists: [BAATherapistModel] = [] {
    didSet {
      therapistLocations = []
    }
  }
  
  public var treatment: BookAnAppointmentCellModel
  
  public var therapists: BookAnAppointmentCellModel
  
  public var therapistLocations: [BAALocationModel] = []
  
  public var addOnList: [Addon] = []
  
  public var addOns: BookAnAppointmentCellModel
  
  public var prefferedDate: BookAnAppointmentCellModel
  
  public var notes: BookAnAppointmentCellModel
  
  public var shownSections: [BookAnAppointmentSection] = []
  
  public var actionTitle: String {
    return "CHECK AVAILABILITY".localized()
  }
  
  public var isActionEnabled: Bool {
    return prefferedDate.content != nil && treatment.content != nil && branches.saveInfo != nil
  }
}

extension BookAnAppointmentViewModel {
  private func loadAndSelectTreatmentsByLocation(locationID: String? = nil) {
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
      self.treatmentViewModel = SelectTreatmentViewModel(treatmentCategories: treatmentCategories)
    }, completion: { (_) in
      self.view?.selectTreatmentsByLocation()
    })
  }
  
  private func loadAndSelectAddons(locationID: String? = nil) {
    var previousAddonID: String?
    var predicates: [CoreDataRecipe.Predicate] = [
      .isEqual(key: "type", value: AddonType.appointment.rawValue),
      .isEqual(key: "isActive", value: true)]
    
    if let locationID = locationID {
      predicates.append(.isEqual(key: "location.id", value: locationID))
    }
    
    let addOnList = CoreDataUtil.list(
      Addon.self,
      predicate: .compoundAnd(predicates: predicates),
      sorts: [.custom(key: "name", isAscending: true)]).filter({ (addon) -> Bool in
        let isValid = previousAddonID != addon.id
        previousAddonID = addon.id
        return isValid
      })
    self.addOnList = addOnList
    self.view?.selectAddOnsByLocation()
  }
}

extension BookAnAppointmentViewModel {
  public func attachView(_ view: BookAnAppointmentView) {
    self.view = view
  }
  
  public func actionTapped() {
    guard let treatmentID = treatment.saveInfo as? String else { return }
    
    let locationIDs = branches.saveInfo as? String
    let therapistIDs = therapists.saveInfo as? String
    let minDate = prefferedDate.saveInfo as! Date
    let maxDate = minDate.dateByAdding(days: 7)
    let minDateString = minDate.toString(WithFormat: "yyyy-MM-dd")
    let maxDateString = maxDate.toString(WithFormat: "yyyy-MM-dd")
    networkRequest.getAppointmentAvailableSlotsByTreatment(treatmentID: treatmentID, locationsIDs: locationIDs, therapistIDs: therapistIDs, startDate: minDateString, endDate: maxDateString)
  }
  
  public func initializeContent() {
    view?.showLoading()//preload location, treatments and addons
    networkRequest.getAppointmentLocations()
    networkRequest.getAppointmentTreatments()
    networkRequest.getAppointmentAddons()
    networkRequestDispathGroup.notify(queue: .main) { [weak self] in
      guard let `self` = self else { return }
      self.view?.hideLoading()
    }
  }
}

// MARK: - PorcelainNetworkRequestDelegateProtocol
extension BookAnAppointmentViewModel: PorcelainNetworkRequestDelegateProtocol {
  internal func requestWillStart(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction) {
    guard let bookAppointmentRequestAction = action as? BookAppointmentRequestAction else { return }
    switch bookAppointmentRequestAction {
    case .getAppointmentLocations:
      networkRequestDispathGroup.enter()
    case .getAppointmentTreatments:
      networkRequestDispathGroup.enter()
    case .getAppointmentAddons:
      networkRequestDispathGroup.enter()
    case .getAppointmentTreatmentsByLocation:
      view?.showLoading()
    case .getAppointmentTherapistsByTreatment:
      view?.showLoading()
    case .getAppointmentAddonsByLocation:
      view?.showLoading()
    case .getAppointmentAvailableSlots:
      view?.showLoading()
    default:
      view?.showLoading()
    }
  }
  
  internal func requestDidFail(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction, error: Error?, statusCode: Int?, errorMessage: String?) {
    guard let bookAppointmentRequestAction = action as? BookAppointmentRequestAction else { return }
    switch bookAppointmentRequestAction {
    case .getAppointmentLocations:
      networkRequestDispathGroup.leave()
      view?.showError(errorMessage)
    case .getAppointmentTreatments:
      networkRequestDispathGroup.leave()
      view?.showError(errorMessage)
    case .getAppointmentAddons:
      networkRequestDispathGroup.leave()
      view?.showError(errorMessage)
    case .getAppointmentTreatmentsByLocation:
      view?.hideLoading()
      view?.showError(errorMessage)
    case .getAppointmentTherapistsByTreatment:
      view?.hideLoading()
      view?.showError(errorMessage)
    case .getAppointmentAddonsByLocation:
      view?.hideLoading()
      view?.showError(errorMessage)
    case .getAppointmentAvailableSlots:
      view?.hideLoading()
      view?.showError(errorMessage)
    default:
      view?.hideLoading()
      view?.showError(errorMessage)
    }
  }
  
  internal func requestSuccessful(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction, result: Any?) {
    guard let bookAppointmentRequestAction = action as? BookAppointmentRequestAction else { return }
    switch bookAppointmentRequestAction {
    case .getAppointmentLocations:
      CoreDataUtil.performBackgroundTask({ (moc) in
        Location.parseAppointmentLocations(result, inMOC: moc)
      }, completion: { (_) in
        self.networkRequestDispathGroup.leave()
      })
    case .getAppointmentTreatments:
      CoreDataUtil.performBackgroundTask({ (moc) in
        Treatment.parseAppointmentTreatmentsByLocation(result, inMOC: moc)
      }, completion: { (_) in
        self.networkRequestDispathGroup.leave()
      })
    case .getAppointmentAddons:
      CoreDataUtil.performBackgroundTask({ (moc) in
        Addon.parseAppointmentAddonsByLocation(result, inMOC: moc)
      }, completion: { (_) in
        self.networkRequestDispathGroup.leave()
      })
    case .getAppointmentTreatmentsByLocation(let locationID):
      view?.hideLoading()
      CoreDataUtil.performBackgroundTask({ (moc) in
        Treatment.parseAppointmentTreatmentsByLocation(result, inMOC: moc)
      }, completion: { (_) in
        self.view?.hideLoading()
        self.loadAndSelectTreatmentsByLocation(locationID: locationID)
      })
    case .getAppointmentTherapistsByTreatment:
      view?.hideLoading()
      treatmentTherapists = BAATherapistModel.parseTherapists(result, locationID: branches.saveInfo as? String)
      if treatmentTherapists.isEmpty {
        view?.showError("No therapists available")
      } else {
        view?.selectTherapistsByTreatment()
      }
    case .getAppointmentAddonsByLocation(let locationID):
      CoreDataUtil.performBackgroundTask({ (moc) in
        Addon.parseAppointmentAddonsByLocation(result, inMOC: moc)
      }, completion: { (_) in
        self.view?.hideLoading()
        self.loadAndSelectAddons(locationID: locationID)
      })
    case .getAppointmentAvailableSlots:
      let availableScheduleDates = AvailableScheduleDate.parseAvailableSchedule(result).filter { (availableScheduleDate) -> Bool in
        return availableScheduleDate.locations.contains(where: { !$0.therapists.isEmpty }) //filter out dates that don't show any therapist/s
      }
      view?.hideLoading()
      view?.checkAvailability(availableScheduleDates)
    default:
      view?.hideLoading()
    }
  }
}
