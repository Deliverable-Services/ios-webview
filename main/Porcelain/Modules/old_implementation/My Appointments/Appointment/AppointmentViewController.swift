//
//  AppointmentViewController.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 03/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import UIKit
import Foundation
import LUExpandableTableView
import KRProgressHUD
import SwiftyJSON
import R4pidKit

private struct Constant {
  static let barTitle = "MY APPOINTMENTS".localized()
}

fileprivate enum SectionType: String {
  case upcomingAppointment = "Upcoming Appointments"
  case pendingApprovals = "Pending Approval from Porcelain"
  case treatmentPlan = "My Treatment Plan"
  
  static var count = 3

  func description() -> String {
    switch self {
    case .upcomingAppointment: return ""
    case .pendingApprovals: return "Booking requests that are waiting for Porcelain’s approval."
    case .treatmentPlan: return "Suggested treatments"
    }
  }
}

struct TreatmentPlanCellData {
  var treatmentPlan: CustomerTreatmentPlan
}

class AppointmentViewController: UIViewController {
  public static var segueIdentifier: String {
    return "showMyTreatment"
  }
  
  lazy var handler: MyAppointmentsHandler = {
    let handler = MyAppointmentsHandler()
    handler.delegate = self
    return handler
  }()
  
  var isFetching: Bool = false
  var upcomingAppointments: [AppointmentStruct] = []
  var appointmentRequests: [AppointmentStruct] = []
  var treatmentPlans: [TreatmentPlanCellData]?
  
  private var selectedAppointment: AppointmentStruct?
  
  @IBOutlet fileprivate  weak var tableView: LUExpandableTableView! {
    didSet { self.tableView.addSubview(self.refreshControl) }
  }
  
  lazy private var refreshControl: UIRefreshControl! = {
    let refreshControl = UIRefreshControl()
    refreshControl.tintColor = UIColor.Porcelain.blueGrey
    refreshControl.addTarget(self, action: #selector(AppointmentViewController.fetchFromNetwork), for: .valueChanged)
    return refreshControl
  }()
  
  fileprivate var sections: [SectionType] = [
    .upcomingAppointment,
    .pendingApprovals,
    .treatmentPlan
  ]
  
  // MARK: - Overriden methods
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setUpUI()
    self.reloadDatasource()
    self.fetchFromNetwork()
    self.registerForNotifications()
  }
  
