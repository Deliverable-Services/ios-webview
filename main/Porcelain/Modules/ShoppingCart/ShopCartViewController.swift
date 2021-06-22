//
//  ShopCartViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 2/24/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import Stripe

public enum ShopShippingAddressType {
  case `default`
  case shopCart
}

public final class ShopCartViewController: UIViewController, EmptyNotificationActionIndicatorProtocol {
  public var emptyNotificationActionView: EmptyNotificationActionView? {
    didSet {
      emptyNotificationActionView?.backgroundColor = .whiteFive
    }
  }
  @IBOutlet private weak var contentStack: UIStackView!
  @IBOutlet private weak var cartProgressView: CartProgressView! {
    didSet {
      cartProgressView.backgroundColor = .whiteFive
    }
  }
  @IBOutlet private weak var contentScrollView: UIScrollView! {
    didSet {
      contentScrollView.backgroundColor = .whiteFive
    }
  }
  
  private var cartViewController: CartViewController? {
    return getChildController(CartViewController.self)
  }
  private var shippingAddressViewController: AddressBookViewController? {
    return getChildController(AddressBookViewController.self)
  }
  private var shippingMethodViewController: ShippingMethodViewController? {
    return getChildController(ShippingMethodViewController.self)
  }
  private var paymentMethodViewController: PaymentMethodViewController? {
    return getChildController(PaymentMethodViewController.self)
  }
  private var reviewOrderViewController: ReviewOrderViewController? {
    return getChildController(ReviewOrderViewController.self)
  }
  
  public var emptyNotificationActionData: EmptyNotificationActionData? {
    didSet {
      if let emptyNotificationActionData = emptyNotificationActionData {
        showEmptyNotificationActionOnView(view, type: .centered(data: emptyNotificationActionData))
      } else {
        hideEmptyNotificationAction()
      }
    }
  }
  
  private var cachedPKPaymentAuthVC: PKPaymentAuthorizationViewController?
  
  private lazy var viewModel: ShopCartViewModelProtocol = ShopCartViewModel()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    setStatusBarNav(style: .default)
    hideBarSeparator()
    SimpleNotificationView.hideIDs(SimpleNotificationView.Cart.ids)
  }
  
  public override func popOrDismissViewController() {
    if ShopCartSection(rawValue: viewModel.section.rawValue - 1) != nil {
      viewModel.prevPage()
    } else {
      super.popOrDismissViewController()
    }
  }
  
  public func emptyNotificationActionTapped(data: EmptyNotificationActionData) {
    if let navigationController = navigationController as? NavigationController {
      navigationController.popToRootViewController(animated: true)
    } else {
      dismiss(animated: true) {
      }
    }
    appDelegate.mainView.goToTab(.shop)?.getChildController(ShopViewController.self)?.showSection(.products)
  }
}

// MARK: - NavigationProtocol
extension ShopCartViewController: NavigationProtocol {
}

// MARK: - ControllerProtocol
extension ShopCartViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("ShopCartViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: .icLeftArrow, selector: #selector(popOrDismissViewController))
    viewModel.attachView(view: self)
    viewModel.initialize()
  }
  
  public func setupObservers() {
    cartProgressView.didUpdateSection = { [weak self] in
      guard let `self` = self else { return }
      self.viewModel.section = self.cartProgressView.section
      self.reload()
    }
    cartViewController?.delegate = self
    shippingAddressViewController?.delegate = self
    shippingMethodViewController?.delegate = self
    paymentMethodViewController?.delegate = self
    reviewOrderViewController?.delegate = self
  }
}

// MARK: - ShopCartView
extension ShopCartViewController: ShopCartView {
  public func reload() {
    navigationItem.title = viewModel.section.title
    if viewModel.cartItems.isEmpty {
      contentStack.isHidden = true
      emptyNotificationActionData = EmptyNotificationActionData(
        title: "Your shopping cart is empty.",
        subtitle: nil,
        action: "GO TO PRODUCTS")
    } else {
      contentStack.isHidden = false
      emptyNotificationActionData = nil
      cartProgressView.section = viewModel.section
      contentScrollView.setContentOffset(CGPoint(x: contentScrollView.bounds.width * CGFloat(viewModel.section.rawValue), y: 0.0), animated: true)
      switch viewModel.section {
      case .cart:
        cartViewController?.reload()
      case .shippingAddress:
        shippingAddressViewController?.reload()
      case .shippingMethod:
        viewModel.shippingMethod = nil
        shippingMethodViewController?.initialize()
      case .paymentMethod:
        paymentMethodViewController?.reload()
      case .reviewOrder:
        reviewOrderViewController?.reload()
      }
    }
  }
  
