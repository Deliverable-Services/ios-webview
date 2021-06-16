//
//  ShippingMethodViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 2/26/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import SwiftyJSON

public struct ShippingMethod: Equatable {
  public var id: String
  public var title: String?
  public var description: String?
  public var cost: Double
  
  public init?(data: JSON) {
    guard let methodID = data.methodID.string else { return nil }
    
    id = methodID
    if let cost = data.settings.cost.value.string?.toNumber().doubleValue {
      title = data.title.string
      self.cost = cost
    } else {
      title = data.title.string
      cost = 0
    }
    description = data.methodDescription.string?.cleanHTMLTags()
  }
  
  public static func parse(data: JSON) -> [ShippingMethod] {
    return data.array?.compactMap({ ShippingMethod(data: $0) }) ?? []
  }
  
  public static func == (lhs: ShippingMethod, rhs: ShippingMethod) -> Bool {
    return lhs.id == rhs.id
  }
}

public protocol ShippingMethodViewControllerDelegate: class {
  func shippingMethodViewControllerTitle(viewController: ShippingMethodViewController) -> String
  func shippingMethodViewControllerCartSalt(viewController: ShippingMethodViewController) -> CartSaltData?
  func shippingMethodViewControllerDidCancel(viewController: ShippingMethodViewController)
  func shippingMethodViewControllerDidSelect(viewController: ShippingMethodViewController, shippingMethod: ShippingMethod, action: Bool)
  func shippingMethodViewControllerShopCartNavigationTapped(viewController: ShippingMethodViewController)
  func shippingMethodViewControllerShopCartNavigationType(viewController: ShippingMethodViewController) -> ShopCartNavigationButton.AppearanceType?
}

public final class ShippingMethodViewController: UIViewController, RefreshHandlerProtocol, EmptyNotificationActionIndicatorProtocol {
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
      tableView.registerWithNib(ShippingMethodTCell.self)
      tableView.setAutomaticDimension()
      tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 32.0, bottom: 0.0, right: 32.0)
      tableView.separatorColor = .whiteThree
      tableView.dataSource = self
      tableView.delegate = self
    }
  }
  @IBOutlet private weak var actionContainerView: UIView! {
    didSet {
      actionContainerView.backgroundColor = .whiteFive
    }
  }
  @IBOutlet private weak var actionButton: ShopCartNavigationButton!
  
  public var emptyNotificationActionData: EmptyNotificationActionData? {
    didSet {
      if let emptyNotificationActionData = emptyNotificationActionData {
        tableView.backgroundColor = .clear
        showEmptyNotificationActionOnView(view, type: .centered(data: emptyNotificationActionData))
      } else {
        tableView.backgroundColor = .whiteFive
        hideEmptyNotificationAction()
      }
    }
  }
  
  private var resetShippingMethodID: String?
  private var selectedShippingMethodID: String? {
    get {
      return R4pidDefaults.shared[.selectedShippingMethodID]?.string
    }
    set {
      R4pidDefaults.shared[.selectedShippingMethodID] = .init(value: newValue)
    }
  }
  
  private var shippingMethods: [ShippingMethod] = []
  
  public weak var delegate: ShippingMethodViewControllerDelegate? {
    didSet {
      guard isViewLoaded else { return }
      reload()
    }
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func popOrDismissViewController() {
    if let resetShippingMethodID = resetShippingMethodID {
      selectedShippingMethodID = resetShippingMethodID
    }
    delegate?.shippingMethodViewControllerDidCancel(viewController: self)
    super.popOrDismissViewController()
  }
  
  public func initialize() {
    shippingMethods = []
    guard let cartSalt = delegate?.shippingMethodViewControllerCartSalt(viewController: self),
      let countryCode = cartSalt.countryCode,
      let realAmount = cartSalt.subTotal,
      let amount = cartSalt.total else {
        emptyNotificationActionData = EmptyNotificationActionData(
          title: "Country code and/or subtotal missing.",
          subtitle: nil,
          action: nil)
        reload()
      return
    }
    emptyNotificationActionData = nil
    reload()
    startRefreshing()
    actionButton.setEnabled(false)
    PPAPIService.Checkout.getShippingMethods(countryCode: countryCode, amount: String(format: "%f", amount), realAmounnt: String(format: "%f", realAmount), couponCode: cartSalt.coupon?.code).call { (response) in
      switch response {
      case .success(let result):
        self.shippingMethods = ShippingMethod.parse(data: result.data)
        if self.shippingMethods.isEmpty {
          self.emptyNotificationActionData = EmptyNotificationActionData(
            title: "No available shipping methods",
            subtitle: nil,
            action: nil)
        } else {
          self.emptyNotificationActionData = nil
        }
        self.endRefreshing()
        self.reload()
        self.resetShippingMethodID = self.selectedShippingMethodID
      case .failure(let error):
        self.emptyNotificationActionData = EmptyNotificationActionData(
          title: error.localizedDescription,
          subtitle: nil,
          action: nil)
        self.endRefreshing()
        self.reload()
      }
    }
  }
  
  public func reload() {
    title = delegate?.shippingMethodViewControllerTitle(viewController: self) ?? "SHIPPING METHOD"
    if let appearanceType = delegate?.shippingMethodViewControllerShopCartNavigationType(viewController: self) {
      actionButton.type = appearanceType
    } else {
      actionButton.type = .navigation(title: "PROCEED WITH PAYMENT", enabled: false)
    }
    tableView.reloadData()
    updateSelection()
  }
  
  private func updateSelection() {
    guard let selectedShippingMethodID = selectedShippingMethodID else { return }
    guard let row = shippingMethods.enumerated().filter({ $0.element.id == selectedShippingMethodID }).first?.offset else { return }
    tableView.selectRow(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: .none)
    delegate?.shippingMethodViewControllerDidSelect(viewController: self, shippingMethod: shippingMethods[row], action: false)
  }
  
  public func refreshControlDidRefresh(_ refreshControl: UIRefreshControl) {
    initialize()
  }
  
  public func emptyNotificationActionTapped(data: EmptyNotificationActionData) {
  }
  
  @IBAction private func actionTapped(_ sender: Any) {
    resetShippingMethodID = nil
    delegate?.shippingMethodViewControllerShopCartNavigationTapped(viewController: self)
  }
}

