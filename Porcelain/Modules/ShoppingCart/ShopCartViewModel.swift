//
//  ShopCartViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 2/26/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit
import Stripe

public enum ShopCartSection: Int {
  case cart = 0
  case shippingAddress
  case shippingMethod
  case paymentMethod
  case reviewOrder
  
  public var title: String {
    switch self {
    case .cart:
      return "CART"
    case .shippingAddress:
      return "SHIPPING ADDRESS"
    case .shippingMethod:
      return "SHIPPING METHOD"
    case .paymentMethod:
      return "PAYMENT METHOD"
    case .reviewOrder:
      return "REVIEW ORDER"
    }
  }
}

public struct CartSaltData {
  public let countryCode: String?
  public let subTotal: Double?
  public let total: Double?
  public let coupon: ShoppingCoupon?
}

public struct CartSpecificsData {
  let subTotal: Double
  let discount: Double
  let shippingFee: Double
  let total: Double
}

public protocol ShopCartView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func showError(message: String?)
  func showApplePayAuth(paymentRequest: PKPaymentRequest)
  func showSuccess()
}

public protocol ShopCartViewModelProtocol: class {
  var section: ShopCartSection { get set }
  var cartItems: [ShoppingCartItem] { get }
  var coupon: ShoppingCoupon? { get set }
  var shippingAddress: ShippingAddress? { get set }
  var shippingMethod: ShippingMethod? { get set }
  var paymentMethod: PaymentMethod? { get set }
  var card: Card? { get set }
  var cartSalt: CartSaltData { get }
  var orderReceivedData: OrderReceivedData? { get }
  
  func attachView(view: ShopCartView)
  func initialize()
  func nextPage()
  func prevPage()
  func validateAndPlaceOrder(data: CartSpecificsData)
  func updateShippingMethodOnReviewOrder(completion: @escaping (Bool?) -> Void)
  func placeOrder(data: CartSpecificsData)
  func validateApplePayWithCompletion(payment: PKPayment, completion: @escaping (PKPaymentAuthorizationResult) -> Void)
}

public final class ShopCartViewModel: ShopCartViewModelProtocol {
  private weak var view: ShopCartView?
  private var cartSpeficifics: CartSpecificsData?
  
  public var section: ShopCartSection = .cart
  public var cartItems: [ShoppingCartItem] {
    get {
      return ShoppingCart.shared.items
    } set {
      ShoppingCart.shared.items = newValue
    }
  }
  public var coupon: ShoppingCoupon?
  public var shippingAddress: ShippingAddress?
  public var shippingMethod: ShippingMethod?
  public var paymentMethod: PaymentMethod?
  public var card: Card?
  public var cartSalt: CartSaltData {
    let subTotal = cartItems.map({ $0.price * Double($0.quantity) }).reduce(0, +)
    let total: Double
    if let discountDollar = coupon?.discountDollar, subTotal > discountDollar  {
      total = subTotal - discountDollar
    } else {
      total = subTotal
    }
    return CartSaltData(countryCode: shippingAddress?.countryCode, subTotal: subTotal, total: total, coupon: coupon)
  }
  public var orderReceivedData: OrderReceivedData?
}

extension ShopCartViewModel {
  private var request: [APIServiceConstant.Key: Any] {
    var request: [APIServiceConstant.Key: Any] = [:]
    request[.shippingID] = shippingAddress?.id
    request[.shippingMethod] = shippingMethod?.id
    if let paymentMethod = paymentMethod {
      switch paymentMethod {
      case .applePay: break
      default:
        request[.paymentMethod] = paymentMethod.id
        if paymentMethod.id == "stripe" {
          request[.cardID] = card?.id
        }
      }
    }
    request[.email] = shippingAddress?.email ?? AppUserDefaults.customer?.email
    request[.couponCode] = [coupon].compactMap({ $0?.code })
    var cart: [[APIServiceConstant.Key: Any]] = []
    cartItems.forEach { (cartItem) in
      var cartRequest: [APIServiceConstant.Key: Any] = [:]
      cartRequest[.productID] = cartItem.productID
      cartRequest[.quantity] = cartItem.quantity
      cartRequest[.variationID] = cartItem.productVariation?.id
      if let overrideCart = coupon?.cart?.first(where: { $0.productID == cartItem.productID }) {
        cartRequest[.quantity] = overrideCart.quantity
        cartRequest[.price] = overrideCart.price
        cartRequest[.subtotal] = overrideCart.subtotal
        cartRequest[.total] = overrideCart.total
      }
      cart.append(cartRequest)
    }
    request[.cart] = cart
    request[.totalProductPrice] = cartSpeficifics?.subTotal
    request[.discountDollar] = cartSpeficifics?.discount
    request[.shippingCost] = cartSpeficifics?.shippingFee
    request[.totalPrice] = cartSpeficifics?.total
    return request
  }
}

