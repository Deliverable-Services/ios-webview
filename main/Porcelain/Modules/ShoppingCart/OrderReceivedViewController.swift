//
//  OrderReceivedViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 3/3/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import SwiftyJSON

private struct AttributedInstructionsAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? = 0.46
  var alignment: NSTextAlignment? = .left
  var lineBreakMode: NSLineBreakMode? = .byWordWrapping
  var minimumLineHeight: CGFloat? = 20.0
  var font: UIFont? = .openSans(style: .regular(size: 13.0))
  var color: UIColor? = .gunmetal
}

public enum OrderShipping: String {
  case flatRate = "flat_rate"
  case freeShipping = "free_shipping"
  
  public var title: String {
    switch self {
    case .flatRate:
      return "Flat Rate"
    case .freeShipping:
      return "Free Shipping"
    }
  }
}

public struct ORBankDetails {
  public let name: String?
  public let accountNumber: String
  public let accountName: String?
  
  public init?(data: JSON) {
    guard let accountNumber = data.accountNumber.string else { return nil }
    self.accountNumber = accountNumber
    name = data.bankName.string
    accountName = data.accountName.string
  }
}

public struct ORPurchasedItem {
  public let id: String
  public let name: String?
  public let image: String?
  public let price: Double
  public let quantity: Int
  public let productVariation: ProductVariation?
  
  public init?(data: JSON) {
    guard let id = data.id.numberString else { return nil }
    self.id = id
    name = data.name.string
    image = data.product.images.array?.first?.src.string
    price = data.product.price.double ?? data.price.doubleValue
    quantity = data.quantity.intValue
    productVariation = ProductVariation(data: data.variation)
  }
}

public struct ORShippingAddress  {
  public let id: String
  public let name: String?
  public let address: String?
  public let country: String?
  public let state: String?
  public let postalCode: String?
  public let email: String?
  public let phone: String?
  
  public init?(data: JSON) {
    guard let id = data.id.numberString else { return nil }
    self.id = id
    name = data.name.string
    address = data.address.string
    country = data.country.string
    state = data.state.string
    postalCode = data.postalCode.numberString
    email = data.email.string
    phone = data.phone.string
  }
  
  public init(id: String, name: String, address: String, country: String, state: String, postalCode: String, email: String, phone: String) {
    self.id = id
    self.name = name
    self.address = address
    self.country = country
    self.state = state
    self.postalCode = postalCode
    self.email = email
    self.phone = phone
  }
}

public struct OrderReceivedData {
  let message: String?
  let orderID: String
  let orderNumber: String?
  let orderDate: Date?
  let orderSubtotal: Double
  let orderShippingFee: Double
  let orderDiscount: Double
  let orderShipping: OrderShipping?
  let orderShippingAddress: ORShippingAddress?
  let orderCoupon: String?
  let orderPaymentMethod: PaymentMethod?
  let orderTotal: String?
  let bankDetails: [ORBankDetails]?
  let purchasedItems: [ORPurchasedItem]?
  let subPayment: String?
  
  public init?(message: String? = nil, data: JSON) {
    guard let orderID = data.wcOrderID.numberString else { return nil }
    self.message = message
    self.orderID = orderID
    orderNumber = data.wcOrderNumber.string
    orderDate = data.createdAt.toDate(format: .ymdhmsDateFormat)
    orderSubtotal = data.total.doubleValue
    orderShippingFee = data.shipping.doubleValue
    orderDiscount = data.discount.doubleValue
    orderCoupon = data.coupons.string
    orderShipping = OrderShipping(rawValue: data.shippingMethod.stringValue)
    orderShippingAddress = ORShippingAddress(data: data.shippingAddress) //?? testShipping
    orderPaymentMethod = PaymentMethod(data: data.paymentMethodDetails)
    orderTotal = data.totalAmount.string
    bankDetails = data.bankDetails.array?.compactMap({ ORBankDetails(data: $0) })
    purchasedItems = data.purchasedItems.array?.compactMap({ ORPurchasedItem(data: $0) })
    if data.subPaymentMethod.string == "apple_pay" {
      subPayment = "Apple Pay"
    } else if data.subPaymentMethod.string == "google_pay" {
      subPayment = "Google Pay"
    } else {
      subPayment = nil
    }
  }
}

public enum OrderReceivedDismissType {
  case back
  case action(title: String)
}

public protocol OrderReceivedViewControllerDelegate: class {
  func orderReceivedViewControllerTitle(viewController: OrderReceivedViewController) -> String
  func orderReceivedViewControllerData(viewController: OrderReceivedViewController) -> OrderReceivedData?
  func orderReceivedViewControllerNavigationTapped(viewController: OrderReceivedViewController)
  func orderReceivedViewControllerNavigationType(viewController: OrderReceivedViewController) -> ShopCartNavigationButton.AppearanceType?
}

