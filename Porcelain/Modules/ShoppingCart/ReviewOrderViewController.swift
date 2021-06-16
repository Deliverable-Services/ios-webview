//
//  ReviewOrderViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 2/26/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public protocol ReviewOrderViewControllerDelegate: class {
  func reviewOrderViewControllerCartItems(viewController: ReviewOrderViewController) -> [ShoppingCartItem]
  func reviewOrderViewControllerCartSalt(viewController: ReviewOrderViewController) -> CartSaltData?
  func reviewOrderViewControllerDidSelectShippingAddress(viewController: ReviewOrderViewController, shippingAddress: ShippingAddress)
  func reviewOrderViewControllerShippingAddress(viewController: ReviewOrderViewController) -> ShippingAddress?
  func reviewOrderViewControllerDidSelectShippingMethod(viewController: ReviewOrderViewController, shippingMethod: ShippingMethod)
  func reviewOrderViewControllerShippingMethod(viewController: ReviewOrderViewController) -> ShippingMethod?
  func reviewOrderViewControllerDidSelectPaymentMethod(viewController: ReviewOrderViewController, paymentMethod: PaymentMethodData)
  func reviewOrderViewControllerDidSelectCoupon(viewController: ReviewOrderViewController, coupon: ShoppingCoupon?)
  func reviewOrderViewControllerCoupon(viewController: ReviewOrderViewController) -> ShoppingCoupon?
  func reviewOrderViewControllerUpdateShippingMethod(viewController: ReviewOrderViewController)
  func reviewOrderViewControllerPaymentMethod(viewController: ReviewOrderViewController) -> PaymentMethodData?
  func reviewOrderViewControllerShopCartNavigationTapped(viewController: ReviewOrderViewController, orderData: CartSpecificsData)
  func reviewOrderViewControllerShopCartNavigationType(viewController: ReviewOrderViewController) -> ShopCartNavigationButton.AppearanceType?
}

public final class ReviewOrderViewController: UIViewController {
  @IBOutlet private weak var scrollView: UIScrollView! {
    didSet {
      scrollView.backgroundColor = .whiteFive
      scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 24.0, right: 0.0)
    }
  }
  @IBOutlet private weak var reviewOrderItemsView: ReviewOrderItemsView! {
    didSet {
      reviewOrderItemsView.cornerRadius = 7.0
      reviewOrderItemsView.borderWidth = 1.0
      reviewOrderItemsView.borderColor = .whiteThree
    }
  }
  @IBOutlet private weak var reviewOrderShippingAddressView: ReviewOrderShippingAddressView! {
    didSet {
      reviewOrderShippingAddressView.cornerRadius = 7.0
      reviewOrderShippingAddressView.borderWidth = 1.0
      reviewOrderShippingAddressView.borderColor = .whiteThree
    }
  }
  @IBOutlet private weak var reviewOrderShippingMethodView: ReviewOrderShippingMethodView! {
    didSet {
      reviewOrderShippingMethodView.cornerRadius = 7.0
      reviewOrderShippingMethodView.borderWidth = 1.0
      reviewOrderShippingMethodView.borderColor = .whiteThree
    }
  }
  @IBOutlet private weak var reviewOrderPaymentMethodView: ReviewOrderPaymentMethodView! {
    didSet {
      reviewOrderPaymentMethodView.cornerRadius = 7.0
      reviewOrderPaymentMethodView.borderWidth = 1.0
      reviewOrderPaymentMethodView.borderColor = .whiteThree
    }
  }
  @IBOutlet private weak var cartAmountSummaryView: CartAmountSummaryView!
  @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
  
  private var tempShippingAddress: ShippingAddress?
  private var tempShippingMethod: ShippingMethod?
  private var tempPaymentMethod: PaymentMethodData?
  
  public weak var delegate: ReviewOrderViewControllerDelegate? {
    didSet {
      guard isViewLoaded else { return }
      reload()
    }
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public func reload() {
    reviewOrderItemsView.cartItems = delegate?.reviewOrderViewControllerCartItems(viewController: self).sorted(by: { $0.createdAt > $1.createdAt }) ?? []
    reviewOrderShippingAddressView.shippingAddress = delegate?.reviewOrderViewControllerShippingAddress(viewController: self)
    reviewOrderShippingMethodView.shippingMethod = delegate?.reviewOrderViewControllerShippingMethod(viewController: self)
    let paymentMethod = delegate?.reviewOrderViewControllerPaymentMethod(viewController: self)
    reviewOrderPaymentMethodView.paymentMethod = paymentMethod?.paymentMethod
    reviewOrderPaymentMethodView.card = paymentMethod?.card
    cartAmountSummaryView.cartItems = delegate?.reviewOrderViewControllerCartItems(viewController: self) ?? []
    cartAmountSummaryView.shippingMethod = delegate?.reviewOrderViewControllerShippingMethod(viewController: self)
    cartAmountSummaryView.coupon = delegate?.reviewOrderViewControllerCoupon(viewController: self)
    if let appearanceType = delegate?.reviewOrderViewControllerShopCartNavigationType(viewController: self) {
      cartAmountSummaryView.actionAppearanceType = appearanceType
    } else {
      cartAmountSummaryView.actionAppearanceType = .default(title: "PLACE ORDER", enabled: false)
    }
    cartAmountSummaryView.recalculateCouponIfNeeded()
  }
}

