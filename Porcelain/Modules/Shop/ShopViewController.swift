//
//  ShopViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 19/08/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class ShopViewController: UIViewController, EmptyNotificationActionIndicatorProtocol {
  @IBOutlet private weak var bannerHeightConstraint: NSLayoutConstraint!
  @IBOutlet private weak var segmentedControl: DesignableSegmentedControl!
  @IBOutlet private weak var contentView: UIView!
  @IBOutlet private weak var productsTableView: RefreshingTableView! {
    didSet {
      productsTableView.contentInset = UIEdgeInsets(top: 24.0, left: 0.0, bottom: 0.0, right: 0.0)
      productsTableView.setAutomaticDimension()
      productsTableView.registerWithNib(ProductsSectionTCell.self)
      productsTableView.dataSource = self
      productsTableView.delegate = self
    }
  }
  @IBOutlet private weak var treatmentsTableView: RefreshingTableView! {
    didSet {
      treatmentsTableView.contentInset = UIEdgeInsets(top: 24.0, left: 0.0, bottom: 0.0, right: 0.0)
      treatmentsTableView.setAutomaticDimension()
      treatmentsTableView.registerWithNib(TreatmentsSectionTCell.self)
      treatmentsTableView.dataSource = self
      treatmentsTableView.delegate = self
    }
  }
  
  private lazy var searchBarButton = BadgeableBarButtonItem(image: .icSearch, style: .plain, target: self, action: #selector(searchTapped(_:)))
  private lazy var cartBarButton = ShoppingCartBarButtonItem(image: .icCart, style: .plain, target: self, action: #selector(cartTapped(_:)))
  
  public var emptyNotificationActionView: EmptyNotificationActionView?
  
  public var emptyNotificationActionData: EmptyNotificationActionData? {
    didSet {
      if let emptyNotificationActionData = emptyNotificationActionData  {
        showEmptyNotificationActionOnView(contentView, type: .margin(data: emptyNotificationActionData))
      } else {
        hideEmptyNotificationAction()
      }
    }
  }
  
  private var section: ShopSection = .products
  private lazy var viewModel: ShopViewModelProtocol = ShopViewModel()
  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    if let navBarFrame = navigationController?.navigationBar.frame {
      let newBannerHeight = navBarFrame.origin.y + navBarFrame.height + 16.0
      guard bannerHeightConstraint.constant != newBannerHeight else { return }
      bannerHeightConstraint.constant = newBannerHeight
    } else {
      bannerHeightConstraint.constant = 118.0
    }
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    setStatusBarNav(style: .lightContent)
    hideBarSeparator()
    navigationController?.navigationBar.isTranslucent = true
    navigationController?.navigationBar.backgroundColor = .clear
    segmentedControl.selectedSegmentIndex = section.rawValue
    updateShopSection(reload: false)
  }
  
  public func showSection(_ section: ShopSection) {
    self.section = section
    guard segmentedControl != nil,
      segmentedControl.selectedSegmentIndex != section.rawValue else { return }
    segmentedControl.selectedSegmentIndex = section.rawValue
    updateShopSection(reload: true)
  }
  
  private func updateShopSection(reload: Bool) {
    section = ShopSection(rawValue: segmentedControl.selectedSegmentIndex)!
    switch section {
    case .products:
      productsTableView.isHidden = false
      treatmentsTableView.isHidden = true
      if reload || viewModel.productSections.isEmpty {
        viewModel.initializeProducts()
      }
    case .treatments:
      productsTableView.isHidden = true
      treatmentsTableView.isHidden = false
      if reload || viewModel.treatmentSections.isEmpty {
        viewModel.initializeTreatments()
      }
    }
  }
  
  @objc
  private func searchTapped(_ sender: Any) {
    showShopSearch()
  }
  
  @objc
  private func cartTapped(_ sender: Any) {
    showShopCart()
  }
  
  @IBAction private func shopSegmentValueChanged(_ sender: DesignableSegmentedControl) {
    updateShopSection(reload: false)
  }
  
  public func emptyNotificationActionTapped(data: EmptyNotificationActionData) {
    switch ShopSection(rawValue: segmentedControl.selectedSegmentIndex)! {
    case .products:
      viewModel.initializeProducts()
    case .treatments:
      viewModel.initializeTreatments()
    }
  }
}

// MARK: - NavigationProtocol
extension ShopViewController: NavigationProtocol {
  public var barButtonColor: UIColor? {
    return .white
  }
}

