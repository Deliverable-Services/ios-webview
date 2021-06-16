//
//  DashboardViewController.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 08/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import R4pidKit

private struct Constant {
  static let barTitle = "DASHBOARD".localized()
}

public class DashboardViewController: UIViewController {
  @IBOutlet fileprivate weak var collectionView: UICollectionView!
  @IBOutlet fileprivate var notificationsBarItem: BadgeBarButtonItem!
  @IBOutlet weak var syncNowView: UIView!
  
  private lazy var viewModel: DashboardViewModelProtocol = DashboardViewModel()
  
  var shouldShowSyncView: Bool = {
    let user = CoreDataUtil.get(
      User.self, predicate: .isEqual(key: "id", value: AppUserDefaults.customer?.id),
      inMOC: CoreDataUtil.mainMOC)
    return !(user?.isSynced ?? true)
  }()
  
  @IBAction func closeSyncViewButtonClicked(sender: UIButton) {
    self.isSyncNowViewHidden(true)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    if AppConfiguration.testSlackIntegration {
      self.isSyncNowViewHidden(false)
    } else if AppConfiguration.devLogin {
      self.isSyncNowViewHidden(true)
    } else {
      self.isSyncNowViewHidden(!shouldShowSyncView)
    }
    
    setup()
    addObservers()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    setNavigationTheme(.blue)
    setStatusBarNav(style: .lightContent)
    fetchNotifications()
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    setNavigationTheme(.white)
    setStatusBarNav(style: .default)
  }
  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    collectionView.collectionViewLayout.invalidateLayout()
  }

  @objc
  fileprivate func fetchNotifications() {
    viewModel.fetchNotifications()
  }

  @objc
  fileprivate func showProfile() {
    if !appDelegate.mainViewController.shouldLogin(reloadCompletion: { [weak self] in
      guard let `self` = self else { return }
      self.reloadData()
    }) {
      performSegue(withIdentifier: "showProfile", sender: nil)
    }
  }
  
  @objc
  private func showConversations() {
    if !appDelegate.mainViewController.shouldLogin(reloadCompletion: { [weak self] in
      guard let `self` = self else { return }
      self.reloadData()
    }) {
      appDelegate.freshChatShowConversations(in: self)
    }
  }
  
  @objc
  private func showContactUs() {
    performSegue(withIdentifier: "showContactUs", sender: nil)
  }
  
  @objc
  fileprivate func showNotifications() {
    if !appDelegate.mainViewController.shouldLogin(reloadCompletion: { [weak self] in
      guard let `self` = self else { return }
      self.reloadData()
    }) {
      self.performSegue(withIdentifier: StoryboardIdentifier.toNotifications.rawValue, sender: nil)
    }
  }
  
  @objc
  private func reloadData() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      self.collectionView.refreshControl?.endRefreshing()
      AppNotificationCenter.default.post(name: AppNotificationNames.appointmentsDidChange, object: nil)
      self.isSyncNowViewHidden(!self.shouldShowSyncView)
    }
  }

  @objc
  fileprivate func showUnreadIndicator() {
    DispatchQueue.main.async {
      self.notificationsBarItem.showUnreadIndicator = true
    }
  }

  private func hideUnreadIndicator() {
    DispatchQueue.main.async {
      self.notificationsBarItem.showUnreadIndicator = false
    }
  }
  
  private func isSyncNowViewHidden(_ isHidden: Bool) {
    UIView.animate(withDuration: 0.5) {
      self.syncNowView.isHidden = isHidden
    }

    UIView.animate(withDuration: 0.5) {
      self.view.layoutIfNeeded()
    }
  }

  @objc
  func updateUnreadNotifications() {
    guard let userID = AppUserDefaults.customer?.id else { return }
    guard AppNotification.unreadCount(ofUser: userID) > 0 else {
      hideUnreadIndicator()
      return
    }
    showUnreadIndicator()
  }
}

// MARK: - ControllerProtocol, NavigationProtocol
extension DashboardViewController: ControllerProtocol, NavigationProtocol {
  public static var segueIdentifier: String {
    return "showDashboard"
  }
  
  public func setupUI() {
    title = Constant.barTitle
    view.backgroundColor = UIColor.Porcelain.white
  }
  
