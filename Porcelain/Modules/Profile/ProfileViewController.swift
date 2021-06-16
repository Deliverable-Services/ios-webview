//
//  ProfileViewController.swift
//  Porcelain
//
//  Created by Jean on 6/16/18.
//  Copyright © 2018 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class ProfileViewController: UIViewController, RefreshHandlerProtocol, EmptyNotificationActionIndicatorProtocol {
  public var refreshControl: UIRefreshControl?
  
  public var refreshScrollView: UIScrollView?
  
  public var emptyNotificationActionView: EmptyNotificationActionView? {
    didSet {
      emptyNotificationActionView?.backgroundColor = .whiteFive
    }
  }
  
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.setAutomaticDimension()
      tableView.registerWithNib(ProfileMainCell.self)
      tableView.registerWithNib(ProfileItemCell.self)
      tableView.separatorInset = .zero
      tableView.separatorColor = .whiteThree
      tableView.dataSource = self
      tableView.delegate = self
    }
  }
  
  private var estimatedaHeightDict: [String: CGFloat] = [:]
  
  private lazy var cartBarButton = ShoppingCartBarButtonItem(image: .icCart, style: .plain, target: self, action: #selector(cartTapped(_:)))
  private lazy var settingsBarButton = BadgeableBarButtonItem(image: .icSettings, style: .plain, target: self, action: #selector(settingsTapped(_:)))
  
  private let viewModel: ProfileViewModelProtocol = ProfileViewModel()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    reload()
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    tableView.indexPathsForSelectedRows?.forEach { (indexPath) in
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
  
  public func refreshControlDidRefresh(_ refreshControl: UIRefreshControl) {
    viewModel.initialize()
  }
  
  public func emptyNotificationActionTapped(data: EmptyNotificationActionData) {
    appDelegate.mainView.showLogin {
      self.viewModel.initialize()
    }
  }
  
  @objc
  private func cartTapped(_ sender: Any) {
    showShopCart()
  }
  
  @objc
  private func settingsTapped(_ sender: Any) {
    showSettings()
  }
}

// MARK: - NavigationProtocol
extension ProfileViewController: NavigationProtocol {
}

// MARK: - SettingsPresenterProtocol
extension ProfileViewController: SettingsPresenterProtocol {
}

// MARK: - EditProfilePresenterProtocol
extension ProfileViewController: EditProfilePresenterProtocol {
}

// MARK: - PurchasePresenterProtocol
extension ProfileViewController: PurchasePresenterProtocol {
}

// MARK: - CreditCardPresenterProtocol
extension ProfileViewController: CreditCardPresenterProtocol {
}

// MARK: - AddressBookPresenterProtocol
extension ProfileViewController: AddressBookPresenterProtocol {
}

// MARK: - ShopCartPresenterProtocol
extension ProfileViewController: ShopCartPresenterProtocol {
}

// MARK: - ControllerProtocol
extension ProfileViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("ProfileViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    viewModel.attachView(self)
    viewModel.initialize()
  }
  
  public func setupObservers() {
    observeRefresh(scrollView: tableView)
  }
}

// MARK: - ProfileViews
extension ProfileViewController: ProfileView {
  public func reload() {
    if AppUserDefaults.isLoggedIn {
      tableView.isScrollEnabled = true
      generateRightNavigationButtons([settingsBarButton, cartBarButton])
      hideEmptyNotificationAction(animated: false)
    } else {
      tableView.isScrollEnabled = false
      generateRightNavigationButtons([cartBarButton])
      showEmptyNotificationActionOnView(
        view,
        type: .margin(data: EmptyNotificationActionData(
          title: "To continue and view your profile",
          subtitle: nil,
          action: "LOGIN")))
    }
    tableView.reloadData()
  }
  
  public func showLoading() {
  }
  
  public func hideLoading() {
    endRefreshing()
  }
  
  public func showError(message: String?) {
    showAlert(title: "Oops!", message: message)
  }
}

// MARK: - UITableViewDataSource
extension ProfileViewController: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if AppUserDefaults.isLoggedIn {
      return 1 + viewModel.profileItems.count
    } else {
      return 0
    }
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
      let profileMainCell = tableView.dequeueReusableCell(ProfileMainCell.self, atIndexPath: indexPath)
      profileMainCell.user = viewModel.customer
      profileMainCell.editDidTapped = { [weak self] in
        guard let `self` = self, let customer = self.viewModel.customer else { return }
        appDelegate.mainView.validateSession(loginCompletion: {
          self.showEditProfile(customer: customer)
        }) {
          self.showEditProfile(customer: customer)
        }
      }
      return profileMainCell
    } else {
      let profileItemCell = tableView.dequeueReusableCell(ProfileItemCell.self, atIndexPath: indexPath)
      profileItemCell.data = viewModel.profileItems[indexPath.row - 1]
      return profileItemCell
    }
  }
}

// MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard indexPath.row > 0 else { return }
    let profileItem = viewModel.profileItems[indexPath.row - 1]
    switch profileItem.title ?? "" {
    case "Credit | Debit Card":
      showCreditCard(delegate: self)
    case "Purchase History":
      showPurchases()
    case "Address Book":
      showAddressBook(delegate: self)
    default: break
    }
  }
  
  public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return estimatedaHeightDict[concatenate(indexPath.row)] ?? tableView.estimatedRowHeight
  }
  
  public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    estimatedaHeightDict[concatenate(indexPath.row)] = cell.contentView.bounds.height
  }
  
  public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return .leastNonzeroMagnitude
  }
}

// MARK: - CreditCardViewControllerDelegate
extension ProfileViewController: CreditCardViewControllerDelegate {
  public func creditCardViewControllerAllowsDelete(viewController: CreditCardViewController) -> Bool {
    return true
  }
  
  public func creditCardViewControllerAllowsSelection(viewController: CreditCardViewController) -> Bool {
    return false
  }
  
  public func creditCardViewControllerTitle(viewController: CreditCardViewController) -> String {
    return "CREDIT | DEBIT CARD"
  }
  
  public func creditCardViewControllerDidSelect(viewController: CreditCardViewController, card: Card, action: Bool) {
  }
  
  public func creditCardViewControllerCard(viewController: CreditCardViewController) -> Card? {
    return nil
  }
  
  public func creditCardViewControllerShopCartNavigationTapped(viewController: CreditCardViewController) {
  }
  
  public func creditCardViewControllerShopCartNavigationType(viewController: CreditCardViewController) -> ShopCartNavigationButton.AppearanceType? {
    return nil
  }
}

// MARK: - AddressBookViewControllerDelegate
extension ProfileViewController: AddressBookViewControllerDelegate {
  public func addressBookViewControllerAllowsDelete(viewController: AddressBookViewController) -> Bool {
    return true
  }
  
  public func addressBookViewControllerAllowsSelection(viewController: AddressBookViewController) -> Bool {
    return false
  }
  
  public func addressBookViewControllerTitle(viewController: AddressBookViewController) -> String {
    return "ADDRESS BOOK"
  }
  
  public func addressBookViewControllerTopHeaderPadding(viewController: AddressBookViewController) -> CGFloat {
    return 24.0
  }
  
  public func addressBookViewControllerDidCancel(viewController: AddressBookViewController) {
  }
  
  public func addressBookViewControllerDidSelect(viewController: AddressBookViewController, address: ShippingAddress, action: Bool) {
  }
  
  public func addressBookViewControllerSelectedAddress(viewController: AddressBookViewController) -> ShippingAddress? {
    return nil
  }

  public func addressBookViewControllerShopCartNavigationTapped(viewController: AddressBookViewController) {
  }
  
  public func addressBookViewControllerShopCartNavigationType(viewController: AddressBookViewController) -> ShopCartNavigationButton.AppearanceType? {
    return nil
  }
}

extension ProfileViewController {
  public func initialize() {
    viewModel.initialize()
  }
}