  public func showLoading() {
    appDelegate.showLoading()
  }
  
  public func hideLoading() {
    appDelegate.hideLoading()
  }
  
  public func showError(message: String?) {
    if let cachedPKPaymentAuthVC = cachedPKPaymentAuthVC {
      cachedPKPaymentAuthVC.dismiss(animated: true) { [weak self] in
        guard let `self` = self else { return }
        self.showAlert(title: "Oops!", message: message)
        self.cachedPKPaymentAuthVC = nil
      }
    } else {
      showAlert(title: "Oops!", message: message)
    }
  }
  
  public func showApplePayAuth(paymentRequest: PKPaymentRequest) {
    guard let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) else {
      showError(message: "This device is restricted from making payments.")
      return
    }
    showLoading()
    paymentAuthorizationViewController.delegate = self
    cachedPKPaymentAuthVC = paymentAuthorizationViewController
    present(paymentAuthorizationViewController, animated: true) { [weak self] in
      guard let `self` = self else { return }
      self.hideLoading()
    }
  }
  
  public func showSuccess() {
    if let cachedPKPaymentAuthVC = cachedPKPaymentAuthVC {
      cachedPKPaymentAuthVC.dismiss(animated: true) { [weak self] in
        guard let `self` = self else { return }
        self.showCheckoutSuccess()
        self.cachedPKPaymentAuthVC = nil
      }
    } else {
      if viewModel.orderReceivedData != nil {
        presentOrderReceived()
      } else {
        showCheckoutSuccess()
      }
    }
  }
}

// MARK: PKPaymentAuthorizationControllerDelegate
extension ShopCartViewController: PKPaymentAuthorizationViewControllerDelegate {
  public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
    viewModel.validateApplePayWithCompletion(payment: payment, completion: completion)
  }
  
  public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
    controller.dismiss(animated: true) { [weak self] in
      guard let `self` = self else { return }
      self.cachedPKPaymentAuthVC = nil
    }
  }
}

// MARK: - CartViewControllerDelegate
extension ShopCartViewController: CartViewControllerDelegate {
  public func cartViewControlletRemoveAddAllContents(viewController: CartViewController) {
    if viewModel.cartItems.isEmpty {
      contentStack.isHidden = true
      emptyNotificationActionData = EmptyNotificationActionData(
        title: "Your shopping cart is empty.",
        subtitle: nil,
        action: "GO TO PRODUCTS")
    } else {
      contentStack.isHidden = false
      emptyNotificationActionData = nil
    }
  }
  
  public func cartViewControllerCartItems(viewController: CartViewController) -> [ShoppingCartItem] {
    return viewModel.cartItems
  }
  
  public func cartViewControllerDidSelectCoupon(viewController: CartViewController, coupon: ShoppingCoupon?) {
    viewModel.coupon = coupon
  }
  
  public func cartViewControllerCoupon(viewController: CartViewController) -> ShoppingCoupon? {
    return viewModel.coupon
  }
  
  public func cartViewControllerShopCartNavigationTapped(viewController: CartViewController) {
    if AppUserDefaults.isLoggedIn {
      viewModel.nextPage()
    } else {
      appDelegate.mainView.validateSession(loginCompletion: {
        self.shippingAddressViewController?.initialize()
        self.shippingMethodViewController?.initialize()
        self.paymentMethodViewController?.initialize()
        self.viewModel.nextPage()
      }, validCompletion: {
        self.shippingAddressViewController?.initialize()
        self.shippingMethodViewController?.initialize()
        self.paymentMethodViewController?.initialize()
        self.viewModel.nextPage()
      })
    }
  }
  
  public func cartViewControllerShopCartNavigationType(viewController: CartViewController) -> ShopCartNavigationButton.AppearanceType? {
    return .navigation(title: "CHOOSE SHIPPING ADDRESS", enabled: !viewModel.cartItems.isEmpty)
  }
}

// MARK: - AddressBookViewControllerDelegate/ Shipping Address Delegate
extension ShopCartViewController: AddressBookViewControllerDelegate {
  public func addressBookViewControllerAllowsDelete(viewController: AddressBookViewController) -> Bool {
    return false
  }
  
  public func addressBookViewControllerAllowsSelection(viewController: AddressBookViewController) -> Bool {
    return true
  }
  