  deinit {
    AppNotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Private methods
  private func registerForNotifications() {
    AppNotificationCenter.default
      .addObserver(self, selector: #selector(AppointmentViewController.reloadData),
                   name: AppNotificationNames.appointmentsDidChange, object: nil)
  }
  
  private func reloadDatasource() {
    upcomingAppointments = []
    appointmentRequests = []
    
    upcomingAppointments = Appointment.myUpcomingAppointments()
    appointmentRequests = Appointment.myRequestedAppointments()
    tableView.reloadData()
    toggleEmpty()
  }

  private func didFinishNetworkRequest() {
    DispatchQueue.main.async {
      self.reloadDatasource()
      self.endRefreshing()
      self.isFetching = false
    }
  }
  
  private func datasource(forSection section: Int) -> [AppointmentStruct] {
    if section == 0 { return upcomingAppointments }
    return appointmentRequests
  }
  
  private func toggleEmpty() {
    if upcomingAppointments.count == 0 {
      tableView.expandSections(at: [0])
    }
    if appointmentRequests.count == 0 {
      tableView.expandSections(at: [1])
    }
    if treatmentPlans?.count ?? 0 == 0 {
      tableView.expandSections(at: [2])
    }
  }
  
  private func setUpUI() {
    self.navigationController?.navigationBar.barTintColor = UIColor.Porcelain.whiteFour
    self.navigationController?.navigationBar.tintColor = UIColor.Porcelain.greyishBrown
    self.view.backgroundColor = UIColor.Porcelain.whiteTwo
    self.setUpTableViewUI()
    self.addBarButtonItems()
    
    let navLabel = UILabel()
    let navTitle: NSAttributedString = Constant.barTitle
      .withFont(UIFont.Porcelain.openSans(14.5, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.greyishBrown)
      .withKern(2)
    
    navLabel.attributedText = navTitle
    self.navigationItem.titleView = navLabel
  }
  
  private func setUpTableViewUI() {
    self.tableView.tableFooterView = UIView()
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = 200
    self.tableView.backgroundColor = UIColor.Porcelain.whiteTwo
    self.tableView.separatorInset = .zero
    self.tableView.separatorStyle = .none
    self.tableView.allowsSelection = true
    self.tableView.expandableTableViewDataSource = self
    self.tableView.expandableTableViewDelegate = self
    self.setupHeader()
    self.registerNib()
  }
  
  private func setupHeader() {
    let bookView = Bundle.main
      .loadNibNamed(BookAppointmentHeaderView.identifier,
                    owner: nil, options: nil)?.first as! BookAppointmentHeaderView
    bookView.configure { [weak self] in
      guard let `self` = self else { return }
      self.performSegue(withIdentifier: StoryboardIdentifier.toBookAppointment.rawValue, sender: nil)
    }
    self.tableView.tableHeaderView = bookView
  }
  
  private func registerNib() {
    let nibNames = [DefaultEmptyCell.identifier]
    
    for identifier in nibNames {
      let nib = UINib(nibName: identifier, bundle: nil)
      tableView.register(nib, forCellReuseIdentifier: identifier)
    }
    
    tableView.register(UINib(nibName: AppointmentsSectionHeader.identifier,
                             bundle: Bundle.main),
                       forHeaderFooterViewReuseIdentifier: AppointmentsSectionHeader.identifier)
  }
  
  private func addBarButtonItems() {
    let dashboardBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "home").withRenderingMode(.alwaysTemplate),
                                                 style: .plain, target: self,
                                                 action: #selector(AppointmentViewController.dismissVC))
    let historyBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "history").withRenderingMode(.alwaysTemplate),
                                               style: .plain, target: self,
                                               action: #selector(AppointmentViewController.goToTreatmentHistoryScreen))
    let layersBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "layers").withRenderingMode(.alwaysTemplate),
                                              style: .plain, target: self,
                                              action: #selector(AppointmentViewController.goToPackagesScreen))
    self.navigationItem.leftBarButtonItem = dashboardBarButtonItem
    self.navigationItem.rightBarButtonItems = [layersBarButtonItem, historyBarButtonItem]
  }
  
  private func emptyStr(type: SectionType) -> String {
    switch type {
    case .pendingApprovals: return "No pending approval requests".localized()
    case .upcomingAppointment: return "No appointments".localized()
    case .treatmentPlan: return "No treatment plan".localized()
    }
  }
  
  private func endRefreshing() {
    KRProgressHUD.hideHUD()
    if refreshControl.isRefreshing == true {
      refreshControl.endRefreshing()
    }
  }

  // MARK: - Action methods
  @objc func fetchFromNetwork() {
    if isFetching == false {
      handler.getAppointments()
      handler.getTreatmentPlan()
    }
  }
  
  @objc func reloadData() {
    reloadDatasource()
    fetchFromNetwork()
  }
}

// MARK: - ControllerProtocol
extension AppointmentViewController: ControllerProtocol {
  func setupUI() {
  }
  
  func setupController() {
  }
  
  func setupObservers() {
  }
}

// MARK: - EXTENSIONS
extension AppointmentViewController: LUExpandableTableViewDataSource {
  func expandableTableView(_ expandableTableView: LUExpandableTableView,
                           numberOfRowsInSection section: Int) -> Int {
    if section == 2 {
      return max(treatmentPlans?.count ?? 0, 1)
    }
    return max(datasource(forSection: section).count, 1)
  }

