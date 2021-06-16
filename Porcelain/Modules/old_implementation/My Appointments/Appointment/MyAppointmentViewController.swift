//
//  MyAppointmentViewController.swift
//  Porcelain
//
//  Created by Jean on 6/29/18.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import KRProgressHUD
import R4pidKit

fileprivate enum AppointmentSection: Int {
  case name = 0
  case body
}

class MyAppointmentViewController: UIViewController, NavigationProtocol {
  static var identifier = String(describing: MyAppointmentViewController.self)
  var appointment: AppointmentStruct! {
    didSet {
      isSoon = (appointment.timeStart ?? Date()).timeIntervalSince(Date())/3600 < hoursThreshold
    }
  }
  @IBOutlet private var tableView: UITableView!
  @IBOutlet private var footerContainerView: UIView!
  @IBOutlet private var footerHeightConstraint: NSLayoutConstraint!
//  private var didInitFromNotif: Bool = false
  private var goToContactsBlock: (() -> Void)?
  private let hoursThreshold = 72.0
  private var isSoon = false
  private var footerView: MyAppointmentTableFooter?
  
  lazy var handler: MyAppointmentsHandler = {
    let handler = MyAppointmentsHandler()
    handler.delegate = self
    return handler
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initFooter()
    initTableView()
    initNavBar()
    initBlocks()
  }
  
  func initFromNotification(appointment app: AppointmentStruct) {
    appointment = app
//    didInitFromNotif = true
  }
  
  // MARK: Private methods
  private func initBlocks() {
    goToContactsBlock = { [weak self] () -> () in
      guard let strongSelf = self else { return }
      strongSelf.navigate(.toContactUs)
    }
  }
  
  private func title() -> String {
    let type = AppointmentType(rawValue: appointment.type)!
    switch type {
    case .confirmed: return "UPCOMING APPOINTMENT".localized()
    case .requested: return "APPOINTMENT REQUEST".localized()
    case .reserved: return "CONFIRM APPOINTMENT".localized()
    }
  }
  
  private func initNavBar() {
    navigationController?.navigationBar.tintColor = UIColor.Porcelain.greyishBrown
    if isBeingPresented == false {
      generateLeftNavigationButton(image: #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysOriginal), selector: #selector(popViewController))
    } else {
      navigationItem.leftBarButtonItem = UIBarButtonItem(
        image: #imageLiteral(resourceName: "ic-close").withRenderingMode(.alwaysOriginal),
        style: .plain,
        target: self,
        action: #selector(dismissSelf))
    }
    
    let navLabel = UILabel()
    let navTitle: NSAttributedString = title()
      .withFont(UIFont.Porcelain.openSans(14.5, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.greyishBrown)
      .withKern(2)
    
    navLabel.attributedText = navTitle
    self.navigationItem.titleView = navLabel
  }
  
  private func initTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.separatorStyle = .none
    tableView.allowsSelection = false
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.isScrollEnabled = false
  }
  
  private func initFooter(type: AppointmentType? = nil) {
    if footerView == nil {
    footerView = Bundle.main
      .loadNibNamed(MyAppointmentTableFooter.identifier, owner: self, options: nil)!
      .first as? MyAppointmentTableFooter
      footerContainerView.addSubview(footerView!)
    }

    let switchType = type ?? AppointmentType(rawValue: appointment.type)!
    switch (switchType, isSoon) {
    case (.requested, true):
      footerView?.isHidden = true
      footerHeightConstraint.constant = 0
    case (.requested, false):
      footerHeightConstraint.constant = 100
    case (.reserved, true):
      footerHeightConstraint.constant = 100
    case (.reserved, false):
      footerHeightConstraint.constant = 190
    case (.confirmed, _):
      footerView?.isHidden = true
      footerHeightConstraint.constant = 0
    }

    footerView?.frame = CGRect(origin: .zero, size: footerContainerView.frame.size)
    footerView?.configure(
    appointment: appointment,
    isSoon: isSoon) { [weak self] (appId, pType) in
      guard let strongSelf = self else { return }
      strongSelf.processCancelConfirm(appointment: strongSelf.appointment, type: pType)
    }
  }
  
  private func processCancelConfirm(appointment: AppointmentStruct, type: AppointmentProcessType?) {
    guard let pType = type else { return }
    switch pType {
    case .cancel:
      print("canceling appointment \(appointment.id) type \(appointment.type)")
      AlertViewController.loadAlertWithContent(
        "Your appointment will also be\nremoved from your calendar",
        buttons: [
          .action(title: "CANCEL", style: .cancel),
          .action(title: "OK", style: .confirm)]) { (choice) in
            if choice == "OK" {
              self.handler.cancelAppointment(appointmentID: appointment.id)
            }
        }.show(in: self)
    case .confirm:
      print("confirming appointment \(appointment.id) type \(appointment.type)")
      handler.confirmAppointment(appointmentID: appointment.id)
    }
  }
  
  private func didConfirm(message: String?) {
    AppNotificationCenter.default
      .post(name: AppNotificationNames.appointmentsDidChange, object: nil)
    reloadAsConfirmed()
    let content = "Thank you for confirming your appointment! We look forward to serving you."
    let btn = "Got it!"

    let str = message?.count == 0 ? content.localized() : message
    AlertViewController
      .loadAlertWithContent(str, actions: [btn.localized()])
      .show(in: self)
  }

  private func didCancel(message: String?) {
    guard let msg = message else { return }
    let btn = "Got it!"
    AlertViewController
      .loadAlertWithContent(msg.localized(), actions: [btn.localized()]) { [unowned self] (_) in
        self.dismissAppointment()
    }.show(in: self)
  }
  
  private func dismissAppointment() {
    AppNotificationCenter.default
      .post(name: AppNotificationNames.appointmentsDidChange, object: nil)
    DispatchQueue.main.async {
      if self.isBeingPresented { self.dismissSelf() }
      else { self.popViewController() }
    }
  }
  
  private func reloadAsConfirmed() {
    appointment.type = AppointmentType.confirmed.rawValue
    initFooter(type: AppointmentType.confirmed)
    tableView.reloadData()
  }

  // MARK: action methods
  @objc func dismissSelf() {
    dismissViewController()
  }
}

// MARK: - Tableview methods
extension MyAppointmentViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let appSection = AppointmentSection(rawValue: indexPath.row)
      else { fatalError("Invalid indexpath") }
    switch appSection {
    case .name:
      let cell = tableView.dequeueReusableCell(withIdentifier: MyAppointmentNameCell.identifier)
        as! MyAppointmentNameCell
      cell.configure(appointment: appointment, delegate: self)
      return cell
    case .body:
      let cell = tableView.dequeueReusableCell(withIdentifier: MyAppointmentCell.identifier)
        as! MyAppointmentCell
      cell.configure(appointment: appointment,
                     isSoon: isSoon,
                     contactUsBlock: goToContactsBlock)
      return cell
    }
  }
}