  public func addressBookViewControllerTitle(viewController: AddressBookViewController) -> String {
    return ""
  }
  
  public func addressBookViewControllerTopHeaderPadding(viewController: AddressBookViewController) -> CGFloat {
    return 0.0
  }
  
  public func addressBookViewControllerDidCancel(viewController: AddressBookViewController) {
  }
  
  public func addressBookViewControllerDidSelect(viewController: AddressBookViewController, address: ShippingAddress, action: Bool) {
    let canReload = viewModel.shippingAddress != address
    viewModel.shippingAddress = address
    if canReload {
      shippingAddressViewController?.reload()
    }
  }
  
  public func addressBookViewControllerSelectedAddress(viewController: AddressBookViewController) -> ShippingAddress? {
    return viewModel.shippingAddress
  }
  
  public func addressBookViewControllerShopCartNavigationTapped(viewController: AddressBookViewController) {
    viewModel.nextPage()
  }
  
  public func addressBookViewControllerShopCartNavigationType(viewController: AddressBookViewController) -> ShopCartNavigationButton.AppearanceType? {
    return .navigation(title: "CHOOSE SHIPPING METHOD", enabled: viewModel.shippingAddress != nil)
  }
}

// MARK: - ShippingMethodViewControllerDelegate
extension ShopCartViewController: ShippingMethodViewControllerDelegate {
  public func shippingMethodViewControllerTitle(viewController: ShippingMethodViewController) -> String {
    return ""
  }
  
  public func shippingMethodViewControllerCartSalt(viewController: ShippingMethodViewController) -> CartSaltData? {
    return viewModel.cartSalt
  }
  
  public func shippingMethodViewControllerDidCancel(viewController: ShippingMethodViewController) {
  }
  
  public func shippingMethodViewControllerDidSelect(viewController: ShippingMethodViewController, shippingMethod: ShippingMethod, action: Bool) {
    let canReload = viewModel.shippingMethod != shippingMethod
    viewModel.shippingMethod = shippingMethod
    if canReload {
      viewController.reload()
    }
  }
  
  public func shippingMethodViewControllerShopCartNavigationTapped(viewController: ShippingMethodViewController) {
    viewModel.nextPage()
  }
  
  public func shippingMethodViewControllerShopCartNavigationType(viewController: ShippingMethodViewController) -> ShopCartNavigationButton.AppearanceType? {
    return .navigation(title: "PROCEED WITH PAYMENT", enabled: viewModel.shippingMethod != nil)
  }
}

// MARK: - PaymentMethodViewControllerDelegate
extension ShopCartViewController: PaymentMethodViewControllerDelegate {
  public func paymentMethodViewControllerTitle(viewController: PaymentMethodViewController) -> String {
    return ""
  }
  
  public func paymentMethodViewControllerDidCancel(viewController: PaymentMethodViewController) {
  }
  
  public func paymentMethodViewControllerDidSelect(viewController: PaymentMethodViewController, paymentMethod: PaymentMethodData, action: Bool) {
    let _paymentMethod = paymentMethod.paymentMethod
    let canReload = viewModel.paymentMethod != _paymentMethod
    viewModel.paymentMethod = _paymentMethod
    viewModel.card = paymentMethod.card
    if canReload {
      viewController.reload()
    }
  }
  
  public func paymentMethodViewControllerPaymentMethod(viewController: PaymentMethodViewController) -> PaymentMethodData {
    return PaymentMethodData(paymentMethod: viewModel.paymentMethod, card: viewModel.card)
  }
  
  public func paymentMethodViewControllerShopCartNavigationTapped(viewController: PaymentMethodViewController) {
    viewModel.nextPage()
  }
  
  public func paymentMethodViewContollerShopCartNavigationType(viewController: PaymentMethodViewController) -> ShopCartNavigationButton.AppearanceType? {
    var isEnabled = viewModel.paymentMethod != nil
    if viewModel.paymentMethod?.id == "stripe" {
      isEnabled = viewModel.card != nil
    }
    return .default(title: "REVIEW ORDER", enabled: isEnabled)
  }
}

// MARK: - ReviewOrderViewControllerDelegate
extension ShopCartViewController: ReviewOrderViewControllerDelegate {
  public func reviewOrderViewControllerCartItems(viewController: ReviewOrderViewController) -> [ShoppingCartItem] {
    return viewModel.cartItems
  }
  