// MARK: - NavigationProtocol
extension ShippingMethodViewController: NavigationProtocol {
}

// MARK: - ControllerProtocol
extension ShippingMethodViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("ShippingMethodViewController segueIdentifier not set")
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
    initialize()
  }
  
  public func setupObservers() {
    observeRefresh(scrollView: tableView)
  }
}

// MARK: - UITableViewDataSource
extension ShippingMethodViewController: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return shippingMethods.count
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let shippingMethodTCell = tableView.dequeueReusableCell(ShippingMethodTCell.self, atIndexPath: indexPath)
    shippingMethodTCell.shippingMethod = shippingMethods[indexPath.row]
    return shippingMethodTCell
  }
}

// MARK: - UITableViewDelegate
extension ShippingMethodViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedShippingMethodID = shippingMethods[indexPath.row].id
    delegate?.shippingMethodViewControllerDidSelect(viewController: self, shippingMethod: shippingMethods[indexPath.row], action: true)
  }
  
  public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return .leastNonzeroMagnitude
  }
}

extension R4pidDefaultskey {
  fileprivate static let selectedShippingMethodID = R4pidDefaultskey(value: "FE4OPZ8C4123CB739F45CD6E3F1F6419D3427807\(AppUserDefaults.customerID ?? "")")
}

public protocol ShippingMethodPresenterProtocol {
}

extension ShippingMethodPresenterProtocol where Self: ControllerProtocol & UIViewController {
  public func showShippingMethod(delegate: ShippingMethodViewControllerDelegate, animated: Bool = true) {
    let shippingMethodViewController = UIStoryboard.get(.cart).getController(ShippingMethodViewController.self)
    shippingMethodViewController.delegate = delegate
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(shippingMethodViewController, animated: animated)
    } else {
      let navigationController = NavigationController(rootViewController: shippingMethodViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
  }
  
  public func presentShippingMethod(delegate: ShippingMethodViewControllerDelegate, animated: Bool = true) {
    let shippingMethodViewController = UIStoryboard.get(.cart).getController(ShippingMethodViewController.self)
    shippingMethodViewController.delegate = delegate
    let navigationController = NavigationController(rootViewController: shippingMethodViewController)
    navigationController.modalPresentationStyle = .fullScreen
    present(navigationController, animated: animated) {
    }
  }
}