// MARK: - ShopSearchPresenterProtocol
extension ShopViewController: ShopSearchPresenterProtocol {
  public func shopSearchDidSelectProduct(_ product: Product) {
    showProductView(product: product)
  }
  
  public func shopSearchDidSelectTreatment(_ treatment: Treatment) {
    showTreatment(treatment)
  }
  
  public func shopSearchDidCancel() {
  }
}

// MARK: - CartPresenterProtocol
extension ShopViewController: ShopCartPresenterProtocol {
}

// MARK: - TreatmentPresenterProtocol
extension ShopViewController: TreatmentPresenterProtocol {
}

// MARK: - ControllerProtocol
extension ShopViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("ShopViewController segueIdentifier not set")
  }
  
  public func setupUI() {
    view.backgroundColor = .whiteFive
  }
  
  public func setupController() {
    generateRightNavigationButtons([cartBarButton, searchBarButton])
    viewModel.attachView(self)
    viewModel.initialize()
  }
  
  public func setupObservers() {
    productsTableView.didRefresh = { [weak self] in
      guard let `self` = self else { return }
      self.viewModel.initializeProducts()
    }
    treatmentsTableView.didRefresh = { [weak self] in
      guard let `self` = self else { return }
      self.viewModel.initializeTreatments()
    }
  }
}

// MARK: - ShopView
extension ShopViewController: ShopView {
  public func reload(section: ShopSection) {
    emptyNotificationActionData = viewModel.emptyNotificationActionData
    productsTableView.isHidden = ShopSection(rawValue: segmentedControl.selectedSegmentIndex) != .products
    treatmentsTableView.isHidden = ShopSection(rawValue: segmentedControl.selectedSegmentIndex) != .treatments
    switch section {
    case .products:
      productsTableView.reloadData()
    case .treatments:
      treatmentsTableView.reloadData()
    }
  }
  
  public func showLoading(section: ShopSection) {
    switch section {
    case .products:
      productsTableView.startRefreshing()
    case .treatments:
      treatmentsTableView.startRefreshing()
    }
  }
  
  public func hideLoading(section: ShopSection) {
    switch section {
    case .products:
      productsTableView.endRefreshing()
    case .treatments:
      treatmentsTableView.endRefreshing()
    }
  }
  
  public func showError(message: String?) {
    showAlert(title: "Oops!", message: message)
  }
}

// MARK: - UICollectionViewDataSource
extension ShopViewController: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == productsTableView {
      return viewModel.productSections.count
    } else if tableView == treatmentsTableView {
      return viewModel.treatmentSections.count
    } else {
      return 0
    }
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if tableView == productsTableView {
      let productsSectionTCell = tableView.dequeueReusableCell(ProductsSectionTCell.self, atIndexPath: indexPath)
      productsSectionTCell.data = viewModel.productSections[indexPath.row]
      productsSectionTCell.didSelectProduct = { [weak self] (product) in
        guard let `self` = self else { return }
        self.showProductView(product: product)
      }
      return productsSectionTCell
    } else if tableView == treatmentsTableView {
      let treatmentsSectionTCell = tableView.dequeueReusableCell(TreatmentsSectionTCell.self, atIndexPath: indexPath)
      treatmentsSectionTCell.data = viewModel.treatmentSections[indexPath.row]
      treatmentsSectionTCell.didSelectTreatment = { [weak self] (treatment) in
        guard let `self` = self else { return }
        self.showTreatment(treatment)
      }
      return treatmentsSectionTCell
    } else {
      fatalError("not possible")
    }
  }
}

// MARK: - UITableViewDelegate
extension ShopViewController: UITableViewDelegate {
}

// MARK: - ProductViewPresenterProtocol
extension ShopViewController: ProductViewPresenterProtocol {
  
}

public final class RefreshingTableView: UITableView, RefreshHandlerProtocol {
  public override var refreshControl: UIRefreshControl? {
    didSet {
      refreshControl?.tintColor = .lightNavy
    }
  }
  
  public var refreshScrollView: UIScrollView?
  
  public var didRefresh: VoidCompletion? {
    didSet {
      guard didRefresh != nil else { return }
      observeRefresh(scrollView: self)
    }
  }
  
  public func refreshControlDidRefresh(_ refreshControl: UIRefreshControl) {
    didRefresh?()
  }
}
