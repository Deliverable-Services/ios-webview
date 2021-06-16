//
//  NotificationsViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 10/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class NotificationsViewController: UIViewController, RefreshHandlerProtocol, EmptyNotificationActionIndicatorProtocol {
  public var emptyNotificationActionView: EmptyNotificationActionView? {
    didSet {
      emptyNotificationActionView?.backgroundColor = .whiteFive
    }
  }
  
  public var refreshControl: UIRefreshControl?
  
  public var refreshScrollView: UIScrollView?
  
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.setAutomaticDimension()
      tableView.registerWithNib(NotificationsTCell.self)
      tableView.dataSource = self
      tableView.delegate = self
    }
  }
  
  private lazy var viewModel: NotificationsViewModelProtocol = NotificationsViewModel(view: self)
  
  private lazy var frcHandler = FetchResultsControllerHandler<AppNotification>(type: .tableView(tableView))
  private var estimatedHeightDict: [String: CGFloat] = [:]
  
  private var emptyNotificationActionData: EmptyNotificationActionData? {
    didSet {
      if let emptyNotificationActionData = emptyNotificationActionData {
        showEmptyNotificationActionOnView(view, type: .centered(data: emptyNotificationActionData))
      } else {
        hideEmptyNotificationAction()
      }
    }
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    NotificationCenter.default.post(name: .didReceiveNotification, object: nil)
  }
  
  public func refreshControlDidRefresh(_ refreshControl: UIRefreshControl) {
    viewModel.initialize()
  }
  
  public func emptyNotificationActionTapped(data: EmptyNotificationActionData) {
    viewModel.initialize()
  }
}

// MARK: - NavigationProtocol
extension NotificationsViewController: NavigationProtocol {
}

// MARK: - ControllerProtocol
extension NotificationsViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("NotificationsViewController segueIdentifier not set")
  }
  
  public func setupUI() {
    view.backgroundColor = .whiteFive
    tableView.backgroundColor = .whiteFive
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: .icTabHome, selector: #selector(popOrDismissViewController))
    viewModel.initialize()
  }
  
  public func setupObservers() {
    observeRefresh(scrollView: tableView)
  }
}

// MARK: - NotificationsView
extension NotificationsViewController: NotificationsView {
  public func reload() {
    frcHandler.reload(recipe: viewModel.notificationsRecipe)
  }
  
  public func showLoading() {
    startRefreshing()
  }
  
  public func hideLoading() {
    endRefreshing()
    emptyNotificationActionData = viewModel.emptyNotificationActionData
  }
  
  public func showError(message: String?) {
    showAlert(title: "Oops!", message: message)
  }
}

// MARK: - UITableViewDataSource
extension NotificationsViewController: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return frcHandler.numberOfObjectsInSection(section)
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let notificationsTCell = tableView.dequeueReusableCell(NotificationsTCell.self, atIndexPath: indexPath)
    notificationsTCell.notification  = frcHandler.object(at: indexPath)
    return notificationsTCell
  }
}

// MARK: - UITableViewDelegate
extension NotificationsViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let notification = frcHandler.object(at: indexPath)
    if let notificationID = notification.id, !notification.isRead {
      viewModel.markNotificationAsRead(notificationID: notificationID)
    }
    NotificationHandler.evaluateNotification(notification)
  }
  
  public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return estimatedHeightDict[concatenate(indexPath.row)] ?? PastAppointmentsTCell.defaultSize.height
  }
  
  public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    estimatedHeightDict[concatenate(indexPath.row)] = cell.contentView.bounds.height
  }
  
  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 24.0
  }
  
  public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 16.0
  }
}

public protocol NotificationsPresenterProtocol {
}

extension NotificationsPresenterProtocol where Self: ControllerProtocol & UIViewController {
  @discardableResult
  public func showNotifications(animated: Bool = true) -> NotificationsViewController {
    let notificationsViewController = UIStoryboard.get(.notification).getController(NotificationsViewController.self)
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(notificationsViewController, animated: animated)
    } else {
      let navigationController = NavigationController(rootViewController: notificationsViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
    return notificationsViewController
  }
}
