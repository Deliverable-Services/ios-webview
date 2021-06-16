//
//  PaymentMethodViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 2/26/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import SwiftyJSON
import Stripe

public struct PaymentMethod: Equatable {
  public var id: String
  public var title: String?
  public var description: String?
  public var image: UIImage?
  public var instructions: String?
  
  public init?(data: JSON) {
    guard let id = data.id.string else { return nil }
    self.id = id
    title = data.title.string
    description = data.description.string
    image = nil
    instructions = data.settings.instructions.value.string
  }
  
  public init(id: String) {
    self.id = id
  }
  
  public static let applePay: PaymentMethod = {
    var paymentMethod = PaymentMethod(id: "apple_pay")
    paymentMethod.image = .icApplePay
    return paymentMethod
  }()

  
  public static func parse(data: JSON) -> [PaymentMethod] {
    var paymentMethods = data.array?.compactMap({ PaymentMethod(data: $0) }) ?? []
    if Stripe.deviceSupportsApplePay() && AppConfiguration.enableApplePay {
      paymentMethods.append(PaymentMethod.applePay)
    }
    return paymentMethods
  }
  
  public static func == (lhs: PaymentMethod, rhs: PaymentMethod) -> Bool {
    return lhs.id == rhs.id
  }
}

public struct PaymentMethodData: Equatable {
  public let paymentMethod: PaymentMethod?
  public let card: Card?
  
  public static func == (lhs: PaymentMethodData, rhs: PaymentMethodData) -> Bool {
    return lhs.paymentMethod == rhs.paymentMethod && lhs.card == rhs.card
  }
}

public protocol PaymentMethodViewControllerDelegate: class {
  func paymentMethodViewControllerTitle(viewController: PaymentMethodViewController) -> String
  func paymentMethodViewControllerDidCancel(viewController: PaymentMethodViewController)
  func paymentMethodViewControllerDidSelect(viewController: PaymentMethodViewController, paymentMethod: PaymentMethodData, action: Bool)
  func paymentMethodViewControllerPaymentMethod(viewController: PaymentMethodViewController) -> PaymentMethodData
  func paymentMethodViewControllerShopCartNavigationTapped(viewController: PaymentMethodViewController)
  func paymentMethodViewContollerShopCartNavigationType(viewController: PaymentMethodViewController) -> ShopCartNavigationButton.AppearanceType?
}

public final class PaymentMethodViewController: UIViewController, RefreshHandlerProtocol, EmptyNotificationActionIndicatorProtocol {
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
      tableView.registerWithNib(PaymentMethodTCell.self)
      tableView.setAutomaticDimension()
      tableView.backgroundColor = .whiteFive
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
        showEmptyNotificationActionOnView(view, type: .centered(data: emptyNotificationActionData))
      } else {
        hideEmptyNotificationAction()
      }
    }
  }
  
  private var resetPaymentMethodID: String?
  private var selectedPaymentMethodID: String? {
    get {
      return R4pidDefaults.shared[.selectedPaymentMethodID]?.string
    }
    set {
      R4pidDefaults.shared[.selectedPaymentMethodID] = .init(value: newValue)
    }
  }
  
  private var paymentMethods: [PaymentMethod] = []
  private var selectedPaymentMethod: PaymentMethod? {
    didSet {
      selectedPaymentMethodID = selectedPaymentMethod?.id
    }
  }
  private var selectedCard: Card?
  
  public weak var delegate: PaymentMethodViewControllerDelegate? {
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
    if let resetPaymentMethodID = resetPaymentMethodID {
      selectedPaymentMethodID = resetPaymentMethodID
    }
    delegate?.paymentMethodViewControllerDidCancel(viewController: self)
    super.popOrDismissViewController()
  }
  
  public func initialize() {
    paymentMethods = []
    reload()
    startRefreshing()
    actionButton.setEnabled(false)
    PPAPIService.Checkout.getPaymentGateways().call { (response) in
      switch response {
      case .success(let result):
        self.paymentMethods = PaymentMethod.parse(data: result.data)
        if self.paymentMethods.isEmpty {
          self.emptyNotificationActionData = EmptyNotificationActionData(
            title: "No available payment methods",
            subtitle: nil,
            action: nil)
        } else {
          self.emptyNotificationActionData = nil
        }
        self.endRefreshing()
        self.reload()
        self.resetPaymentMethodID = self.selectedPaymentMethodID
      case .failure(let error):
        self.emptyNotificationActionData = EmptyNotificationActionData(
          title: error.localizedDescription,
          subtitle: nil,
          action: nil)
        self.endRefreshing()
      }
    }
  }
  
  public func reload() {
    title = delegate?.paymentMethodViewControllerTitle(viewController: self) ?? "PAYMENT METHOD"
    selectedCard = delegate?.paymentMethodViewControllerPaymentMethod(viewController: self).card
    if let appearanceType = delegate?.paymentMethodViewContollerShopCartNavigationType(viewController: self) {
      actionButton.type = appearanceType
    } else {
      actionButton.type = .default(title: "REVIEW ORDER", enabled: false)
    }
    tableView.reloadData()
    updateSelection()
  }
  
  private func updateSelection() {
    guard let selectedPaymentMethodID = selectedPaymentMethodID else { return }
    guard let row = paymentMethods.enumerated().filter({ $0.element.id == selectedPaymentMethodID }).first?.offset else { return }
    tableView.selectRow(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: .none)
    selectedPaymentMethod = paymentMethods[row]
    let paymentMethod = PaymentMethodData(paymentMethod: selectedPaymentMethod, card: selectedCard)
    delegate?.paymentMethodViewControllerDidSelect(viewController: self, paymentMethod: paymentMethod, action: false)
  }
  
  public func refreshControlDidRefresh(_ refreshControl: UIRefreshControl) {
    initialize()
  }
  
  public func emptyNotificationActionTapped(data: EmptyNotificationActionData) {
  }
  
  @IBAction private func actionTapped(_ sender: Any) {
    resetPaymentMethodID = nil
    delegate?.paymentMethodViewControllerShopCartNavigationTapped(viewController: self)
  }
}

