//
//  PastAppointmentsViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 29/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class PastAppointmentsViewController: UIViewController, RefreshHandlerProtocol, EmptyNotificationActionIndicatorProtocol {
  public var refreshControl: UIRefreshControl?
  
  public var refreshScrollView: UIScrollView?
  
  public var emptyNotificationActionView: EmptyNotificationActionView? {
    didSet {
      emptyNotificationActionView?.backgroundColor = .whiteFive
    }
  }
  
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 8.0, right: 0.0)
      tableView.setAutomaticDimension()
      tableView.registerWithNib(PastAppointmentsTCell.self)
      tableView.dataSource = self
      tableView.delegate = self
    }
  }
  
  public var emptyNotificationActionData: EmptyNotificationActionData? {
    didSet {
      if let emptyNotificationActionData = emptyNotificationActionData {
        showEmptyNotificationActionOnView(self.view, type: .centered(data: emptyNotificationActionData))
      } else {
        hideEmptyNotificationAction()
      }
    }
  }
  
  private lazy var frcHandler = FetchResultsControllerHandler<Appointment>(type: .tableView(tableView), sectionKey: "monthYear")
  
  private var estimatedHeightDict: [String: CGFloat] = [:]
  
  fileprivate var bookAnAppointment: RebookAppointmentCompletion?

  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  private func initialize() {
    if let customerID = AppUserDefaults.customerID {
      startRefreshing()
      PPAPIService.User.getMyAppointmentsPast().call { (response) in
        switch response {
        case .success(let result):
          CoreDataUtil.performBackgroundTask({ (moc) in
            guard let customer = User.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
            Appointment.parseAppointmentsFromData(result.data, customer: customer, type: .past, inMOC: moc)
          }, completion: { (_) in
            self.endRefreshing()
            if result.data.isEmpty {
              self.emptyNotificationActionData = EmptyNotificationActionData(
                title: "Uh oh! You don’t have any treatments yet.",
                subtitle: nil,
                action: "BOOK NOW")
            } else {
              self.reload()
              self.emptyNotificationActionData = nil
            }
          })
        case .failure(let error):
          self.emptyNotificationActionData = EmptyNotificationActionData(
            title: error.localizedDescription,
            subtitle: nil,
            action: "BOOK NOW")
          self.endRefreshing()
        }
      }
    } else {
      showEmptyNotificationActionOnView(
        view,
        type: .margin(data: EmptyNotificationActionData(
          title: "To continue and view your profile",
          subtitle: nil,
          action: "LOGIN")))
    }
  }
  
  private func reload() {
    if let customerID = AppUserDefaults.customerID {
      var recipe = CoreDataRecipe()
      recipe.sorts = [
        .custom(key: "monthYear", isAscending: false),
        .custom(key: "dateStart", isAscending: false)]
      let predicates: [CoreDataRecipe.Predicate] = [
        .notEqual(key: "monthYear", value: nil),
        .isEqual(key: "customer.id", value: customerID),
        .isEqual(key: "type", value: AppointmentType.past.rawValue)]
      recipe.predicate = CoreDataRecipe.Predicate.compoundAnd(predicates: predicates).rawValue
      frcHandler.reload(recipe: recipe)
    } else {
      tableView.reloadData()
    }
  }
  
  public func refreshControlDidRefresh(_ refreshControl: UIRefreshControl) {
    initialize()
  }
  
  public func emptyNotificationActionTapped(data: EmptyNotificationActionData) {
    if data.action == "BOOK NOW" {
      showBookAnAppointment()
    } else if data.action == "LOGIN" {
      appDelegate.mainView.showLogin {
        self.initialize()
      }
    }
  }
}

// MARK: - NavigationProtocol
extension PastAppointmentsViewController: NavigationProtocol {
}

// MARK: - BookAnAppointmentPresenterProtocol
extension PastAppointmentsViewController: BookAnAppointmentPresenterProtocol {
  public func bookAnAppointmentDidDismiss() {
  }
  
  public func bookAnAppointmentDidRequest() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.dismissViewController()
    }
  }
}

// MARK: - LeaveAFeedbackPresenterProtocol
extension PastAppointmentsViewController: LeaveAFeedbackPresenterProtocol {
}

// MARK: - ControllerProtocol
extension PastAppointmentsViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    return "showPastAppointments"
  }
  
  public func setupUI() {
    view.backgroundColor = .whiteFive
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: .icClose, selector: #selector(dismissViewController))
    reload()
    initialize()
  }
  
  public func setupObservers() {
    observeRefresh(scrollView: tableView)
  }
}

// MARK: - UITableViewDataSource
extension PastAppointmentsViewController: UITableViewDataSource {
  public func numberOfSections(in tableView: UITableView) -> Int {
    return frcHandler.sections?.count ?? 0
  }
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return frcHandler.numberOfObjectsInSection(section)
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let pastAppointmentsTCell = tableView.dequeueReusableCell(PastAppointmentsTCell.self, atIndexPath: indexPath)
    pastAppointmentsTCell.appointment = frcHandler.object(at: indexPath)
    pastAppointmentsTCell.rebookDidTapped = { [weak self] (appointment) in
      guard let `self` = self else { return }
      self.showBookAnAppointment(rebookData: RebookData(appointment: appointment))
    }
    pastAppointmentsTCell.leaveFeedbackDidTapped = { [weak self] (appointment) in
      guard let `self` = self else { return }
      self.showLeaveAFeedback(type: .appointment(appointment))
    }
    return pastAppointmentsTCell
  }
}

// MARK: - UITableViewDelegate
extension PastAppointmentsViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return estimatedHeightDict[concatenate(indexPath.row)] ?? PastAppointmentsTCell.defaultSize.height
  }
  
  public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    estimatedHeightDict[concatenate(indexPath.row)] = cell.contentView.bounds.height
  }
  
  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard frcHandler.numberOfObjectsInSection(section) > 0 else { return nil }
    let headerView = UIButton()
    headerView.isUserInteractionEnabled = false
    headerView.contentHorizontalAlignment = .left
    headerView.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
    headerView.backgroundColor = .whiteFive
    let title = frcHandler.object(at: IndexPath(row: 0, section: section)).monthYear?.toString(WithFormat: "MMMM yyyy")
    headerView.setAttributedTitle(title?.attributed.add([.color(.gunmetal), .font(.idealSans(style: .book(size: 16.0)))]), for: .normal)
    return headerView
  }
  
  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard frcHandler.numberOfObjectsInSection(section) > 0 else { return .leastNonzeroMagnitude }
    return 52.0
  }
}

public protocol PastAppointmentsPresenterProtocol {
}

extension PastAppointmentsPresenterProtocol where Self: ControllerProtocol & UIViewController {
  public func showPastAppointments(bookAppointmentCompletion: @escaping RebookAppointmentCompletion) {
    let pastAppointmentsViewController = UIStoryboard.get(.appointment).getController(PastAppointmentsViewController.self)
    pastAppointmentsViewController.bookAnAppointment = bookAppointmentCompletion
    let navigationController = NavigationController(rootViewController: pastAppointmentsViewController)
    if #available(iOS 13.0, *) {
      navigationController.isModalInPresentation = true
    }
    present(navigationController, animated: true) {
    }
  }
}
