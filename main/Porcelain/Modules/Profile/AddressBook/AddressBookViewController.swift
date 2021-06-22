//
//  AddressBookViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 19/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public protocol AddressBookViewControllerDelegate: class {
  func addressBookViewControllerAllowsDelete(viewController: AddressBookViewController) -> Bool
  func addressBookViewControllerAllowsSelection(viewController: AddressBookViewController) -> Bool
  func addressBookViewControllerTitle(viewController: AddressBookViewController) -> String
  func addressBookViewControllerTopHeaderPadding(viewController: AddressBookViewController) -> CGFloat
  func addressBookViewControllerDidCancel(viewController: AddressBookViewController)
  func addressBookViewControllerDidSelect(viewController: AddressBookViewController, address: ShippingAddress, action: Bool)
  func addressBookViewControllerSelectedAddress(viewController: AddressBookViewController) -> ShippingAddress?
  func addressBookViewControllerShopCartNavigationTapped(viewController: AddressBookViewController)
  func addressBookViewControllerShopCartNavigationType(viewController: AddressBookViewController) -> ShopCartNavigationButton.AppearanceType?
}

public final class AddressBookViewController: UIViewController, RefreshHandlerProtocol, EmptyNotificationActionIndicatorProtocol {
  public var refreshControl: UIRefreshControl?
  
  public var refreshScrollView: UIScrollView?
  
  public var emptyNotificationActionView: EmptyNotificationActionView? {
    didSet {
      emptyNotificationActionView?.backgroundColor = .whiteFive
      view.bringSubview(toFront: contentStack)
    }
  }
  @IBOutlet private weak var contentStack: UIStackView!
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.setAutomaticDimension()
      tableView.registerWithNib(ShippingAddressTCell.self)
      tableView.backgroundColor = .whiteFive
      tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 8.0, right: 0.0)
      tableView.dataSource = self
      tableView.delegate = self
    }
  }
  @IBOutlet private weak var headerView: UIView!
  @IBOutlet private weak var addNewAddressButton: DesignableButton! {
    didSet {
      addNewAddressButton.setAttributedTitle(
        UIImage.icAddShippingAddress.maskWithColor(.white).attributed.append(
          attrs: "  ADD NEW ADDRESS".attributed.add([
            .color(.white),
            .font(.idealSans(style: .book(size: 14.0))),
            .baseline(offset: 2.0)])),
        for: .normal)
      var appearance = ShadowAppearance.default
      appearance.fillColor = .lightNavy
      addNewAddressButton.shadowAppearance = appearance
    }
  }
  @IBOutlet private weak var bottomActionContainerView: UIView! {
    didSet {
      bottomActionContainerView.backgroundColor = .whiteFive
    }
  }
  @IBOutlet private weak var bottomActionButton: ShopCartNavigationButton!
  
  public var emptyNotificationActionData: EmptyNotificationActionData? {
    didSet {
      if let emptyNotificationActionData = emptyNotificationActionData {
        showEmptyNotificationActionOnView(view, type: .centered(data: emptyNotificationActionData))
      } else {
        hideEmptyNotificationAction()
      }
    }
  }
  
  private var allowsDelete: Bool = true
  
  private lazy var frcHandler = FetchResultsControllerHandler<ShippingAddress>(type: .tableView(tableView))
  private lazy var viewModel: AddressBookViewModelProtocol = AddressBookViewModel()
  
  public weak var delegate: AddressBookViewControllerDelegate? {
    didSet {
      guard isViewLoaded else { return }
      reload()
    }
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public func initialize() {
    viewModel.initialize()
  }
  
  public override func popOrDismissViewController() {
    delegate?.addressBookViewControllerDidCancel(viewController: self)
    super.popOrDismissViewController()
  }
  
  private func updateSelection() {
    guard tableView.allowsSelection else { return }
    if let selectedAddress = delegate?.addressBookViewControllerSelectedAddress(viewController: self) {
      guard let addresses = frcHandler.sections?[0].objects as? [ShippingAddress] else { return }
      guard let row = addresses.enumerated().filter({ $0.element == selectedAddress }).first?.offset else { return }
      tableView.selectRow(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: .none)
      delegate?.addressBookViewControllerDidSelect(viewController: self, address: addresses[row], action: false)
    } else {
      guard let addresses = frcHandler.sections?[0].objects as? [ShippingAddress] else { return }
      guard let row = addresses.enumerated().filter({ $0.element.primary }).first?.offset else { return }
      tableView.selectRow(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: .none)
      delegate?.addressBookViewControllerDidSelect(viewController: self, address: addresses[row], action: false)
    }
  }
  
  public func refreshControlDidRefresh(_ refreshControl: UIRefreshControl) {
    viewModel.initialize()
  }
  
  public func emptyNotificationActionTapped(data: EmptyNotificationActionData) {
  }
  
  @IBAction private func addNewAddressTapped(_ sender: Any) {
    showAddShippingAddress(type: .create)
  }
  
  @IBAction private func bottomActionTapped(_ sender: Any) {
    delegate?.addressBookViewControllerShopCartNavigationTapped(viewController: self)
  }
}

