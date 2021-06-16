//
//  ShoppingCart.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 26/11/2018.
//  Update by Justine Angelo Rangel on 13/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import R4pidKit
import SwiftMessages

public final class ShoppingCartBarButtonItem: BadgeableBarButtonItem {
  public override init() {
    super.init()
    
    addShoppingCartNotif()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    addShoppingCartNotif()
  }
  
  private func updateBadge() {
    let count = ShoppingCart.shared.count
    if count > 0 {
      setBadge("\(count)")
    } else {
      setBadge(nil)
    }
  }
  
  private func addShoppingCartNotif() {
    updateBadge()
    NotificationCenter.default.addObserver(forName: .didUpdateShoppingCart, object: nil, queue: .main) { [weak self] (_) in
      guard let `self` = self else { return }
      self.updateBadge()
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: .didUpdateShoppingCart, object: nil)
  }
}

public final class ShoppingCartItem: ProductProtocol, Equatable {
  public let productID: String
  public var quantity: Int
  public var product: Product? {
    return Product.getProduct(id: productID)
  }
  public var price: Double {
    return productVariation?.price ?? product?.price ?? 0.0
  }
  public let productVariation: ProductVariation?
  public let createdAt: Double
  
  public init(productID: String, productVariation: ProductVariation?) {
    self.productID = productVariation?.productID ?? productID
    self.productVariation = productVariation
    quantity = 1
    createdAt = Date().timeIntervalSince1970
  }
  
  public init?(data: JSON) {
    guard let productID = data.productID.string else { return nil }
    guard let quantity = data.quantity.int else { return nil }
    self.productID = productID
    self.productVariation = ProductVariation(data: data.productVariation)
    self.quantity = quantity
    createdAt = data.createdAt.doubleValue
  }
  
  public static func == (lhs: ShoppingCartItem, rhs: ShoppingCartItem) -> Bool {
    return lhs.productID == rhs.productID && lhs.productVariation == rhs.productVariation
  }
}

public struct ShoppingCoupon {
  public struct Cart {
    public var productID: String
    public var quantity: Int
    public var price: String?
    public var subtotal: String?
    public var total: String?
    
    public init?(data: JSON) {
      guard let productID = data.productID.numberString else { return nil }
      self.productID = productID
      quantity = data.quantity.intValue
      price = data.price.numberString
      total = data.total.numberString
      subtotal = data.subtotal.numberString
      total = data.total.numberString
    }
  }
  
  public enum ShippingDiscountType {
    case percentage(value: Double)
    case fixed(value: Double)
    
    init?(type: String, value: Double) {
      if type == "percent" {
        self = .percentage(value: value)
      } else if type == "fixed" {
        self = .fixed(value: value)
      } else {
        return nil
      }
    }
  }
  
  public var code: String
  public var isValid: Bool
  public var discountDollar: Double
  public var shippingDiscountType: ShippingDiscountType?
  public var cart: [Cart]?
  
  init?(data: JSON) {
    guard let couponCode = data.couponCode.string?.nsString.removingPercentEncoding else { return nil } //fix issue with api returning encoded coupon code
    code = couponCode
    isValid = data.isValid.boolValue
    discountDollar = data.discountDollar.doubleValue
    if let shippingShippingDiscountType = data.shippingDiscountType.string, let shippingDiscountValue = data.shippingDiscountValue.number?.doubleValue {
      shippingDiscountType = ShippingDiscountType(type: shippingShippingDiscountType, value: shippingDiscountValue)
    }
    if let cart = data.cart.array?.compactMap({ Cart(data: $0) }), !cart.isEmpty {
      self.cart = cart
    } else {
      cart = nil
    }
  }
}

public final class ShoppingCart {
  public static let shared = ShoppingCart()
  
  private init() {
    clean(propagate: false)
  }

  public var items: [ShoppingCartItem] = []
  
  public var count: Int {
    return items.map({ $0.quantity }).reduce(0, +)
  }
  
  public func addProduct(cartItem: ShoppingCartItem, quantity: Int = 1) {
    if let item = items.first(where: { $0 == cartItem }) {
      item.quantity += quantity
    } else {
      cartItem.quantity = quantity
      items.append(cartItem)
    }
    AppUserDefaults.cartItems = items
    NotificationCenter.default.post(name: .didUpdateShoppingCart, object: nil)
  }
  
  public func removeProduct(cartItem: ShoppingCartItem, quantity: Int = 1) {
    if let item = items.first(where: { $0 == cartItem }) {
      let newQuantity = max(0, cartItem.quantity - quantity)
      if newQuantity > 0 {
        item.quantity = newQuantity
      } else {
        items.removeAll(where: { $0 == cartItem })
      }
    }
    AppUserDefaults.cartItems = items
    NotificationCenter.default.post(name: .didUpdateShoppingCart, object: nil)
  }
  
