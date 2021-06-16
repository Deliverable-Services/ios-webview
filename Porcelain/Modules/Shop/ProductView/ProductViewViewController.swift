//
//  ProductViewViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 3/9/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public protocol ProductViewViewControllerDelegate: class {
}

public final class ProductViewViewController: UIViewController {
  @IBOutlet private weak var scrollView: UIScrollView! {
    didSet {
      scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 80.0, right: 0.0)
      scrollView.delegate = self
    }
  }
  @IBOutlet private weak var headerView: ProductViewHeaderView!
  @IBOutlet private weak var segmentedContainerView: UIView!
  @IBOutlet private weak var segmentedControl: DesignableSegmentedControl!
  @IBOutlet private weak var contentDetailsWebView: ResizingContentWebView!
  @IBOutlet private weak var tableView: ResizingContentTableView! {
    didSet {
      tableView.setAutomaticDimension()
      tableView.registerWithNib(ProductReviewsTCell.self)
      tableView.dataSource = self
      tableView.delegate = self
    }
  }
  @IBOutlet private weak var maxDetailsHeightConstraint: NSLayoutConstraint!
  @IBOutlet private weak var maxReviewsHeightConstraint: NSLayoutConstraint!
  @IBOutlet private weak var actionButton: DesignableButton! {
    didSet {
      actionButton.cornerRadius = 7.0
    }
  }
  
  private var addToBasketEnabled: Bool = true {
    didSet {
      actionButton.isUserInteractionEnabled = addToBasketEnabled
      actionButton.backgroundColor = addToBasketEnabled ? .greyblue: .whiteThree
      actionButton.setAttributedTitle(
        "ADD TO BASKET".attributed.add([
          .color(addToBasketEnabled ? .white: .bluishGrey),
          .font(.idealSans(style: .book(size: 14.0)))]),
        for: .normal)
    }
  }
  
  private var estimatedHeightDict: [String: CGFloat] = [:]
  
  fileprivate var viewModel: ProductViewViewModelProtocol!
  fileprivate weak var delegate: ProductViewViewControllerDelegate?
  private lazy var cartBarButton = ShoppingCartBarButtonItem(image: .icCart, style: .plain, target: self, action: #selector(cartTapped(_:)))
  
  private var newY: CGFloat = 0 {
    didSet {
      isActionShown = newY < 24.0
      guard oldValue != newY else { return }
      segmentedContainerView.transform = .init(translationX: 0.0, y: newY)
    }
  }
  
  private var isActionShown: Bool = true {
    didSet {
      guard oldValue != isActionShown else { return }
      let actionAlpha: CGFloat = isActionShown ? 1.0: 0.0
      UIView.animate(withDuration: 0.3) {
        self.actionButton.alpha = actionAlpha
      }
    }
  }
  
  private var scrollViewHeight: CGFloat = 0.0 {
    didSet {
      guard oldValue != scrollViewHeight else { return }
      maxDetailsHeightConstraint.constant = scrollViewHeight - (48.0 + 104.0)
      maxReviewsHeightConstraint.constant = scrollViewHeight - (48.0 + 104.0)
    }
  }
  
  private lazy var frcHandler = FetchResultsControllerHandler<Review>(type: .tableView(tableView))
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    setStatusBarNav(style: .default)
    hideBarSeparator()
  }
  
  private func updateYSegment() {
    newY = max(0.0, (headerView.bounds.height - 80.0) - scrollView.contentOffset.y)
  }
  
  private func updateActionButton() {
    switch viewModel.section {
    case .about:
      addToBasketEnabled = headerView.addToBasketEnabled
    case .reviews:
      actionButton.isUserInteractionEnabled = true
      actionButton.backgroundColor = .greyblue
      actionButton.setAttributedTitle(
        "ADD A REVIEW".attributed.add([.color(.white), .font(.idealSans(style: .book(size: 14.0)))]),
        for: .normal)
    }
  }
  
  @objc
  private func cartTapped(_ sender: Any) {
    showShopCart()
  }
  
  @IBAction private func segmentValueChanged(_ sender: DesignableSegmentedControl) {
    guard let newSection = ProductViewSection(rawValue: sender.selectedSegmentIndex) else { return }
    viewModel.section = newSection
    viewModel.initialize()
  }
  
  @IBAction private func actionTapped(_ sender: DesignableButton) {
    switch viewModel.section {
    case .about:
      guard let productID = viewModel.product.id else { return }
      ShoppingCart.shared.addProduct(cartItem: ShoppingCartItem(productID: productID, productVariation: headerView.productVariation))
      SimpleNotificationView.showAddToCartNotification(productID: productID) {
        self.showShopCart()
      }
    case .reviews:
      showMakeReview(type: .productReview(product: viewModel.product))
    }
  }
}