// MARK: - AddressBookPresenterProtocol
extension ReviewOrderViewController: AddressBookPresenterProtocol {
}

// MARK: - ShippingMethodPresenterProtocol
extension ReviewOrderViewController: ShippingMethodPresenterProtocol {
}

// MARK: - PaymentMethodPresenterProtocol
extension ReviewOrderViewController: PaymentMethodPresenterProtocol {
}

// MARK: - ControllerProtocol
extension ReviewOrderViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("ReviewOrderViewController segueIdentifier not set")
  }
  
  public func setupUI() {
    view.backgroundColor = .white
  }
  
  public func setupController() {
  }
  
  public func setupObservers() {
    observeKeyboard()
    reviewOrderShippingAddressView.editDidTapped = { [weak self] in
      guard let `self` = self else { return }
      self.presentAddressBook(delegate: self)
    }
    reviewOrderShippingMethodView.editDidTapped = { [weak self] in
      guard let `self` = self else { return }
      self.presentShippingMethod(delegate: self)      
    }
    reviewOrderPaymentMethodView.editDidTapped = { [weak self] in
      guard let `self` = self else { return }
      self.presentPaymentMethod(delegate: self)
    }
    cartAmountSummaryView.couponDidUpdate = { [weak self] in
      guard let `self` = self else { return }
      self.delegate?.reviewOrderViewControllerDidSelectCoupon(viewController: self, coupon: self.cartAmountSummaryView.coupon)
    }
    cartAmountSummaryView.couponApplyFreeShipping = { [weak self] in
      guard let `self` = self else { return }
      self.delegate?.reviewOrderViewControllerUpdateShippingMethod(viewController: self)
    }
    cartAmountSummaryView.actionDidTapped = { [weak self] in
      guard let `self` = self else { return }
      self.delegate?.reviewOrderViewControllerShopCartNavigationTapped(viewController: self, orderData: self.cartAmountSummaryView.orderData)
    }
  }
}