// MARK: - NavigationProtocol
extension AddressBookViewController: NavigationProtocol {
}

// MARK: - AddShippingAddressPresenterProtocol
extension AddressBookViewController: AddShippingAddressPresenterProtocol {
}

// MARK: - ControllerProtocol
extension AddressBookViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("AddressBookViewController segueIdentifier not set")
  }
  
  public func setupUI() {
    view.backgroundColor = .white
  }
  
  public func setupController() {
    if isPushed {
      generateLeftNavigationButton(image: .icLeftArrow, selector: #selector(popOrDismissViewController))
    } else {
      generateLeftNavigationButton(image: .icClose, selector: #selector(popOrDismissViewController))
    }
    viewModel.attachView(self)
    viewModel.initialize()
  }
  
  public func setupObservers() {
    observeRefresh(scrollView: tableView)
    frcHandler.delegate = self
  }
}

// MARK: - AddressBookView
extension AddressBookViewController: AddressBookView {
  public func reload() {
    title = delegate?.addressBookViewControllerTitle(viewController: self) ?? "ADDRESS BOOK"
    allowsDelete = delegate?.addressBookViewControllerAllowsDelete(viewController: self) ?? true
    tableView.allowsSelection = delegate?.addressBookViewControllerAllowsSelection(viewController: self) ?? false
    if let appearanceType = delegate?.addressBookViewControllerShopCartNavigationType(viewController: self) {
      bottomActionContainerView.isHidden = false
      bottomActionButton.type = appearanceType
    } else {
      bottomActionContainerView.isHidden = true
    }
    frcHandler.reload(recipe: viewModel.cardsRecipe)
    updateSelection()
  }
  
  public func showLoading() {
    if frcHandler.numberOfObjectsInSection(0) == 0 {
      startRefreshing()
    }
  }
  
  public func hideLoading() {
    emptyNotificationActionData = viewModel.emptyNotificationActionData
    endRefreshing()
  }
  
  public func showError(message: String?) {
    showAlert(title: "Oops!", message: message)
  }
}

// MARK: - UITableViewDataSource
extension AddressBookViewController: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return frcHandler.numberOfObjectsInSection(section)
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let shippingAddressTCell = tableView.dequeueReusableCell(ShippingAddressTCell.self, atIndexPath: indexPath)
    shippingAddressTCell.allowsDelete = allowsDelete
    shippingAddressTCell.allowsSelection = tableView.allowsSelection
    shippingAddressTCell.shippingAddress = frcHandler.object(at: indexPath)
    shippingAddressTCell.defaultDidTapped = { [weak self] (address) in
      guard let `self` = self else { return }
      self.viewModel.setAddressPrimary(address)
    }
    shippingAddressTCell.editDidTapped = { [weak self] (address) in
      guard let `self` = self else { return }
      self.showAddShippingAddress(type: .update(address: address))
    }
    shippingAddressTCell.deleteDidTapped = { [weak self] (address) in
      guard let `self` = self else { return }
      let handler = DialogHandler()
      handler.message = "You are about to delete your shipping address."
      handler.actions = [.cancel(title: "CANCEL"), .confirm(title: "PROCEED")]
      handler.actionCompletion = { [weak self] (action, dialogView) in
        dialogView.dismiss()
        guard let `self` = self else { return }
        if action.title == "PROCEED" {
          dialogView.dismiss()
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.viewModel.deleteAddress(address)
          }
        }
      }
      PresenterViewController.show(
        presentVC: DialogViewController.load(handler: handler),
        onVC: self)
    }
    return shippingAddressTCell
  }
}

// MARK: - UITableViewDelegate
extension AddressBookViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    delegate?.addressBookViewControllerDidSelect(viewController: self, address: frcHandler.object(at: indexPath), action: true)
    updateSelection()
  }
  
  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return headerView
  }
  
  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 80 + (delegate?.addressBookViewControllerTopHeaderPadding(viewController: self) ?? 24.0)
  }
}

// MARK: - FetchResultsControllerHandlerDelegate
extension AddressBookViewController: FetchResultsControllerHandlerDelegate {
  public func fetchResultsWillUpdateContent(hander: Any) {
  }
  
  public func fetchResultsDidUpdateContent(handler: Any) {
    updateSelection()
  }
}

public protocol AddressBookPresenterProtocol {
}

extension AddressBookPresenterProtocol where Self: ControllerProtocol & UIViewController {
  public func showAddressBook(delegate: AddressBookViewControllerDelegate, animated: Bool = true) {
    let addressBookViewController = UIStoryboard.get(.profile).getController(AddressBookViewController.self)
    addressBookViewController.delegate = delegate
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(addressBookViewController, animated: animated)
    } else {
      let navigationController = NavigationController(rootViewController: addressBookViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
  }
  
  public func presentAddressBook(delegate: AddressBookViewControllerDelegate, animated: Bool = true) {
    let addressBookViewController = UIStoryboard.get(.profile).getController(AddressBookViewController.self)
    addressBookViewController.delegate = delegate
    let navigationController = NavigationController(rootViewController: addressBookViewController)
    navigationController.modalPresentationStyle = .fullScreen
    present(navigationController, animated: animated) {
    }
  }
}