// MARK: - NavigationProtocol
extension ProductViewViewController: NavigationProtocol {
}

// MARK: - ShopCartPresenterProtocol
extension ProductViewViewController: ShopCartPresenterProtocol {
}

// MARK: - MakeReviewPresenterProtocol
extension ProductViewViewController: MakeReviewPresenterProtocol {
}

// MARK: - ControllerProtocol
extension ProductViewViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("ProductViewViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: .icLeftArrow, selector: #selector(popOrDismissViewController))
    generateRightNavigationButtons([cartBarButton])
    viewModel.attachView(self)
    viewModel.initialize()
  }
  
  public func setupObservers() {
    observeKeyboard()
    headerView.didUpdateBasket = { [weak self] in
      guard let `self` = self else { return }
      self.updateActionButton()
    }
    headerView.addToBasketDidTapped = { [weak self] in
      guard let `self` = self else { return }
      guard let productID = self.viewModel.product.id else { return }
      ShoppingCart.shared.addProduct(cartItem: ShoppingCartItem(productID: productID, productVariation: self.headerView.productVariation))
      SimpleNotificationView.showAddToCartNotification(productID: productID) {
        self.showShopCart()
      }
    }
  }
}

// MARK: - ProductViewView
extension ProductViewViewController: ProductViewView {
  public func reload() {
    headerView.hasError = viewModel.hasError
    headerView.data = ProductViewHeaderData(product: viewModel.product, availableVariations: viewModel.availableVariations)
    switch viewModel.section {
    case .about:
      contentDetailsWebView.isHidden = false
      tableView.isHidden = true
      contentDetailsWebView.loadHTMLString(viewModel.htmlString ?? "No Content", baseURL: nil)
    case .reviews:
      contentDetailsWebView.isHidden = true
      tableView.isHidden = false
      frcHandler.reload(recipe: viewModel.reviewsRecipe)
    }
    updateActionButton()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.updateYSegment()
    }
  }
  
  public func showLoading() {
    appDelegate.showLoading()
  }
  
  public func hideLoading() {
    appDelegate.hideLoading()
  }
  
  public func showError(message: String?) {
    showAlert(title: "Oops!", message: message)
  }
}

// MARK: - UITableViewDataSource
extension ProductViewViewController: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return frcHandler.numberOfObjectsInSection(section)
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let productReviewsTCell = tableView.dequeueReusableCell(ProductReviewsTCell.self, atIndexPath: indexPath)
    productReviewsTCell.review = frcHandler.object(at: indexPath)
    return productReviewsTCell
  }
}

// MARK: - UITableViewDelegate
extension ProductViewViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return estimatedHeightDict["\(indexPath.row)"] ?? 20.0
  }
  
  public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    estimatedHeightDict["\(indexPath.row)"] = cell.contentView.bounds.height
  }
}

// MARK: - UIScrollViewDelegate
extension ProductViewViewController: UIScrollViewDelegate {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    updateYSegment()
    scrollViewHeight = scrollView.bounds.height
  }
}

// MARK: - KeyboardHandlerProtocol
extension ProductViewViewController: KeyboardHandlerProtocol {
  public func keyboardWillHide(_ notification: Notification) {
    scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 80.0, right: 0.0)
  }
  
  public func keyboardWillShow(_ notification: Notification) {
    scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: evaluateKeyboardFrameFromNotification(notification).height, right: 0.0)
  }
}

public protocol ProductViewPresenterProtocol: ProductViewViewControllerDelegate {
}

extension ProductViewPresenterProtocol where Self: ControllerProtocol & UIViewController {
  public func showProductView(product: Product, animated: Bool = true) {
    let newProductViewViewController = UIStoryboard.get(.shop).getController(ProductViewViewController.self)
    newProductViewViewController.viewModel = ProductViewViewModel(product: product)
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(newProductViewViewController, animated: true)
    } else {
      let navigationController = NavigationController(rootViewController: newProductViewViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
  }
}