public final class OrderReceivedViewController: UIViewController {
  @IBOutlet private weak var scrollView: UIScrollView! {
    didSet {
      scrollView.contentInset = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 16.0, right: 0.0)
    }
  }
  @IBOutlet private weak var messageLabel: UILabel! {
    didSet {
      messageLabel.font = .idealSans(style: .book(size: 16.0))
      messageLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var shippingAddressView: OrderReceivedAddressView! {
    didSet {
      shippingAddressView.cornerRadius = 7.0
      shippingAddressView.borderColor = .whiteThree
      shippingAddressView.borderWidth = 1.0
    }
  }
  @IBOutlet private weak var summaryView: OrderReceivedSummaryView! {
    didSet {
      summaryView.cornerRadius = 7.0
      summaryView.borderColor = .whiteThree
      summaryView.borderWidth = 1.0
    }
  }
  @IBOutlet private weak var instructionsLabel: UILabel!
  @IBOutlet private weak var bankDetailsStack: UIStackView!
  @IBOutlet private weak var orderDetailsStack: UIStackView!
  @IBOutlet private weak var orderDetailsTitleLabel: UILabel! {
    didSet {
      orderDetailsTitleLabel.font = .openSans(style: .semiBold(size: 14.0))
      orderDetailsTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var orderDetailsView: ReviewOrderItemsView! {
    didSet {
      orderDetailsView.cornerRadius = 7.0
      orderDetailsView.borderWidth = 1.0
      orderDetailsView.borderColor = .whiteThree
    }
  }
  @IBOutlet private weak var actionContainerView: UIView! {
    didSet {
      actionContainerView.backgroundColor = .whiteFive
    }
  }
  @IBOutlet private weak var actionButton: ShopCartNavigationButton!
  
  fileprivate weak var delegate: OrderReceivedViewControllerDelegate?
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  @objc
  private func backTapped() {
    delegate?.orderReceivedViewControllerNavigationTapped(viewController: self)
  }
  
  private func initialize() {
    title = delegate?.orderReceivedViewControllerTitle(viewController: self) ?? "ORDER RECEIVED"
    let orderReceivedData = delegate?.orderReceivedViewControllerData(viewController: self)
    if let message = orderReceivedData?.message {
      messageLabel.isHidden = false
      messageLabel.text = message
    } else {
      messageLabel.isHidden = true
    }
    if let shippingAddress = orderReceivedData?.orderShippingAddress {
      shippingAddressView.isHidden = false
      shippingAddressView.shippingAddress = shippingAddress
    } else {
      shippingAddressView.isHidden = true
    }
    summaryView.orderReceivedData = orderReceivedData
    if let instructions = orderReceivedData?.orderPaymentMethod?.instructions {
      instructionsLabel.isHidden = false
      instructionsLabel.attributedText = instructions.attributed.add(.appearance(AttributedInstructionsAppearance()))
    } else {
      instructionsLabel.isHidden = true
    }
    if let bankDetails = orderReceivedData?.bankDetails, !bankDetails.isEmpty {
      bankDetailsStack.isHidden = false
      bankDetailsStack.removeAllArrangedSubviews()
      bankDetails.forEach { (bank) in
        let orBankDetailsView = OrderReceivedBankDetailsView()
        orBankDetailsView.backgroundColor = .white
        orBankDetailsView.cornerRadius = 7.0
        orBankDetailsView.borderColor = .whiteThree
        orBankDetailsView.borderWidth = 1.0
        orBankDetailsView.bankDetails = bank
        bankDetailsStack.addArrangedSubview(orBankDetailsView)
      }
    } else {
      bankDetailsStack.isHidden = true
    }
    if let purchasedItems = orderReceivedData?.purchasedItems, !purchasedItems.isEmpty {
      orderDetailsStack.isHidden = false
      orderDetailsView.purchasedItems = purchasedItems
    } else {
      orderDetailsStack.isHidden = true
    }
    if let appearanceType = delegate?.orderReceivedViewControllerNavigationType(viewController: self) {
      actionContainerView.isHidden = false
      actionButton.type = appearanceType
    } else {
      actionContainerView.isHidden = true
      generateLeftNavigationButton(image: .icLeftArrow, selector: #selector(backTapped))
    }
  }
  
  @IBAction private func actionTapped(_ sender: Any) {
    delegate?.orderReceivedViewControllerNavigationTapped(viewController: self)
  }
}

// MARK: - NavigationProtocol
extension OrderReceivedViewController: NavigationProtocol {
}

// MARK: - ControllerProtocol
extension OrderReceivedViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("OrderReceivedViewController segueIdentifier not set")
  }
  
  public func setupUI() {
    view.backgroundColor = .whiteFive
  }
  
  public func setupController() {
    initialize()
  }
  
  public func setupObservers() {
  }
}

public protocol OrderReceivedPresenterProtocol: OrderReceivedViewControllerDelegate {
}

extension OrderReceivedPresenterProtocol where Self: ControllerProtocol & UIViewController {
  public func showOrderReceived(animated: Bool = true) {
    let orderReceivedViewController = UIStoryboard.get(.cart).getController(OrderReceivedViewController.self)
    orderReceivedViewController.delegate = self
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(orderReceivedViewController, animated: animated)
    } else {
      let navigationController = NavigationController(rootViewController: orderReceivedViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
  }
  
  public func presentOrderReceived(animated: Bool = true) {
    let orderReceivedViewController = UIStoryboard.get(.cart).getController(OrderReceivedViewController.self)
    orderReceivedViewController.delegate = self
    let navigationController = NavigationController(rootViewController: orderReceivedViewController)
    navigationController.modalPresentationStyle = .fullScreen
    present(navigationController, animated: animated) {
    }
  }
}