  public func reviewOrderViewControllerCartSalt(viewController: ReviewOrderViewController) -> CartSaltData? {
    return viewModel.cartSalt
  }
  
  public func reviewOrderViewControllerDidSelectShippingAddress(viewController: ReviewOrderViewController, shippingAddress: ShippingAddress) {
    viewModel.shippingAddress = shippingAddress
  }
  
  public func reviewOrderViewControllerShippingAddress(viewController: ReviewOrderViewController) -> ShippingAddress? {
    return viewModel.shippingAddress
  }
  
  public func reviewOrderViewControllerDidSelectShippingMethod(viewController: ReviewOrderViewController, shippingMethod: ShippingMethod) {
    viewModel.shippingMethod = shippingMethod
  }
  
  public func reviewOrderViewControllerShippingMethod(viewController: ReviewOrderViewController) -> ShippingMethod? {
    return viewModel.shippingMethod
  }
  
  public func reviewOrderViewControllerDidSelectPaymentMethod(viewController: ReviewOrderViewController, paymentMethod: PaymentMethodData) {
    viewModel.paymentMethod = paymentMethod.paymentMethod
    viewModel.card = paymentMethod.card
  }
  
  public func reviewOrderViewControllerPaymentMethod(viewController: ReviewOrderViewController) -> PaymentMethodData? {
    return PaymentMethodData(paymentMethod: viewModel.paymentMethod, card: viewModel.card)
  }
  
  public func reviewOrderViewControllerDidSelectCoupon(viewController: ReviewOrderViewController, coupon: ShoppingCoupon?) {
    viewModel.coupon = coupon
  }
  
  public func reviewOrderViewControllerCoupon(viewController: ReviewOrderViewController) -> ShoppingCoupon? {
    return viewModel.coupon
  }
  
  public func reviewOrderViewControllerUpdateShippingMethod(viewController: ReviewOrderViewController) {
    viewModel.updateShippingMethodOnReviewOrder { [weak viewController] flag in
      guard let `viewController` = viewController else { return }
      if let flag = flag {
        if flag {//show selection
          viewController.presentShippingMethod(delegate: viewController)
        } else {//update and reload
          viewController.reload()
        }
      } else {
        //do nothing
      }
    }
  }
  
  public func reviewOrderViewControllerShopCartNavigationTapped(viewController: ReviewOrderViewController, orderData: CartSpecificsData) {
    viewModel.nextPage()
    viewModel.validateAndPlaceOrder(data: orderData)
  }
  
  public func reviewOrderViewControllerShopCartNavigationType(viewController: ReviewOrderViewController) -> ShopCartNavigationButton.AppearanceType? {
    return .default(title: "PLACE ORDER", enabled: true)
  }
}

// MARK: - CheckoutSuccessPresenterProtocol
extension ShopCartViewController: CheckoutSuccessPresenterProtocol {
  public func checkoutSuccessViewControllerData(viewController: CheckoutSuccessViewController) -> OrderReceivedData? {
    return viewModel.orderReceivedData
  }
  
  public func checkoutSuccessViewControllerNavigationTapped(viewController: CheckoutSuccessViewController) {
    viewController.dismissViewController()
    popToRootOrDismissViewController()
    appDelegate.mainView.goToTab(.shop)?.getChildController(ShopViewController.self)?.showSection(.products)
  }
  
  public func checkoutSuccessViewControllerNavigationType(viewController: CheckoutSuccessViewController) -> ShopCartNavigationButton.AppearanceType? {
    return .default(title: "CONTINUE SHOPPING", enabled: true)
  }
}

// MARK: - OrderReceivedPresenterProtocol
extension ShopCartViewController: OrderReceivedPresenterProtocol {
  public func orderReceivedViewControllerTitle(viewController: OrderReceivedViewController) -> String {
    return "ORDER RECEIVED"
  }
  
  public func orderReceivedViewControllerData(viewController: OrderReceivedViewController) -> OrderReceivedData? {
    return viewModel.orderReceivedData
  }
  
  public func orderReceivedViewControllerNavigationTapped(viewController: OrderReceivedViewController) {
    viewController.dismissViewController()
    popToRootOrDismissViewController()
    appDelegate.mainView.goToTab(.shop)?.getChildController(ShopViewController.self)?.showSection(.products)
  }
  
  public func orderReceivedViewControllerNavigationType(viewController: OrderReceivedViewController) -> ShopCartNavigationButton.AppearanceType? {
    return .default(title: "CONTINUE SHOPPING", enabled: true)
  }
}

