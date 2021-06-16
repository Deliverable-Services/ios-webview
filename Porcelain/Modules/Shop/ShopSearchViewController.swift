//
//  ShopSearchViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 03/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import SwiftyJSON

public protocol ShopSearchSortProtocol {
  var sortKey: String { get }
}

extension Product: ShopSearchSortProtocol {
  public var sortKey: String {
    return name ?? ""
  }
}

extension Treatment: ShopSearchSortProtocol {
  public var sortKey: String {
    return displayName ?? name ?? ""
  }
}

public final class ShopSearchViewController: UIViewController {
  @IBOutlet private weak var bannerHeightConstraint: NSLayoutConstraint!
  @IBOutlet private weak var searchTextField: DesignableTextField! {
    didSet {
      searchTextField.leftEdgeInset = 16.0
      searchTextField.rightEdgeInset = 16.0
      searchTextField.tintColor = .white
      searchTextField.attributedPlaceholder = "Search".attributed.add([
        .color(.white),
        .font(.openSans(style: .regular(size: 14.0)))])
      let defaultAttr = NSAttributedString.createAttributesString([
        .color(.white),
        .font(.openSans(style: .regular(size: 14.0))),
        .underlineStyle(.styleSingle)])
      searchTextField.defaultTextAttributes = defaultAttr
      searchTextField.typingAttributes = defaultAttr
      searchTextField.backgroundColor = UIColor.white.withAlphaComponent(0.3)
      searchTextField.delegate = self
    }
  }
  @IBOutlet private weak var dismissButton: UIButton! {
    didSet {
      dismissButton.setAttributedTitle(
        "Cancel".attributed.add([
          .color(.white),
          .font(.openSans(style: .semiBold(size: 14.0)))]),
        for: .normal)
    }
  }
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.setAutomaticDimension()
      tableView.separatorColor = .whiteThree
      tableView.registerWithNib(ShopRecentSearchTCell.self)
      tableView.dataSource = self
      tableView.delegate = self
    }
  }
  
  fileprivate var didSelectItem: ((ShopSearchSortProtocol) -> Void)?
  fileprivate var didCancel: VoidCompletion?
  private var contents: [ShopSearchSortProtocol] = []
  
  private var isRecentSearchAvailable: Bool {
    return (searchTextField.text?.isEmpty ?? true) && !ShopSearchDefaults.recentSearches.isEmpty
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  
    searchTextField.becomeFirstResponder()
  }
  
  private func searchText(_ search: String?) {
    var productsPredicates: [CoreDataRecipe.Predicate] = [.isEqual(key: "isActive", value: true)]
    var treatmentsPredicates: [CoreDataRecipe.Predicate] = []
    if let searches = search?.components(separatedBy: " ") {
      searches.forEach { (search) in
        productsPredicates.append(.contains(key: "name", value: search))
        treatmentsPredicates.append(.contains(key: "name", value: search))
      }
    }
    var searchContents: [ShopSearchSortProtocol] = []
    let products = CoreDataUtil.list(
      Product.self,
      predicate: .compoundAnd(predicates: productsPredicates),
      sorts: [.custom(key: "name", isAscending: true)])
    searchContents.append(contentsOf: products)
    let treatments = CoreDataUtil.list(
      Treatment.self,
      predicate: .compoundAnd(predicates: treatmentsPredicates),
      sorts: [.custom(key: "name", isAscending: true)])
    searchContents.append(contentsOf: treatments)
    contents = searchContents
    tableView.reloadData()
  }
  
  public override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  public override func popOrDismissViewController() {
    didCancel?()
    super.popOrDismissViewController()
  }
  
  @IBAction private func searchTextEditingChanged(_ sender: Any) {
    searchText(searchTextField.text)
  }
}

// MARK: - ControllerProtocol
extension ShopSearchViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("ShopSearchViewController segueIdentifier not set")
  }
  
  public func setupUI() {
    if let topInset = UIApplication.shared.keyWindow?.safeAreaInsets.top {
      bannerHeightConstraint.constant = topInset + 44.0 + 16.0
    } else {
      bannerHeightConstraint.constant = 118.0
    }
  }
  
  public func setupController() {
  }
  
  public func setupObservers() {
    observeKeyboard()
  }
}

// MARK: - KeyboardHandlerProtocol
extension ShopSearchViewController: KeyboardHandlerProtocol {
  public func keyboardWillHide(_ notification: Notification) {
    tableView.contentInset = .zero
  }
  
  public func keyboardWillShow(_ notification: Notification) {
    let height = evaluateKeyboardFrameFromNotification(notification).height - (tabBarController?.tabBar.bounds.height ?? 0)
    tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: height, right: 0.0)
  }
}

// MARK: - UITextFieldDelegate
extension ShopSearchViewController: UITextFieldDelegate {
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
}