extension ShopCartViewModel {
  public func attachView(view: ShopCartView) {
    self.view = view
  }
  
  public func initialize() {
    ShoppingCart.shared.clean()
    SelectCountryService.getDefaultCountry { (_) in} //Preload countries
    if let card = Card.selectedCard { //Preload cards
      self.card = card
    } else {
      PPAPIService.User.getStripCards().call { (response) in
        switch response {
        case .success(let result):
          CoreDataUtil.performBackgroundTask({ (moc) in
            guard let customerID = AppUserDefaults.customerID else { return }
            guard let customer = Customer.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
            Card.parseCardsFromData(result.data, customer: customer, inMOC: moc)
          }, completion: { (_) in
            self.card = Card.selectedCard
          })
        case .failure: break
        }
      }
    }
    view?.reload()
  }
  
  public func nextPage() {
    guard let section = ShopCartSection(rawValue: section.rawValue + 1) else { return }
    self.section = section
    view?.reload()
  }
  
  public func prevPage() {
    guard let section = ShopCartSection(rawValue: section.rawValue - 1) else { return }
    self.section = section
    view?.reload()
  }
  
  public func validateAndPlaceOrder(data: CartSpecificsData) {// Validate variation for outdated request and try to fix
    var errorMessage: String?
    let dispatchGroup = DispatchGroup()
    cartItems.forEach { (cartItem) in
      dispatchGroup.enter()
      PPAPIService.Product.getProductExtraInfo(productID: cartItem.productID).call { (response) in
        switch response {
        case .success(let result):
          if let productVariation = cartItem.productVariation,
            let variations = result.data.variations.array?.compactMap({ ProductVariation(data: $0) }),
            variations.count > 0 {//API Variations/ and contains
            if let existingVariation = variations.first(where: { $0.metaData == productVariation.metaData && $0.productID == productVariation.productID }), existingVariation.inStock {
              if existingVariation.id == productVariation.id && existingVariation.price != productVariation.price || //variation id is not the same
                existingVariation.id != productVariation.id && existingVariation.price == productVariation.price { //price is not the same
                let updatedCartItem = ShoppingCartItem(productID: cartItem.productID, productVariation: existingVariation) //recreate cart item with existing
                updatedCartItem.quantity = cartItem.quantity
                ShoppingCart.shared.replaceProduct(cartItem: cartItem, withCartItem: updatedCartItem)
                errorMessage = "Product variation updated, Please check your order and try again."
              } else {
                //Product variation is all good!
              }
            } else {
              errorMessage = "Product variation updated, Please check your order and try again."
              ShoppingCart.shared.removeProduct(cartItem: cartItem)
            }
            dispatchGroup.leave()
          } else {
            if let inStock = result.data.inStock.bool, inStock {
              if cartItem.price == result.data.price.doubleValue {
                //Product is all good!
                dispatchGroup.leave()
              } else {
                CoreDataUtil.performBackgroundTask({ (moc) in
                  let product = Product.getProduct(id: cartItem.productID, inMOC: moc)
                  product?.price = result.data.doubleValue
                }, completion: { (_) in
                  let updatedCartItem = ShoppingCartItem(productID: cartItem.productID, productVariation: nil)
                  updatedCartItem.quantity = cartItem.quantity
                  ShoppingCart.shared.replaceProduct(cartItem: cartItem, withCartItem: updatedCartItem)
                  errorMessage = "Product was updated, Please check your order and try again."
                  dispatchGroup.leave()
                })
              }
            } else {
              CoreDataUtil.performBackgroundTask({ (moc) in
                let product = Product.getProduct(id: cartItem.productID, inMOC: moc)
                product?.inStock = false
              }, completion: { (_) in
                ShoppingCart.shared.clean()
                errorMessage = "Product stock is updated, Please check your order and try again."
                dispatchGroup.leave()
              })
            }
          }
        case .failure(let error):
          errorMessage = error.localizedDescription
          dispatchGroup.leave()
        }
      }
    }
    
    view?.showLoading()
    dispatchGroup.notify(queue: .main) { [weak self] in
      guard let `self` = self else { return }
      self.view?.hideLoading()
      if let errorMessage = errorMessage {
        ShoppingCart.shared.mergeIndenticalProductsIfNeeded()
        if self.cartItems.isEmpty {
          self.section = .cart
        }
        self.view?.reload()
        self.view?.showError(message: errorMessage)
      } else {
        self.placeOrder(data: data)
      }
    }
  }
  
