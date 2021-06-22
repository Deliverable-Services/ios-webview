//
//  PurchaseViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 29/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class PurchasesViewController: UIViewController, RefreshHandlerProtocol, EmptyNotificationActionIndicatorProtocol {
  public var refreshControl: UIRefreshControl?
  
  public var refreshScrollView: UIScrollView?
  
  public var emptyNotificationActionView: EmptyNotificationActionView? {
    didSet {
      emptyNotificationActionView?.backgroundColor = .whiteFive
    }
  }
  
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 12.0, right: 0.0)
      tableView.setAutomaticDimension()
      tableView.registerWithNib(PurchasesTCell.self)
      tableView.dataSource = self
      tableView.delegate = self
    }
  }
  
  private lazy var frcHandler = FetchResultsControllerHandler<Purchase>(type: .tableView(tableView), sectionKey: "monthYear")
  
  private var estimatedHeightDict: [String: CGFloat] = [:]
  
  public var emptyNotificationActionData: EmptyNotificationActionData? {
    didSet {
      if let emptyNotificationActionData = emptyNotificationActionData  {
        showEmptyNotificationActionOnView(view, type: .centered(data: emptyNotificationActionData))
      } else {
        hideEmptyNotificationAction()
      }
    }
  }
  
  private var orderReceivedData: OrderReceivedData?
  private var orderReceivedTitle: String?
  
  private lazy var viewModel: PurchasesViewModelProtocol = PurchasesViewModel(view: self)
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public func refreshControlDidRefresh(_ refreshControl: UIRefreshControl) {
    viewModel.initialize()
  }
  
  public func emptyNotificationActionTapped(data: EmptyNotificationActionData) {
    navigationController?.popViewController(animated: false)
    appDelegate.mainView.goToTab(.shop)?.getChildController(ShopViewController.self)?.showSection(.products)
  }
}

// MARK: - NavigationProtocol
extension PurchasesViewController: NavigationProtocol {
}

// MARK: - ShopCartPresenterProtocol
extension PurchasesViewController: ShopCartPresenterProtocol {
}

// MARK: - LeaveAFeedbackPresenterProtocol
extension PurchasesViewController: LeaveAFeedbackPresenterProtocol {
}

// MARK: - ControllerProtocol
extension PurchasesViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    return "showPurchase"
  }
  
  public func setupUI() {
    view.backgroundColor = .whiteFive
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: .icLeftArrow, selector: #selector(popViewController))
    viewModel.initialize()
  }
  
  public func setupObservers() {
    observeRefresh(scrollView: tableView)
  }
}

// MARK: - PurchaseView
extension PurchasesViewController: PurchasesView {
  public func reload() {
    frcHandler.reload(recipe: viewModel.recipe)
  }
  
  public func showLoading() {
    if frcHandler.numberOfObjectsInSection(0) == 0 {
      startRefreshing()
    }
  }
  
  public func hideLoading() {
    endRefreshing()
    emptyNotificationActionData = viewModel.emptyNotificationActionData
  }
  
  public func showError(message: String?) {
    showAlert(title: "Oops!", message: message)
  }
}

// MARK: - UITableViewDataSource
extension PurchasesViewController: UITableViewDataSource {
  public func numberOfSections(in tableView: UITableView) -> Int {
    return frcHandler.sections?.count ?? 0
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return frcHandler.numberOfObjectsInSection(section)
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let purchasesCell = tableView.dequeueReusableCell(PurchasesTCell.self, atIndexPath: indexPath)
    purchasesCell.purchase = frcHandler.object(at: indexPath)
    purchasesCell.orderAgainDidTapped = { [weak self] (purchase) in
      guard let `self` = self else { return }
      purchase.purchasedItems?.forEach { (item) in
        guard let productID = item.productID else { return }
        ShoppingCart.shared.addProduct(cartItem: ShoppingCartItem(productID: productID, productVariation: purchase.productVariations?.first(where: { $0.id == item.variationID })))
      }
      self.showShopCart()
    }
    purchasesCell.leaveFeedbackDidTapped = { [weak self] (purchase) in
      guard let `self` = self else { return }
      self.showLeaveAFeedback(type: .purchase(purchase))
    }
    return purchasesCell
  }
}

// MARK: - UITableViewDelegate
extension PurchasesViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let purchase = frcHandler.object(at: indexPath)
    guard let purchaseOrderID = purchase.wcOrderID else { return }
    orderReceivedTitle = purchase.purchaseStatus?.title.uppercased()
    orderReceivedData = nil
    appDelegate.showLoading()
    PPAPIService.User.getPurchaseDetails(wcOrderID: purchaseOrderID).call { (response) in
      switch response {
      case .success(let result):
        appDelegate.hideLoading()
        if let orderReceivedData = OrderReceivedData(data: result.data) {
          self.orderReceivedData = orderReceivedData
          self.showOrderReceived()
        } else {
          self.showError(message: "Order details could not be retrieved.")
        }
      case .failure(let error):
        appDelegate.hideLoading()
        self.showError(message: error.localizedDescription)
      }
    }
  }
  
  public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return estimatedHeightDict["\(indexPath.row)"] ?? PurchasesTCell.defaultSize.height
  }
  
  public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    estimatedHeightDict["\(indexPath.row)"] = cell.bounds.height
  }
  
  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard frcHandler.numberOfObjectsInSection(section) > 0 else { return nil }
    let headerView = UIButton()
    headerView.isUserInteractionEnabled = false
    headerView.contentHorizontalAlignment = .left
    headerView.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
    headerView.backgroundColor = .whiteFive
    let title = frcHandler.object(at: IndexPath(row: 0, section: section)).monthYear?.toString(WithFormat: "MMMM yyyy")
    headerView.setAttributedTitle(title?.attributed.add([.color(.gunmetal), .font(.idealSans(style: .book(size: 16.0)))]), for: .normal)
    return headerView
  }
  
  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard frcHandler.numberOfObjectsInSection(section) > 0 else { return .leastNonzeroMagnitude }
    return 52.0
  }
}

// MARK: - OrderReceivedPresenterProtocol
extension PurchasesViewController: OrderReceivedPresenterProtocol {
  public func orderReceivedViewControllerTitle(viewController: OrderReceivedViewController) -> String {
    return orderReceivedTitle ?? ""
  }
  
  public func orderReceivedViewControllerData(viewController: OrderReceivedViewController) -> OrderReceivedData? {
    return orderReceivedData
  }
  
  public func orderReceivedViewControllerNavigationTapped(viewController: OrderReceivedViewController) {
    viewController.popOrDismissViewController()
  }
  
  public func orderReceivedViewControllerNavigationType(viewController: OrderReceivedViewController) -> ShopCartNavigationButton.AppearanceType? {
    return nil
  }
}

public protocol PurchasePresenterProtocol {
}

extension PurchasePresenterProtocol where Self: ControllerProtocol & UIViewController {
  public func showPurchases(animated: Bool = true) {
    let purchasesViewController = UIStoryboard.get(.profile).getController(PurchasesViewController.self)
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(purchasesViewController, animated: animated)
    } else {
      let navigationController = NavigationController(rootViewController: purchasesViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
  }
}