// MARK: - UITableViewDataSource
extension ShopSearchViewController: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isRecentSearchAvailable {
      return ShopSearchDefaults.recentSearches.count
    } else {
      return contents.count
    }
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let shopRecentSearchTCell = tableView.dequeueReusableCell(ShopRecentSearchTCell.self, atIndexPath: indexPath)
    if isRecentSearchAvailable {
      let recentSearch = ShopSearchDefaults.recentSearches[indexPath.row]
      shopRecentSearchTCell.title = recentSearch.title
    } else {
      if let product = contents[indexPath.row] as? Product {
        shopRecentSearchTCell.title = [product.categoryName, product.name].compactMap({ $0 }).joined(separator: ", ")
      } else if let treatment = contents[indexPath.row] as? Treatment {
        shopRecentSearchTCell.title = [treatment.categoryName, treatment.name].compactMap({ $0 }).joined(separator: ", ")
      } else {
        shopRecentSearchTCell.title = nil
      }
    }
    return shopRecentSearchTCell
  }
}

// MARK: - UITableViewDelegate
extension ShopSearchViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if isRecentSearchAvailable {
      if let product = ShopSearchDefaults.recentSearches[indexPath.row].product {
        didSelectItem?(product)
      } else if let treatment = ShopSearchDefaults.recentSearches[indexPath.row].treatment {
        didSelectItem?(treatment)
      }
    } else {
      if let product = contents[indexPath.row] as? Product {
        ShopSearchDefaults.recentSearches.insert(RecentSearchData(
          title: [product.categoryName, product.name].compactMap({ $0 }).joined(separator: ", "),
          productID: product.id,
          treatmentID: nil), at: 0)
      } else if let treatment = contents[indexPath.row] as? Treatment {
        ShopSearchDefaults.recentSearches.insert(RecentSearchData(
          title: [treatment.categoryName, treatment.name].compactMap({ $0 }).joined(separator: ", "),
          productID: nil,
          treatmentID: treatment.serviceID), at: 0)
      }
      didSelectItem?(contents[indexPath.row])
    }
    dismissViewController()
  }
  
  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard isRecentSearchAvailable else { return nil }
    let recentSearchView = UIButton()
    recentSearchView.isUserInteractionEnabled = false
    recentSearchView.contentHorizontalAlignment = .left
    recentSearchView.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
    recentSearchView.backgroundColor = .white
    recentSearchView.setAttributedTitle(
      "RECENT SEARCH".attributed.add([
        .color(.gunmetal),
        .font(.openSans(style: .semiBold(size: 14.0)))]),
      for: .normal)
    let stack = UIStackView()
    stack.distribution = .fill
    stack.axis = .vertical
    stack.addArrangedSubview(recentSearchView)
    let separatorView = UIView()
    separatorView.backgroundColor = .whiteThree
    separatorView.addHeightConstraint(1.0)
    stack.addArrangedSubview(separatorView)
    return stack
  }
  
  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard isRecentSearchAvailable else { return .leastNonzeroMagnitude }
    return 60.0
  }
  
  public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return .leastNonzeroMagnitude
  }
}

extension R4pidDefaultskey {
  fileprivate static var recentSearches: R4pidDefaultskey {
    return .init(value: "723E605A8C45CF1F647E9C1F451C4729470A88D9844B\(AppUserDefaults.customerID ?? "")")
  }
}

private struct RecentSearchData {
  var title: String?
  var productID: String?
  var treatmentID: String?
  
  init?(data: JSON) {
    guard let title = data.title.string else { return nil }
    self.title = title
    productID = data.productID.string
    treatmentID = data.treatmentID.string
  }
  
  init(title: String, productID: String?, treatmentID: String?) {
    self.title = title
    self.productID = productID
    self.treatmentID = treatmentID
  }
  
  var product: Product? {
    guard let productID = productID else { return nil }
    return Product.getProduct(id: productID)
  }
  
  var treatment: Treatment? {
    guard let treatmentID = treatmentID else { return nil }
    return Treatment.getTreatment(id: treatmentID)
  }
}

private struct ShopSearchDefaults {
  private init() {
  }
  
  static var recentSearches: [RecentSearchData] {
    get {
      return JSON(parseJSON: R4pidDefaults.shared[.recentSearches]?.string ?? "").arrayValue.compactMap({ RecentSearchData(data: $0) })
    }
    set {
      R4pidDefaults.shared[.recentSearches] = .init(
        value: JSON(newValue.prefix(10).map({ [
          "title": $0.title,
          "product_id": $0.productID,
          "treatment_id": $0.treatmentID]})).rawString())
    }
  }
}

public protocol ShopSearchPresenterProtocol {
  func shopSearchDidSelectProduct(_ product: Product)
  func shopSearchDidSelectTreatment(_ treatment: Treatment)
  func shopSearchDidCancel()
}

extension ShopSearchPresenterProtocol where Self: ControllerProtocol & UIViewController {
  public func showShopSearch() {
    let shopSearchViewController = UIStoryboard.get(.shop).getController(ShopSearchViewController.self)
    shopSearchViewController.didSelectItem = { [weak self] (item) in
      guard let `self` = self else { return }
      if let product = item as? Product {
        self.shopSearchDidSelectProduct(product)
      } else if let treatment = item as? Treatment {
        self.shopSearchDidSelectTreatment(treatment)
      }
    }
    shopSearchViewController.didCancel = { [weak self] in
      guard let `self` = self else { return }
      self.shopSearchDidCancel()
    }
    present(shopSearchViewController, animated: true)
  }
}