  public func replaceProduct(cartItem: ShoppingCartItem, withCartItem: ShoppingCartItem) {
    guard let indx = items.index(of: cartItem) else { return } //find index
    items[indx] = withCartItem //replace
  }
  
  public func mergeIndenticalProductsIfNeeded() {
    var newItems: [ShoppingCartItem] = []
    items.forEach { (item) in
      if let currentNewItem = newItems.first(where: { $0 == item }) {
        currentNewItem.quantity += item.quantity
      } else {
        newItems.append(item)
      }
    }
    items = newItems
  }
  
  public func printAll() {
    print("================== SHOPPING CART ALL ITEMS ==================")
    for item in items {
      print(" --> \(item.productID)")
    }
    print("================== SHOPPING CART COUPONS ==================")
  }
  
  public func clean(propagate: Bool = true) {
    //should be not nil and in stock
    items = AppUserDefaults.cartItems.filter({ $0.product != nil && ($0.product?.inStock ?? false) })//filter out product
    if propagate {
      NotificationCenter.default.post(name: .didUpdateShoppingCart, object: nil)
    }
  }
  
  public func saveCart() {
    AppUserDefaults.cartItems = items
    NotificationCenter.default.post(name: .didUpdateShoppingCart, object: nil)
  }
  
  public func clearItems() {
    items = []
    AppUserDefaults.cartItems = []
    NotificationCenter.default.post(name: .didUpdateShoppingCart, object: nil)
  }
}

extension R4pidDefaultskey {
  fileprivate static let cartItems = R4pidDefaultskey(value: "797d5681181cba3df02728ce11179873")
}

extension AppUserDefaults {
  fileprivate static var cartItems: [ShoppingCartItem] {
    get {
      return JSON(parseJSON: R4pidDefaults.shared[.cartItems]?.string ?? "").arrayValue.compactMap({ ShoppingCartItem(data: $0) })
    }
    set {
      let cart = newValue.map { (cartItem) -> [String: Any] in
        var _cart: [String: Any] = [
          "product_id": cartItem.productID,
          "quantity": cartItem.quantity,
          "created_at": cartItem.createdAt]
        _cart["product_variation"] = cartItem.productVariation?.rawValue
        return _cart
      }
      R4pidDefaults.shared[.cartItems] = .init(value: JSON(cart).rawString() ?? "")
    }
  }
}

extension Notification.Name {
  public static let didUpdateShoppingCart = NSNotification.Name("didUpdateShoppingCart")
}

extension SimpleNotificationView {
  public struct Cart {
    public static var ids: [String] = []
    public static var isFinishedProcessing: Bool = true
    public static var cachedItem: ShoppingCartItem?
  }
  
  public static func discardCartItemWithUndo(cartItem: ShoppingCartItem, completion: VoidCompletion? = nil) {
    if !Cart.ids.isEmpty {
      hideIDs(Cart.ids)
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
        discardCartItemWithUndo(cartItem: cartItem, completion: completion)
      })
    } else {
      Cart.cachedItem = cartItem
      let messageView = SimpleNotificationView.viewFromNib(newLayout: .simpleNotificationView) as! SimpleNotificationView
      messageView.id = cartItem.productID
      Cart.ids.append(cartItem.productID)
      messageView.didTriggerWithID = { (trigger, id) in
        switch trigger {
        case .action:
          if let cachedItem = Cart.cachedItem {
            ShoppingCart.shared.addProduct(cartItem: cachedItem, quantity: cachedItem.quantity)
          }
          completion?()
        case .auto:
          Cart.cachedItem = nil
        }
        if let indx = Cart.ids.firstIndex(where: { $0 == id }) {
          Cart.ids.remove(at: indx)
        }
      }
      messageView.setContent(notification: "\(cartItem.productName ?? "Product") has been removed", action: "UNDO")
      messageView.setTheme(.undo)
      messageView.show()
    }
  }
  
  public static func showAddToCartNotification(productID: String, actionCompletion: @escaping VoidCompletion) {
    guard let product = Product.getProduct(id: productID) else { return }
    if !Cart.ids.isEmpty {
      hideIDs(Cart.ids)
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
        showAddToCartNotification(productID: productID, actionCompletion: actionCompletion)
      })
    } else {
      let messageView = SimpleNotificationView.viewFromNib(newLayout: .simpleNotificationView) as! SimpleNotificationView
      messageView.id = productID
      Cart.ids.append(productID)
      messageView.didTriggerWithID = { (trigger, id) in
        switch trigger {
        case .action:
          actionCompletion()
        case .auto: break
        }
        if let indx = Cart.ids.firstIndex(where: { $0 == id }) {
          Cart.ids.remove(at: indx)
        }
      }
      messageView.setContent(notification: "\(product.name ?? "Product") has been added to your cart", action: "VIEW CART")
      messageView.setTheme(.custom(backgroundColor: .gunmetal, foregroundColor: .white))
      messageView.show()
    }
  }
}