  public func setupController() {
    notificationsBarItem.action = #selector(showNotifications)
    notificationsBarItem.target = self
    generateLeftNavigationButtons(
      [UIBarButtonItem(image: #imageLiteral(resourceName: "user").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(showProfile))])
    generateRightNavigationButtons(
      [/*UIBarButtonItem(image: #imageLiteral(resourceName: "chat-icon").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(showConversations)),*/
       notificationsBarItem])
    
    if collectionView.refreshControl == nil {
      collectionView.refreshControl = UIRefreshControl()
      collectionView.refreshControl?.tintColor = UIColor.Porcelain.blueGrey
      collectionView.refreshControl?.addTarget(self, action: #selector(reloadData), for: .valueChanged)
    }
  }
  
  private func addObservers() {
    AppNotificationCenter.default
      .addObserver(self, selector: #selector(DashboardViewController.reloadData),
                   name: AppNotificationNames.didSync, object: nil)

    AppNotificationCenter.default
      .addObserver(self, selector: #selector(DashboardViewController.updateUnreadNotifications),
                   name: AppNotificationNames.didUpdateNotifications, object: nil)

    AppNotificationCenter.default
      .addObserver(self, selector: #selector(DashboardViewController.fetchNotifications),
                   name: .UIApplicationDidBecomeActive,
                   object: nil)
  }
  public func setupObservers() {

  }
}

/****************************************************************/

private enum StoryboardIdentifier: String {
  case toSyncProfile = "DashboardToSyncProfile"
  case toNotifications = "DashboardToNotifications"
}

extension DashboardViewController {
  override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = StoryboardIdentifier(rawValue: segue.identifier ?? "") else {
      return
    }
    
    var destinationVC: UIViewController? = segue.destination
    if let navigationVC = segue.destination as? UINavigationController {
      destinationVC = navigationVC.childViewControllers.first
    }
    
    switch identifier {
    case .toSyncProfile:
      let vc = destinationVC as? SyncProfileViewController
      vc?.requestSubmitted = {
//        self.closeSyncViewButtonClicked(sender: UIButton())
      }
    case .toNotifications: break
    }
  }
}

// MARK: - UICollectionViewDataSource
extension DashboardViewController: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return DashboardSection.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch DashboardSection(rawValue: indexPath.row)! {
    case .bookAnAppointment:
      let bookAppointmentCell = collectionView.dequeueReusableCell(DashboardBookAnAppointmentCell.self, atIndexPath: indexPath)
      return bookAppointmentCell
    case .upcomingAppointments:
      let upcomingAppointmentsCell = collectionView.dequeueReusableCell(DashboardUpcomingAppointmentsCell.self, atIndexPath: indexPath)
      upcomingAppointmentsCell.configure(viewModel: DashboardUpcomingAppointmentsViewModel())
      upcomingAppointmentsCell.delegate = self
      return upcomingAppointmentsCell
    case .myAppointments:
      let myAppointmentsCell = collectionView.dequeueReusableCell(DashboardMyProductsCell.self, atIndexPath: indexPath)
      myAppointmentsCell.title = "MY\nAPPOINTMENTS"
      myAppointmentsCell.image = #imageLiteral(resourceName: "day15OnCalendar")
      return myAppointmentsCell
//      let myAppointmentsCell = collectionView.dequeueReusableCell(DashboardMyAppointmentsCell.self, atIndexPath: indexPath)
//      return myAppointmentsCell
    case .myProducts:
      let myProductsCell = collectionView.dequeueReusableCell(DashboardMyProductsCell.self, atIndexPath: indexPath)
      myProductsCell.title = "MY\nPRODUCTS"
      myProductsCell.image = #imageLiteral(resourceName: "my-products-icon")
      return myProductsCell
//    case .dailyLog:
//      let dailyLogCell = collectionView.dequeueReusableCell(DashboardDailyLogCell.self, atIndexPath: indexPath)
//      dailyLogCell.configure(viewModel: viewModel)
//      return dailyLogCell
    }
  }
}

// MARK: - UICollectionViewDelegate
extension DashboardViewController: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    switch DashboardSection(rawValue: indexPath.row)! {
    case .bookAnAppointment:
      if !appDelegate.mainViewController.shouldLogin(reloadCompletion: { [weak self] in
        guard let `self` = self else { return }
        self.reloadData()
      }) {
        performSegue(withIdentifier: BookAppointmentViewController.segueIdentifier, sender: nil)
      }
    case .upcomingAppointments:
      AlertViewController.loadAlertWithContent("Coming soon!", actions: ["OK".localized()]).show()
    case .myAppointments:
      if !appDelegate.mainViewController.shouldLogin(reloadCompletion: { [weak self] in
        guard let `self` = self else { return }
        self.reloadData()
      }) {
        performSegue(withIdentifier: AppointmentViewController.segueIdentifier, sender: nil)
      }
    case .myProducts:
      if !appDelegate.mainViewController.shouldLogin(reloadCompletion: { [weak self] in
        guard let `self` = self else { return }
        self.reloadData()
      }) {
//        performSegue(withIdentifier: MyProductsViewController.segueIdentifier, sender: nil)
      }
//    case .dailyLog: break
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DashboardViewController: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    switch DashboardSection(rawValue: indexPath.row)! {
    case .bookAnAppointment:
      return CGSize(width: collectionView.bounds.width - 32.0, height: DashboardBookAnAppointmentCell.defaultSize.height)
    case .upcomingAppointments:
      return CGSize(width: collectionView.bounds.width, height: DashboardUpcomingAppointmentsCell.defaultSize.height)
    case .myAppointments:
      return CGSize(width: (collectionView.bounds.width - 45.0)/2.0, height: DashboardMyProductsCell.defaultSize.height)
//      return CGSize(width: collectionView.bounds.width - 32.0, height: DashboardMyProductsCell.defaultSize.height)
    case .myProducts:
      return CGSize(width: (collectionView.bounds.width - 45.0)/2.0, height: DashboardMyProductsCell.defaultSize.height)
//    case .dailyLog:
//      return CGSize(width: (collectionView.bounds.width - 45.0)/2.0, height: DashboardDailyLogCell.defaultSize.height)
    }
  }
}

// MARK: - DashboardUpcomingAppointmentCellDelegate
extension DashboardViewController: DashboardUpcomingAppointmentsCellDelegate {
  public func displayError() {
    self.displayAlert(title: AppConstant.Text.defaultErrorTitle, message: AppConstant.Text.defaultErrorMessage, handler: nil)
  }
}