// MARK: - NavigationProtocol
extension PaymentMethodViewController: NavigationProtocol {
}

// MARK: - CreditCardPresenterProtocol
extension PaymentMethodViewController: CreditCardPresenterProtocol {
}

// MARK: - ControllerProtocol
extension PaymentMethodViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("PaymentMethodViewController segueIdentifier not set")
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
extension PaymentMethodViewController: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return paymentMethods.count
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let paymentMethodTCell = tableView.dequeueReusableCell(PaymentMethodTCell.self, atIndexPath: indexPath)
    paymentMethodTCell.paymentMethod = paymentMethods[indexPath.row]
    paymentMethodTCell.card = selectedCard
    paymentMethodTCell.changeDidTapped = { [weak self] in
      guard let `self` = self else { return }
      self.showCreditCard(delegate: self)
    }
    return paymentMethodTCell
  }
}

// MARK: - UITableViewDelegate
extension PaymentMethodViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedPaymentMethod = paymentMethods[indexPath.row]
    if selectedPaymentMethod?.id == "stripe", selectedCard == nil {
      tableView.deselectRow(at: indexPath, animated: true)
      showCreditCard(delegate: self)
    } else {
      delegate?.paymentMethodViewControllerDidSelect(viewController: self, paymentMethod: PaymentMethodData(paymentMethod: selectedPaymentMethod, card: selectedCard), action: true)
    }
  }
  
  public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return .leastNonzeroMagnitude
  }
}

// MARK: - CreditCardViewControllerDelegate
extension PaymentMethodViewController: CreditCardViewControllerDelegate {
  public func creditCardViewControllerAllowsDelete(viewController: CreditCardViewController) -> Bool {
    return false
  }
  
  public func creditCardViewControllerAllowsSelection(viewController: CreditCardViewController) -> Bool {
    return true
  }
  
  public func creditCardViewControllerTitle(viewController: CreditCardViewController) -> String {
    return "SELECT CARD"
  }
  
  public func creditCardViewControllerDidSelect(viewController: CreditCardViewController, card: Card, action: Bool) {
    selectedCard = card
    delegate?.paymentMethodViewControllerDidSelect(viewController: self, paymentMethod: PaymentMethodData(paymentMethod: selectedPaymentMethod, card: selectedCard), action: action)
    if action {
      reload()
      viewController.popOrDismissViewController()
    }
  }
  
  public func creditCardViewControllerCard(viewController: CreditCardViewController) -> Card? {
    return selectedCard
  }
  
  public func creditCardViewControllerShopCartNavigationTapped(viewController: CreditCardViewController) {
  }
  
  public func creditCardViewControllerShopCartNavigationType(viewController: CreditCardViewController) -> ShopCartNavigationButton.AppearanceType? {
    return nil
  }
}

extension R4pidDefaultskey {
  fileprivate static let selectedPaymentMethodID = R4pidDefaultskey(value: "D6E3FE4OPZ8C45CF1F6419CB739FD34278074123\(AppUserDefaults.customerID ?? "")")
}

public protocol PaymentMethodPresenterProtocol {
}

extension PaymentMethodPresenterProtocol where Self: ControllerProtocol & UIViewController {
  public func showPaymentMethod(delegate: PaymentMethodViewControllerDelegate, animated: Bool = true) {
    let paymentMethodViewController = UIStoryboard.get(.cart).getController(PaymentMethodViewController.self)
    paymentMethodViewController.delegate = delegate
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(paymentMethodViewController, animated: animated)
    } else {
      let navigationController = NavigationController(rootViewController: paymentMethodViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
  }
  
  public func presentPaymentMethod(delegate: PaymentMethodViewControllerDelegate, animated: Bool = true) {
    let paymentMethodViewController = UIStoryboard.get(.cart).getController(PaymentMethodViewController.self)
    paymentMethodViewController.delegate = delegate
    let navigationController = NavigationController(rootViewController: paymentMethodViewController)
    navigationController.modalPresentationStyle = .fullScreen
    present(navigationController, animated: animated) {
    }
  }
}
