//
//  CartAmountSummaryView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 2/22/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class CartAmountSummaryView: UIView, Shadowable {
  public var shadowLayer: CAShapeLayer!
  
  @IBOutlet private weak var view: UIView!
  @IBOutlet private weak var couponStack: UIStackView!
  @IBOutlet private weak var couponTextField: DesignableTextField! {
    didSet {
      couponTextField.cornerRadius = 4.0
      couponTextField.borderWidth = 1.0
      couponTextField.borderColor = .whiteThree
      couponTextField.font = .openSans(style: .regular(size: 14.0))
      couponTextField.textColor = .gunmetal
      couponTextField.tintColor = .gunmetal
      couponTextField.placeholder = "Enter Promo Code"
      couponTextField.delegate = self
    }
  }
  @IBOutlet private weak var couponApplyButton: DesignableButton! {
    didSet {
      couponApplyButton.cornerRadius = 7.0
      couponApplyButton.backgroundColor = .greyblue
      couponApplyButton.setAttributedTitle(
        "APPLY".attributed.add([.color(.white), .font(.idealSans(style: .book(size: 13.0)))]),
        for: .normal)
    }
  }
  @IBOutlet private weak var contentScrollView: ObservingContentScrollView!
  @IBOutlet private weak var contentScrollHeightConstraint: NSLayoutConstraint!
  @IBOutlet private weak var subtotalTitleLabel: UILabel! {
    didSet {
      subtotalTitleLabel.font = .openSans(style: .regular(size: 14.0))
      subtotalTitleLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var subtotalPriceLabel: UILabel! {
    didSet {
      subtotalPriceLabel.font = .openSans(style: .regular(size: 14.0))
      subtotalPriceLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var cartCouponListView: CartCouponListView!
  @IBOutlet private weak var shippingStack: UIStackView!
  @IBOutlet private weak var shippingTitleLabel: UILabel! {
    didSet {
      shippingTitleLabel.font = .openSans(style: .regular(size: 14.0))
      shippingTitleLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var shippingValueLabel: UILabel! {
    didSet {
      shippingValueLabel.font = .openSans(style: .regular(size: 14.0))
      shippingValueLabel.textColor = .bluishGrey
      shippingValueLabel.numberOfLines = 2
      shippingValueLabel.textAlignment = .right
    }
  }
  @IBOutlet private weak var totalTitleLabel: UILabel! {
    didSet {
      totalTitleLabel.font = .openSans(style: .semiBold(size: 14.0))
      totalTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var totalPriceLabel: UILabel! {
    didSet {
      totalPriceLabel.font = .openSans(style: .semiBold(size: 14.0))
      totalPriceLabel.textColor = UIColor(red: 46, green: 115, blue: 151)
    }
  }
  @IBOutlet private weak var actionButton: ShopCartNavigationButton!
  
  private var validateCouponRequest: URLSessionDataTask?
  
  public var cartItems: [ShoppingCartItem] = [] {
    didSet {
      updateSubtotal()
    }
  }
  
  public var shippingMethod: ShippingMethod? {
    didSet {
      updateShipping()
    }
  }
  
  public var coupon: ShoppingCoupon? {
    didSet {
      updateCoupons()
    }
  }

  public private(set) var subTotal: Double = 0
  public private(set) var discount: Double = 0
  public private(set) var shippingFee: Double = 0
  public private(set) var total: Double = 0
  
  public var orderData: CartSpecificsData {
    return CartSpecificsData(subTotal: subTotal, discount: discount, shippingFee: shippingFee, total: total)
  }
  
  public var actionAppearanceType: ShopCartNavigationButton.AppearanceType? {
    didSet {
      actionButton.type = actionAppearanceType ?? .navigation(title: "GO TO SHIPPING ADDRESS", enabled: false)
    }
  }

  public override var isFirstResponder: Bool {
    return couponTextField.isFirstResponder
  }
  
  @discardableResult
  public override func becomeFirstResponder() -> Bool {
    return couponTextField.becomeFirstResponder()
  }
  
  @discardableResult
  public override func resignFirstResponder() -> Bool {
    return couponTextField.resignFirstResponder()
  }
  
  public var couponDidUpdate: VoidCompletion?
  public var couponApplyFreeShipping: VoidCompletion?
  public var actionDidTapped: VoidCompletion?
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    var appearance = ShadowAppearance.default
    appearance.shadowOffset = CGSize(width: 0.0, height: -3.0)
    addShadow(appearance: appearance)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    commonInit()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    commonInit()
  }
  
  private func commonInit() {
    loadNib(CartAmountSummaryView.self)
    addSubview(view)
    view.addSideConstraintsWithContainer()
    cartCouponListView.didRemoveCoupons = { [weak self] in
      guard let `self` = self else { return }
      self.coupon = nil
      self.couponDidUpdate?()
      self.couponApplyFreeShipping?()
    }
    contentScrollView.observeContentSizeUpdates = { [weak self] (size) in
      guard let `self` = self else { return }
      self.contentScrollHeightConstraint.constant = size.height
    }
  }
  
  private func updateSubtotal() {
    var itemCount = 0
    var itemTotal: Double = 0
    cartItems.forEach { (item) in
      itemCount += item.quantity
      itemTotal += item.price * Double(item.quantity)
    }
    subtotalTitleLabel.text = String(format: "Subtotal (%d item/s)", itemCount)
    subtotalPriceLabel.text = String(format: "%@%.2f", AppConstant.currencySymbol, itemTotal)
    updateTotal()
  }
  
  private func updateShipping() {
    if shippingMethod != nil {
      shippingStack.isHidden = false
    } else {
      shippingStack.isHidden = true
    }
    updateTotal()
  }
  
  private func updateCoupons() {
    discount = 0
    shippingFee = shippingMethod?.cost ?? 0
    if let coupon = coupon {
      couponStack.isHidden = true
      var contents: [String] = []
      if coupon.discountDollar > 0 {
        discount = coupon.discountDollar
        contents.append(String(format: "-%@%.2f", AppConstant.currencySymbol, coupon.discountDollar))
      }
      cartCouponListView.coupons = [CartCouponData(code: coupon.code, content: contents.joined(separator: ", "))]
    } else {
      couponStack.isHidden = false
      cartCouponListView.coupons = []
    }
    if shippingFee == 0 {
      shippingValueLabel.text = "Free"
    } else {
      shippingValueLabel.text = [shippingMethod?.title, String(format: "%@%.2f", AppConstant.currencySymbol, shippingFee)].compactMap({ $0 }).joined(separator: ": ")
    }
    updateTotal()
  }
  
  private func updateTotal() {
    subTotal = cartItems.map({ $0.price * Double($0.quantity) }).reduce(0, +)
    total = max(0.0, subTotal - discount + shippingFee)
    totalPriceLabel.text = String(format: "%@%.2f", AppConstant.currencySymbol, total)
  }
  
  public func recalculateCouponIfNeeded() {
    guard let coupon = coupon else { return }
    validateCouponRequest?.cancel()
    actionButton.isLoading = true
    let cart: [[APIServiceConstant.Key: Any]] = cartItems.map({ [
      .productID: $0.productID,
      .quantity: $0.quantity,
      .variationID: ($0.productVariation?.id ?? NSNull())] })
    let request: [APIServiceConstant.Key: Any] = [.cart: cart]
    validateCouponRequest = PPAPIService.Checkout.validateCouponNew(code: coupon.code, request: request).call { (response) in
      switch response {
      case .success(let result):
        if let coupon = ShoppingCoupon(data: result.data), coupon.isValid {
          self.coupon = coupon
        } else {
          self.coupon = nil
        }
        self.actionButton.isLoading = false
        self.couponDidUpdate?()
      case .failure(let error):
        guard error.failureCode.rawCode != -1  && error.localizedDescription != "cancelled" else { return }
        self.coupon = nil
        self.actionButton.isLoading = false
      }
    }
  }
  
  @IBAction private func couponApplyTapped(_ sender: Any) {
    guard let code = couponTextField.text else { return }
    guard !code.isEmpty else {
      appDelegate.showAlert(title: "Oops!", message: "Coupon code is missing.")
      return
    }
    appDelegate.showLoading()
    let cart: [[APIServiceConstant.Key: Any]] = cartItems.map({ [
      .productID: $0.productID,
      .quantity: $0.quantity,
      .variationID: ($0.productVariation?.id ?? NSNull())] })
    let request: [APIServiceConstant.Key: Any] = [.cart: cart]
    PPAPIService.Checkout.validateCouponNew(code: code, request: request).call { (response) in
      switch response {
      case .success(let result):
        appDelegate.hideLoading()
        if let coupon = ShoppingCoupon(data: result.data), coupon.isValid {
          self.couponTextField.text = nil
          self.coupon = coupon
          self.couponDidUpdate?()
          self.couponApplyFreeShipping?()
        } else {
          self.coupon = nil
          appDelegate.showAlert(title: "Oops!", message: "Coupon code is invalid.")
        }
        self.resignFirstResponder()
      case .failure(let error):
        self.coupon = nil
        appDelegate.hideLoading()
        appDelegate.showAlert(title: "Oops!", message: error.localizedDescription)
      }
    }
  }
  
  @IBAction private func actionTapped(_ sender: Any) {
    actionDidTapped?()
  }
}

// MARK: - UITextFieldDelegate
extension CartAmountSummaryView: UITextFieldDelegate {
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
}