  func expandableTableView(_ expandableTableView: LUExpandableTableView,
                           cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let sectionType = sections[indexPath.section]
    
    guard (sectionType != .treatmentPlan && datasource(forSection: indexPath.section).count > 0) ||
      (sectionType == .treatmentPlan && treatmentPlans?.count ?? 0 > 0) else {
      let cell  = tableView.dequeueReusableCell(withIdentifier: DefaultEmptyCell.identifier)
        as! DefaultEmptyCell
      cell.configure(text: emptyStr(type: sectionType))
      return cell
    }
    
    switch sectionType {
    case .upcomingAppointment:
      let cell = tableView.dequeueReusableCell(withIdentifier: UpcomingAppointmentCell.identifier) as! UpcomingAppointmentCell
      let app = datasource(forSection: indexPath.section)
      cell.configure(app[indexPath.row])
      return cell
    case .pendingApprovals:
      let cell  = tableView.dequeueReusableCell(withIdentifier: AppointmentRequestCell.identifier) as! AppointmentRequestCell
      cell.configure(appointment: appointmentRequests[indexPath.row])
      cell.addTopPadding = indexPath.row == 0
      cell.addBottomPadding = indexPath.row == datasource(forSection: indexPath.section).count - 1
      
      var roundCorners: CACornerMask = []
      if indexPath.row == 0 {
        roundCorners.insert(.layerMaxXMinYCorner)
        roundCorners.insert(.layerMinXMinYCorner)
      }
      
      if indexPath.row == datasource(forSection: indexPath.section).count - 1 {
        roundCorners.insert(.layerMinXMaxYCorner)
        roundCorners.insert(.layerMaxXMaxYCorner)
      }

      cell.roundCorners = roundCorners
      cell.layoutIfNeeded()
      cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
      return cell
    case .treatmentPlan:
      let cell  = tableView.dequeueReusableCell(withIdentifier: CustomerTreatmentPlanCell.identifier) as! CustomerTreatmentPlanCell
      guard let data = treatmentPlans?[indexPath.row].treatmentPlan else { fatalError() }
      cell.configure(CustomerTreatmentPlanModel(customerTreatmentPlan: data))
      cell.addTopPadding = indexPath.row == 0
      cell.addBottomPadding = indexPath.row == (treatmentPlans?.count ?? 0) - 1
      cell.bookNowDidTapped = { [weak self] (treatmentID) in
        guard let `self` = self else { return }
        self.performSegue(withIdentifier: StoryboardIdentifier.toBookAppointment.rawValue, sender: treatmentID)
      }
      
      var roundCorners: CACornerMask = []
      if indexPath.row == 0 {
        roundCorners.insert(.layerMaxXMinYCorner)
        roundCorners.insert(.layerMinXMinYCorner)
      }
      
      if indexPath.row == (treatmentPlans?.count ?? 0) - 1 {
        roundCorners.insert(.layerMinXMaxYCorner)
        roundCorners.insert(.layerMaxXMaxYCorner)
      }
      
      cell.roundCorners = roundCorners
      cell.layoutIfNeeded()
      cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
      return cell
    }
  }
  
  func expandableTableView(_ expandableTableView: LUExpandableTableView,
                           sectionHeaderOfSection section: Int) -> LUExpandableTableViewSectionHeader {
    let sectionType = sections[section]
    guard let sectionHeader = expandableTableView
      .dequeueReusableHeaderFooterView(withIdentifier: AppointmentsSectionHeader.identifier)
      as? AppointmentsSectionHeader
      else {
      assertionFailure("Section header shouldn't be nil")
      return LUExpandableTableViewSectionHeader()
    }
    
    var toggable = datasource(forSection: section).count > 0
    if sectionType == .treatmentPlan {
      toggable = (treatmentPlans?.count ?? 0) > 0
    }
    sectionHeader.configure(sectionType.rawValue,
                            sectionType.description(), toggable: toggable)
    return sectionHeader
  }
  
  func numberOfSections(in expandableTableView: LUExpandableTableView) -> Int {
    return sections.count
  }
}