  /// nil completion do nothing, false completion one result -reload true multiple result show selection
  public func updateShippingMethodOnReviewOrder(completion: @escaping (Bool?) -> Void) {
    guard let countryCode = cartSalt.countryCode, let realAmount = cartSalt.subTotal, let amount = cartSalt.total else {
      completion(nil)
      return
    }
    view?.showLoading()
    PPAPIService.Checkout.getShippingMethods(countryCode: countryCode, amount: String(format: "%f", amount), realAmounnt: String(format: "%f", realAmount), couponCode: cartSalt.coupon?.code).call { (response) in
      switch response {
      case .success(let result):
        self.view?.hideLoading()
        let shippingMethods = ShippingMethod.parse(data: result.data)
        if shippingMethods.isEmpty {
          completion(nil)
        } else if shippingMethods.count == 1 {
          self.shippingMethod = shippingMethods[0]
          completion(false)
        } else {
          self.shippingMethod = shippingMethods[0]
          completion(true)
        }
      case .failure(let error):
        self.view?.hideLoading()
        self.view?.showError(message: error.localizedDescription)
        completion(nil)
      }
    }
  }
  
  public func placeOrder(data: CartSpecificsData) {
    self.cartSpeficifics = data
    guard shippingAddress != nil else {
      view?.showError(message: "No Shipping address selected.")
      return
    }
    guard shippingMethod != nil else {
      view?.showError(message: "No Shipping method selected.")
      return
    }
    guard let paymentMethod = paymentMethod else {
      view?.showError(message: "No Payment method selected.")
      return
    }
    if paymentMethod.id == "stripe" && card == nil {
      view?.showError(message: "No Card selected for payment method.")
      return
    }
    switch paymentMethod {
    case .applePay:
      let paymentRequest = Stripe.paymentRequest(
        withMerchantIdentifier: AppConstant.Integration.ApplePay.merchantIdentifier,
        country: AppConstant.Integration.ApplePay.countryCode,
        currency: AppConstant.Integration.ApplePay.currencyCode)
      paymentRequest.requiredShippingContactFields = []
      paymentRequest.requiredBillingContactFields = []
      paymentRequest.merchantCapabilities = .capability3DS
      var paymentSummaryItems: [PKPaymentSummaryItem] = []
      cartItems.forEach { (cartItem) in
        let itemName = String(format: "%@ x%d", cartItem.product?.name ?? "", cartItem.quantity)
        paymentSummaryItems.append(PKPaymentSummaryItem(
          label: itemName,
          amount: NSDecimalNumber(value: cartItem.price * Double(cartItem.quantity)),
          type: .final))
      }
      if let coupon = coupon {
        paymentSummaryItems.append(PKPaymentSummaryItem(
          label: "discount",
          amount: NSDecimalNumber(value: -coupon.discountDollar),
          type: .final))
      }
      paymentSummaryItems.append(PKPaymentSummaryItem(
        label: "shipping",
        amount: NSDecimalNumber(value: data.shippingFee),
        type: .final))
      paymentSummaryItems.append(PKPaymentSummaryItem(
        label: AppConstant.companyName,
        amount: NSDecimalNumber(value: data.total),
        type: .final))
      paymentRequest.paymentSummaryItems = paymentSummaryItems
      if Stripe.canSubmitPaymentRequest(paymentRequest) {
        view?.showApplePayAuth(paymentRequest: paymentRequest)
      } else {
        view?.showError(message: "Please check your apple pay configuration.")
      }
    default:
      view?.showLoading()
      PPAPIService.Checkout.checkoutNew(request: request).call { (response) in
        switch response {
        case .success(let result):
          self.orderReceivedData = OrderReceivedData(message: result.message, data: result.data)
          ShoppingCart.shared.clearItems()
          self.view?.hideLoading()
          self.view?.showSuccess()
        case .failure(let error):
          self.view?.hideLoading()
          self.view?.showError(message: error.localizedDescription)
        }
      }
    }
  }
  
  public func validateApplePayWithCompletion(payment: PKPayment, completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
    STPAPIClient.shared().createToken(with: payment) { (token, error) in
      guard let token = token, error == nil else {
        completion(.init(status: .failure, errors: [error].compactMap({ $0 })))
        self.view?.showError(message: error?.localizedDescription)
        return
      }
      self.view?.showLoading()
      var newRequest = self.request
      newRequest[.paymentMethod] = "stripe"
      newRequest[.cardID] = token.tokenId
      newRequest[.subPaymentMethod] = "apple_pay"
      PPAPIService.Checkout.checkoutNew(request: newRequest).call { (response) in
        switch response {
        case .success(let result):
          completion(.init(status: .success, errors: nil))
          self.orderReceivedData = OrderReceivedData(message: result.message, data: result.data)
          ShoppingCart.shared.clearItems()
          self.view?.hideLoading()
          self.view?.showSuccess()
        case .failure(let error):
          completion(.init(status: .failure, errors: [error]))
          self.view?.hideLoading()
          self.view?.showError(message: error.localizedDescription)
        }
      }
    }
  }
}