public final class ShopCartNavigationButton: DesignableButton {
  public enum AppearanceType {
    case `default`(title: String, enabled: Bool)
    case navigation(title: String, enabled: Bool)
  }
  
  public var type: AppearanceType = .navigation(title: "", enabled: false) {
    didSet {
      switch type {
      case .default(let title, let enabled):
        if enabled {
          var appearance = DialogButtonAttributedTitleAppearance(color: .white)
          appearance.font = .idealSans(style: .book(size: 13.0))
          cornerRadius = 7.0
          setAttributedTitle(
            title.attributed.add(.appearance(appearance)),
            for: .normal)
          backgroundColor = .greyblue
        } else {
          var appearance = DialogButtonAttributedTitleAppearance(color: .bluishGrey)
          appearance.font = .idealSans(style: .book(size: 13.0))
          cornerRadius = 7.0
          setAttributedTitle(
            title.attributed.add(.appearance(appearance)),
            for: .normal)
          backgroundColor = .whiteThree
        }
        isUserInteractionEnabled = enabled
      case .navigation(let title, let enabled):
        if enabled {
          var appearance = DialogButtonAttributedTitleAppearance(color: .white)
          appearance.font = .idealSans(style: .book(size: 13.0))
          cornerRadius = 7.0
          setAttributedTitle(
            "\(title)   ".attributed.add(.appearance(appearance)).append(
              attrs: UIImage.icRightArrow.maskWithColor(.white).attributed.add(.baseline(offset: -3.0))),
            for: .normal)
          backgroundColor = .greyblue
        } else {
          var appearance = DialogButtonAttributedTitleAppearance(color: .bluishGrey)
          appearance.font = .idealSans(style: .book(size: 13.0))
          cornerRadius = 7.0
          setAttributedTitle(
            "\(title)   ".attributed.add(.appearance(appearance)).append(
              attrs: UIImage.icRightArrow.maskWithColor(.bluishGrey).attributed.add(.baseline(offset: -3.0))),
            for: .normal)
          backgroundColor = .whiteThree
        }
        isUserInteractionEnabled = enabled
      }
    }
  }
  
  public func setEnabled(_ enabled: Bool) {
    switch type {
    case .default(let title, _):
      if enabled {
        var appearance = DialogButtonAttributedTitleAppearance(color: .white)
        appearance.font = .idealSans(style: .book(size: 13.0))
        cornerRadius = 7.0
        setAttributedTitle(
          title.attributed.add(.appearance(appearance)),
          for: .normal)
        backgroundColor = .greyblue
      } else {
        var appearance = DialogButtonAttributedTitleAppearance(color: .bluishGrey)
        appearance.font = .idealSans(style: .book(size: 13.0))
        cornerRadius = 7.0
        setAttributedTitle(
          title.attributed.add(.appearance(appearance)),
          for: .normal)
        backgroundColor = .whiteThree
      }
      isUserInteractionEnabled = enabled
    case .navigation(let title, _):
      if enabled {
        var appearance = DialogButtonAttributedTitleAppearance(color: .white)
        appearance.font = .idealSans(style: .book(size: 13.0))
        cornerRadius = 7.0
        setAttributedTitle(
          "\(title)   ".attributed.add(.appearance(appearance)).append(
            attrs: UIImage.icRightArrow.maskWithColor(.white).attributed.add(.baseline(offset: -3.0))),
          for: .normal)
        backgroundColor = .greyblue
      } else {
        var appearance = DialogButtonAttributedTitleAppearance(color: .bluishGrey)
        appearance.font = .idealSans(style: .book(size: 13.0))
        cornerRadius = 7.0
        setAttributedTitle(
          "\(title)   ".attributed.add(.appearance(appearance)).append(
            attrs: UIImage.icRightArrow.maskWithColor(.bluishGrey).attributed.add(.baseline(offset: -3.0))),
          for: .normal)
        backgroundColor = .whiteThree
      }
      isUserInteractionEnabled = enabled
    }
  }
}

public protocol ShopCartPresenterProtocol {
}

extension ShopCartPresenterProtocol where Self: ControllerProtocol & UIViewController {
  public func showShopCart(animated: Bool = true) {
    let shopCartViewController = UIStoryboard.get(.cart).getController(ShopCartViewController.self)
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(shopCartViewController, animated: animated)
    } else {
      let navigationController = NavigationController(rootViewController: shopCartViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
  }
}