// MARK: - KeyboardHandlerProtocol
extension ReviewOrderViewController: KeyboardHandlerProtocol {
  public func keyboardWillHide(_ notification: Notification) {
    guard cartAmountSummaryView.isFirstResponder else { return }
    bottomConstraint.constant = 0
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
  
  public func keyboardWillShow(_ notification: Notification) {
    guard cartAmountSummaryView.isFirstResponder else { return }
    let keyboardHeight = evaluateKeyboardFrameFromNotification(notification).height
    let bottomInset = appDelegate.window?.safeAreaInsets.bottom ?? 0.0
    bottomConstraint.constant = max(0, keyboardHeight - (cartAmountSummaryView.bounds.height - 72.0) - bottomInset)
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
}

// MARK: - AddressBookViewControllerDelegate
extension ReviewOrderViewController: AddressBookViewControllerDelegate {
  public func addressBookViewControllerAllowsDelete(viewController: AddressBookViewController) -> Bool {
    return false
  }
  
  public func addressBookViewControllerAllowsSelection(viewController: AddressBookViewController) -> Bool {
    return true
  }
  
  public func addressBookViewControllerTitle(viewController: AddressBookViewController) -> String {
    return "EDIT SHIPPING ADDRESS"
  }
  
  public func addressBookViewControllerTopHeaderPadding(viewController: AddressBookViewController) -> CGFloat {
    return 24.0
  }
  
  public func addressBookViewControllerDidCancel(viewController: AddressBookViewController) {
    tempShippingAddress = nil
  }
  
  public func addressBookViewControllerDidSelect(viewController: AddressBookViewController, address: ShippingAddress, action: Bool) {
    let canReload = tempShippingAddress != address
    tempShippingAddress = address
    if canReload {
      viewController.reload()
    }
  }
  
  public func addressBookViewControllerSelectedAddress(viewController: AddressBookViewController) -> ShippingAddress? {
    return tempShippingAddress ?? delegate?.reviewOrderViewControllerShippingAddress(viewController: self)
  }
  
  public func addressBookViewControllerShopCartNavigationTapped(viewController: AddressBookViewController) {
    viewController.showShippingMethod(delegate: self)
  }
  
  public func addressBookViewControllerShopCartNavigationType(viewController: AddressBookViewController) -> ShopCartNavigationButton.AppearanceType? {
    return .default(title: "UPDATE", enabled: tempShippingAddress != nil)
  }
}

// MARK: - ShippingMethodViewControllerDelegate
extension ReviewOrderViewController: ShippingMethodViewControllerDelegate {
  public func shippingMethodViewControllerTitle(viewController: ShippingMethodViewController) -> String {
    return "EDIT SHIPPING METHOD"
  }
  
  public func shippingMethodViewControllerCartSalt(viewController: ShippingMethodViewController) -> CartSaltData? {
    let cartSalt = delegate?.reviewOrderViewControllerCartSalt(viewController: self)
    if let tempShippingAddress = tempShippingAddress {
      return CartSaltData(countryCode: tempShippingAddress.countryCode, subTotal: cartSalt?.subTotal, total: cartSalt?.total, coupon: cartSalt?.coupon)
    } else {
      return cartSalt
    }
  }
  
  public func shippingMethodViewControllerDidCancel(viewController: ShippingMethodViewController) {
    tempShippingMethod = nil
  }
  
  public func shippingMethodViewControllerDidSelect(viewController: ShippingMethodViewController, shippingMethod: ShippingMethod, action: Bool) {
    let canReload = tempShippingMethod != shippingMethod
    tempShippingMethod = shippingMethod
    if canReload {
      viewController.reload()
    }
  }
  
  public func shippingMethodViewControllerShopCartNavigationTapped(viewController: ShippingMethodViewController) {
    if let tempShippingMethod = tempShippingMethod {
      delegate?.reviewOrderViewControllerDidSelectShippingMethod(viewController: self, shippingMethod: tempShippingMethod)
      reload()
      self.tempShippingMethod = nil
    }
    if let tempShippingAddress = tempShippingAddress {
      delegate?.reviewOrderViewControllerDidSelectShippingAddress(viewController: self, shippingAddress: tempShippingAddress)
      reload()
      self.tempShippingAddress = nil
    }
    viewController.dismissViewController()
  }
  
  public func shippingMethodViewControllerShopCartNavigationType(viewController: ShippingMethodViewController) -> ShopCartNavigationButton.AppearanceType? {
    return .default(title: "UPDATE", enabled: tempShippingMethod != nil)
  }
}

// MARK: - PaymentMethodViewControllerDelegate
extension ReviewOrderViewController: PaymentMethodViewControllerDelegate {
  public func paymentMethodViewControllerTitle(viewController: PaymentMethodViewController) -> String {
    return "EDIT PAYMENT METHOD"
  }
  
  public func paymentMethodViewControllerDidCancel(viewController: PaymentMethodViewController) {
    tempPaymentMethod = nil
  }
  
  public func paymentMethodViewControllerDidSelect(viewController: PaymentMethodViewController, paymentMethod: PaymentMethodData, action: Bool) {
    let canReload = tempPaymentMethod != paymentMethod
    tempPaymentMethod = paymentMethod
    if canReload {
      viewController.reload()
    }
  }
  
  public func paymentMethodViewControllerPaymentMethod(viewController: PaymentMethodViewController) -> PaymentMethodData {
    let paymentMethod = tempPaymentMethod ?? delegate?.reviewOrderViewControllerPaymentMethod(viewController: self)
    return PaymentMethodData(paymentMethod: paymentMethod?.paymentMethod, card: paymentMethod?.card)
  }
  
  public func paymentMethodViewControllerShopCartNavigationTapped(viewController: PaymentMethodViewController) {
    if let tempPaymentMethod = tempPaymentMethod {
      delegate?.reviewOrderViewControllerDidSelectPaymentMethod(viewController: self, paymentMethod: tempPaymentMethod)
      reload()
      self.tempPaymentMethod = nil
    }
    viewController.popOrDismissViewController()
  }
  
  public func paymentMethodViewContollerShopCartNavigationType(viewController: PaymentMethodViewController) -> ShopCartNavigationButton.AppearanceType? {
    return .default(title: "UPDATE", enabled: tempPaymentMethod != nil)
  }
}

// MARK: - ShippingMethodPresenterProtocol
extension AddressBookViewController: ShippingMethodPresenterProtocol {
}
