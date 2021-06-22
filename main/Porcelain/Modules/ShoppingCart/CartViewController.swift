//
//  CartViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 2/22/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import SwipeCellKit

public protocol CartViewControllerDelegate: class {
  func cartViewControlletRemoveAddAllContents(viewController: CartViewController)
  func cartViewControllerCartItems(viewController: CartViewController) -> [ShoppingCartItem]
  func cartViewControllerDidSelectCoupon(viewController: CartViewController, coupon: ShoppingCoupon?)
  func cartViewControllerCoupon(viewController: CartViewController) -> ShoppingCoupon?
  func cartViewControllerShopCartNavigationTapped(viewController: CartViewController)
  func cartViewControllerShopCartNavigationType(viewController: CartViewController) -> ShopCartNavigationButton.AppearanceType?
}

public final class CartViewController: UIViewController {
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.setAutomaticDimension()
      tableView.registerWithNib(CartItemsTCell.self)
      tableView.backgroundColor = .whiteFive
      tableView.dataSource = self
      tableView.delegate = self
    }
  }
  @IBOutlet private weak var cartAmountSummaryView: CartAmountSummaryView!
  @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
  
  private var estimatedHeightDict: [String: CGFloat] = [:]
  private var cartItems: [ShoppingCartItem] = []
  
  public weak var delegate: CartViewControllerDelegate? {
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
    cartItems = delegate?.cartViewControllerCartItems(viewController: self).sorted(by: { $0.createdAt > $1.createdAt }) ?? []
    cartAmountSummaryView.cartItems = cartItems
    cartAmountSummaryView.shippingMethod = nil
    cartAmountSummaryView.coupon = delegate?.cartViewControllerCoupon(viewController: self)
    if let appearanceType = delegate?.cartViewControllerShopCartNavigationType(viewController: self) {
      cartAmountSummaryView.actionAppearanceType = appearanceType
    } else {
      cartAmountSummaryView.actionAppearanceType = .navigation(title: "GO TO SHIPPING ADDRESS", enabled: false)
    }
    tableView.reloadData()
  }
}

// MARK: - ControllerProtocol
extension CartViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("CartViewController segueIdentifier not set")
  }
  
  public func setupUI() {
    view.backgroundColor = .white
  }
  
  public func setupController() {
  }
  
  public func setupObservers() {
    observeKeyboard()
    cartAmountSummaryView.couponDidUpdate = { [weak self] in
      guard let `self` = self else { return }
      self.delegate?.cartViewControllerDidSelectCoupon(viewController: self, coupon: self.cartAmountSummaryView.coupon)
    }
    cartAmountSummaryView.actionDidTapped = { [weak self] in
      guard let `self` = self else { return }
      self.delegate?.cartViewControllerShopCartNavigationTapped(viewController: self)
    }
  }
}

// MARK: - UITableViewDataSource
extension CartViewController: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cartItems.count
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cartItemsTCell = tableView.dequeueReusableCell(CartItemsTCell.self, atIndexPath: indexPath)
    cartItemsTCell.cellDelegate = self
    cartItemsTCell.delegate = self
    cartItemsTCell.data = cartItems[indexPath.row]
    return cartItemsTCell
  }
}

// MARK: - UITableViewDelegate
extension CartViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return estimatedHeightDict[cartItems[indexPath.row].productID] ?? CartItemsTCell.defaultSize.height
  }
  
  public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    estimatedHeightDict[cartItems[indexPath.row].productID] = cell.contentView.bounds.height
  }
}

// MARK: - KeyboardHandlerProtocol
extension CartViewController: KeyboardHandlerProtocol {
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

// MARK: - SwipeTableViewCellDelegate
extension CartViewController: SwipeTableViewCellDelegate {
  public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    guard orientation == .right else { return nil }
    let deleteAction = SwipeAction(style: .destructive, title: "Remove") { [weak self] action, indexPath in
      guard let `self` = self else { return }
      let cartItem = self.cartItems[indexPath.row]
      ShoppingCart.shared.removeProduct(cartItem: cartItem, quantity: 9999)
      self.cartItems = self.delegate?.cartViewControllerCartItems(viewController: self).sorted(by: { $0.createdAt > $1.createdAt }) ?? []
      self.cartAmountSummaryView.cartItems = self.cartItems
      action.fulfill(with: .delete)
      self.cartAmountSummaryView.recalculateCouponIfNeeded()
      self.delegate?.cartViewControlletRemoveAddAllContents(viewController: self)
      SimpleNotificationView.discardCartItemWithUndo(cartItem: cartItem) {
        self.reload()
        self.cartAmountSummaryView.recalculateCouponIfNeeded()
        self.delegate?.cartViewControlletRemoveAddAllContents(viewController: self)
      }
    }
    deleteAction.image = UIImage.icDelete.maskWithColor(.white)
    return [deleteAction]
  }

  public func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
    var options = SwipeTableOptions()
    options.expansionStyle = .destructive(automaticallyDelete: true)
    options.backgroundColor = .coral
    return options
  }
}

// MARK: - CartItemsTCellDelegate
extension CartViewController: CartItemsTCellDelegate {
  public func cartItemsTCellWillRemoveProduct(item: ShoppingCartItem) {
    ShoppingCart.shared.removeProduct(cartItem: item, quantity: 9999)
    cartItems = delegate?.cartViewControllerCartItems(viewController: self) ?? []
    reload()
    cartAmountSummaryView.recalculateCouponIfNeeded()
    delegate?.cartViewControlletRemoveAddAllContents(viewController: self)
    SimpleNotificationView.discardCartItemWithUndo(cartItem: item) {
      self.reload()
      self.cartAmountSummaryView.recalculateCouponIfNeeded()
      self.delegate?.cartViewControlletRemoveAddAllContents(viewController: self)
    }
  }
  
  public func cartItemsTCellDidUpdateProduct(item: ShoppingCartItem) {
    reload()
    cartAmountSummaryView.recalculateCouponIfNeeded()
    delegate?.cartViewControlletRemoveAddAllContents(viewController: self)
  }
}