extension AppointmentViewController: LUExpandableTableViewDelegate {
  func expandableTableView(_ expandableTableView: LUExpandableTableView,
                           heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  func expandableTableView(_ expandableTableView: LUExpandableTableView,
                           heightForHeaderInSection section: Int) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  // MARK: Optional
  func expandableTableView(_ expandableTableView: LUExpandableTableView,
                           didSelectRowAt indexPath: IndexPath) {
    if sections[indexPath.section] != .treatmentPlan {
      selectedAppointment = datasource(forSection: indexPath.section)[indexPath.row]
      performSegue(withIdentifier: StoryboardIdentifier.toAppointmentItem.rawValue, sender: nil)
    }
  }
}

/****************************************************************/

private enum StoryboardIdentifier: String {
  case toTreatmentHistory = "AppointmentToTreatmentHistory"
  case toPackages = "AppointmentToPackages"
  case toAppointmentItem = "AppointmentToAppointmentItem"
  case toBookAppointment = "AppointmentToBookAppointment"
}

extension AppointmentViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = StoryboardIdentifier(rawValue: segue.identifier ?? "") else {
      return
    }
    var destinationVC: UIViewController? = segue.destination
    if let navigationVC = segue.destination as? UINavigationController {
      destinationVC = navigationVC.childViewControllers.first
    }
    
    switch identifier {
    case .toTreatmentHistory, .toPackages, .toBookAppointment:
      break
    case .toAppointmentItem:
      let vc = destinationVC as! MyAppointmentViewController
      vc.appointment = selectedAppointment!
      break
    }
    
    if let bookAppointmentViewController = destinationVC as? BookAppointmentViewController {
      if let treatmentID = sender as? String {
        bookAppointmentViewController.rebookData = ReBookAppointmentData(
          locationID: nil,
          treatmentID: treatmentID,
          therapistID: nil)
      }
    }
  }
  
  @objc func goToTreatmentHistoryScreen() {
    self.performSegue(withIdentifier: StoryboardIdentifier.toTreatmentHistory.rawValue, sender: nil)
  }
  
  @objc func goToPackagesScreen() {
    self.performSegue(withIdentifier: StoryboardIdentifier.toPackages.rawValue, sender: nil)
  }

  @objc func dismissVC() {
    if presentingViewController != nil ||
      (navigationController?.presentingViewController?.presentedViewController == navigationController) {
      dismissViewController()
    } else {
      popViewController()
    }
  }
}

/****************************************************************/
// MARK: - MyAppointmentsHandlerDelegate
extension AppointmentViewController: MyAppointmentsHandlerDelegate {
  func myAppointmentsHandlerWillStart(_ handler: MyAppointmentsHandler,
                                action: MyAppointmentsAction) {
    guard action == .getAppointments || action == .getTreatmentPlan else { return }
    isFetching = true
    KRProgressHUD.showHUD()
  }
  
  func myAppointmentsHandlerSuccessful(_ handler: MyAppointmentsHandler,
                                       action: MyAppointmentsAction,
                                       response: JSON) {
    switch action {
    case .getAppointments:
      didFinishNetworkRequest()
    case .getTreatmentPlan:
      saveTreatmentPlan(response)
      didFinishNetworkRequest()
    default:
      break
    }
  }
  
  func myAppointmentsHandlerDidFail(_ handler: MyAppointmentsHandler,
                                    action: MyAppointmentsAction,
                                    error: Error?,
                                    msg: String?) {
    guard action == .getAppointments || action == .getTreatmentPlan else { return }
    didFinishNetworkRequest()
    guard let message = msg else { return }
    displayAlert(title: "",
                 message: message,
                 handler: nil)
  }
  
  private func saveTreatmentPlan(_ jsonResult: JSON) {
    guard let jsonDict = jsonResult[0].dictionaryValue[PorcelainAPIConstant.Key.data]?.dictionaryValue else { return }
    
    treatmentPlans = []
    treatmentPlans?.append(contentsOf: jsonDict[PorcelainAPIConstant.Key.treatmentPlan]!.arrayValue
      .compactMap({ CustomerTreatmentPlan.from(json: $0) })
      .compactMap({ TreatmentPlanCellData(treatmentPlan: $0) }))
  }
}
