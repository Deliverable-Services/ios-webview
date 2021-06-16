//
//  SMTreatmentsViewController.swift
//  Porcelain
//
//  Created by Justine Rangel on 07/01/2019.
//  Copyright © 2019 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public protocol SMTreatmentsDelegate: class {
  func smTreatmentsViewTreatment(_ treatment: SMTreatmentData, beautyTips: BeautyTipsData?)
}

public final class SMTreatmentsViewController: UIViewController, ActivityIndicatorProtocol, EmptyNotificationActionIndicatorProtocol {
  public var emptyNotificationActionView: EmptyNotificationActionView?
  
  public var activityIndicatorView: UIActivityIndicatorView? {
    didSet {
      activityIndicatorView?.color = .gunmetal
      activityIndicatorView?.backgroundColor = .white
    }
  }
  
  public static var lastSelectionAppointmentID: String?
  public static var hasUpcomingAppointment: Bool?

  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.setAutomaticDimension()
      tableView.separatorColor = .whiteThree
      tableView.separatorStyle = .singleLine
      tableView.alwaysBounceVertical = false
      tableView.dataSource = self
      tableView.delegate = self
    }
  }
  
  private var emptyNotificationActionData: EmptyNotificationActionData? {
    didSet {
      if let emptyNotificationActionData = emptyNotificationActionData {
        showEmptyNotificationActionOnView(view, type: .centered(data: emptyNotificationActionData))
      } else {
        hideEmptyNotificationAction()
      }
    }
  }
  
  public var hasTreatments: Bool {
    return !viewModel.treatments.isEmpty
  }
  
  public var selectedAppointmentID: String? {
    return viewModel.selectedAppointmentID
  }
  
  fileprivate lazy var viewModel: ScanTreatmentViewModelProtocol = ScanTreatmentViewModel()
  
  public weak var delegate: SMTreatmentsDelegate?
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public func emptyNotificationActionTapped(data: EmptyNotificationActionData) {
    viewModel.initialize()
  }
}

// MARK: - ControllerProtocol
extension SMTreatmentsViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("SMTreatmentsViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    viewModel.attachView(self)
    viewModel.initialize()
  }
  
  public func setupObservers() {
  }
}

// MARK: - ScanTreatmentView
extension SMTreatmentsViewController: ScanTreatmentView {
  public func reload() {
    if !viewModel.treatments.isEmpty {
      tableView.isHidden = false
      tableView.reloadData()
      hideEmptyNotificationAction()
    } else {
      tableView.isHidden = true
      emptyNotificationActionData = EmptyNotificationActionData(
        title: "Nothing here yet.",
        subtitle: "You don’t have any recent treatments.",
        action: "RELOAD")
    }
  }
  
  public func showLoading() {
    showActivityOnView(view)
    if let activityIndicatorView = activityIndicatorView {
      view.bringSubview(toFront: activityIndicatorView)
    }
  }
  
  public func hideLoading() {
    hideActivity()
  }
  
  public func showError(message: String?) {
    tableView.isHidden = true
    emptyNotificationActionData = EmptyNotificationActionData(
      title: "Oops!",
      subtitle: message,
      action: "RELOAD")
  }
}

// MARK: - UITableViewDataSource
extension SMTreatmentsViewController: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.treatments.count
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let smTreatmentsCell = tableView.dequeueReusableCell(withIdentifier: "SMTreatmentsCell", for: indexPath)
    smTreatmentsCell.textLabel?.font = .idealSans(style: .light(size: 16.0))
    smTreatmentsCell.textLabel?.textColor = .gunmetal
    smTreatmentsCell.textLabel?.numberOfLines = 0
    smTreatmentsCell.textLabel?.text = viewModel.treatments[indexPath.row].name
    return smTreatmentsCell
  }
}

// MARK: - UITableViewDelegate
extension SMTreatmentsViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let treatment = viewModel.treatments[indexPath.row]
    delegate?.smTreatmentsViewTreatment(viewModel.treatments[indexPath.row], beautyTips: viewModel.beautyTips)
    viewModel.selectedAppointmentID = treatment.appointmentID
  }
  
  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let button = UIButton(frame: .zero)
    button.isUserInteractionEnabled = false
    button.contentHorizontalAlignment = .left
    button.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 10.0, right: 16.0)
    button.setAttributedTitle(
      "Select treatment to view".attributed.add([
        .color(.gunmetal),
        .font(.idealSans(style: .book(size: 18.0)))]),
      for: .normal)
    return button
  }
  
  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 56.0
  }
  
  public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return .leastNonzeroMagnitude
  }
}

public protocol SMTreatmentsPresenterProtocol {
}

extension SMTreatmentsPresenterProtocol where Self: ControllerProtocol & UIViewController {
  @discardableResult
  public func showSMTreatments(beatyTips: BeautyTipsData?, animated: Bool = true) -> SMTreatmentsViewController {
    let smTreatmentsViewController = UIStoryboard.get(.scanQR).getController(SMTreatmentsViewController.self)
    smTreatmentsViewController.viewModel.beautyTips = beatyTips
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(smTreatmentsViewController, animated: animated)
    } else {
      let navigationController = NavigationController(rootViewController: smTreatmentsViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
    return smTreatmentsViewController
  }
}