extension MyAppointmentViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView,
                 heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  func tableView(_ tableView: UITableView,
                 estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 200
  }
}

// MARK: - ControllerProtocol
extension MyAppointmentViewController: ControllerProtocol {
  static var segueIdentifier: String {
    fatalError("segueIdentifier not set")
  }
  
  func setupUI() {
  }
  
  func setupController() {
  }
  
  func setupObservers() {
  }
}

// MARK: - MyAppointmentNameCellDelegate
extension MyAppointmentViewController: MyAppointmentNameCellDelegate {
  func didAddToCalendar(appId: String) {
    guard appId == appointment.id else { return }
    initFooter()
    tableView.beginUpdates()
    tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
    tableView.endUpdates()
  }
}

// MARK: - MyAppointmentsHandlerDelegate
extension MyAppointmentViewController: MyAppointmentsHandlerDelegate {
  func myAppointmentsHandlerWillStart(_ handler: MyAppointmentsHandler,
                                      action: MyAppointmentsAction) {
    KRProgressHUD.showHUD()
  }
  
  func myAppointmentsHandlerSuccessful(_ handler: MyAppointmentsHandler,
                                       action: MyAppointmentsAction,
                                       response: JSON) {
    DispatchQueue.main.async { [weak self] in
      guard let strongSelf = self else { return }
      KRProgressHUD.hideHUD()
      switch action {
      case .cancelAppointment:
        print("response \(response)")
        CalendarEventUtil.searchEvent(query: strongSelf.appointment.id, completion: { (events) in
          events.forEach({ (event) in
            CalendarEventUtil.deleteEvent(event.eventIdentifier)
          })
        })
        strongSelf.didCancel(
          message: response.arrayValue[0].dictionary?[PorcelainAPIConstant.Key.message]?.string)
      case .confirmAppointment:
        let confirmMsg = response.arrayValue[0].dictionary?[PorcelainAPIConstant.Key.message]?.string
        strongSelf.didConfirm(message: confirmMsg)
      default: break
      }
    }
  }
  
  func myAppointmentsHandlerDidFail(_ handler: MyAppointmentsHandler,
                                    action: MyAppointmentsAction,
                                    error: Error?,
                                    msg: String?) {
    DispatchQueue.main.async { [weak self] in
      guard let strongSelf = self else { return }
      KRProgressHUD.hideHUD()
      guard let message = msg else { return }
      AlertViewController
        .loadAlertWithContent(message.localized(), actions: ["OK".localized()])
        .show(in: strongSelf)
    }
  }
}


// MARK: - Navigation
fileprivate enum StoryboardIdentifier: String {
  case toContactUs = "MyAppointmentToContactUs"
}

extension MyAppointmentViewController {
  fileprivate func navigate(_ identifier: StoryboardIdentifier) {
    DispatchQueue.main.async {
      self.performSegue(withIdentifier: identifier.rawValue, sender: nil)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = StoryboardIdentifier(rawValue: segue.identifier ?? "") else {
      return
    }
    var destinationVC: UIViewController? = segue.destination
    if let navigationVC = segue.destination as? UINavigationController {
      destinationVC = navigationVC.childViewControllers.first
    }
    
    switch identifier {
    case .toContactUs:
      let vc = destinationVC as? ContactUsViewController
      vc?.selectedBranch = appointment.branch()
    }
  }
}
