//
//  CreditCardViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 08/08/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public protocol CreditCardViewControllerDelegate: class {
  func creditCardViewControllerAllowsDelete(viewController: CreditCardViewController) -> Bool
  func creditCardViewControllerAllowsSelection(viewController: CreditCardViewController) -> Bool
  func creditCardViewControllerTitle(viewController: CreditCardViewController) -> String
  func creditCardViewControllerDidSelect(viewController: CreditCardViewController, card: Card, action: Bool)
  func creditCardViewControllerCard(viewController: CreditCardViewController) -> Card?
  func creditCardViewControllerShopCartNavigationTapped(viewController: CreditCardViewController)
  func creditCardViewControllerShopCartNavigationType(viewController: CreditCardViewController) -> ShopCartNavigationButton.AppearanceType?
}

public final class CreditCardViewController: UIViewController, RefreshHandlerProtocol, EmptyNotificationActionIndicatorProtocol {
  public var refreshControl: UIRefreshControl?
  
  public var refreshScrollView: UIScrollView?
  
  public var emptyNotificationActionView: EmptyNotificationActionView? {
    didSet {
      emptyNotificationActionView?.backgroundColor = .whiteFive
      view.bringSubview(toFront: contentStack)
    }
  }
  
  @IBOutlet private weak var contentStack: UIStackView!
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.setAutomaticDimension()
      tableView.registerWithNib(CreditCardTCell.self)
      tableView.backgroundColor = .whiteFive
      tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 8.0, right: 0.0)
      tableView.dataSource = self
      tableView.delegate = self
    }
  }
  @IBOutlet private weak var headerView: UIView!
  @IBOutlet private weak var addNewCardButton: DesignableButton! {
    didSet {
      addNewCardButton.setAttributedTitle(
        UIImage.icAddNewCard.maskWithColor(.white).attributed.append(
          attrs: "  ADD NEW CARD".attributed.add([
            .color(.white),
            .font(.idealSans(style: .book(size: 14.0))),
            .baseline(offset: 5.0)])),
        for: .normal)
      var appearance = ShadowAppearance.default
      appearance.fillColor = .lightNavy
      addNewCardButton.shadowAppearance = appearance
    }
  }
  @IBOutlet private weak var bottomActionContainerView: UIView! {
    didSet {
      bottomActionContainerView.backgroundColor = .whiteFive
    }
  }
  @IBOutlet private weak var bottomActionButton: ShopCartNavigationButton!
  
  public var emptyNotificationActionData: EmptyNotificationActionData? {
    didSet {
      if let emptyNotificationActionData = emptyNotificationActionData {
        showEmptyNotificationActionOnView(view, type: .centered(data: emptyNotificationActionData))
      } else {
        hideEmptyNotificationAction()
      }
    }
  }
  
  private var allowsDelete: Bool = true
  
  private lazy var frcHandler = FetchResultsControllerHandler<Card>(type: .tableView(tableView))
  private lazy var viewModel: CreditCardViewModelProtocol = CreditCardViewModel()
  
  fileprivate weak var delegate: CreditCardViewControllerDelegate?
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  private func updateSelection() {
    guard tableView.allowsSelection else { return }
    if let selectedCard = delegate?.creditCardViewControllerCard(viewController: self) {
      guard let cards = frcHandler.sections?[0].objects as? [Card] else { return }
      guard let row = cards.enumerated().filter({ $0.element == selectedCard }).first?.offset else { return }
      tableView.selectRow(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: .none)
      delegate?.creditCardViewControllerDidSelect(viewController: self, card: cards[row], action: false)
    } else {
      guard let cards = frcHandler.sections?[0].objects as? [Card] else { return }
      guard let row = cards.enumerated().filter({ $0.element.isDefault }).first?.offset else { return }
      tableView.selectRow(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: .none)
      delegate?.creditCardViewControllerDidSelect(viewController: self, card: cards[row], action: false)
    }
  }
  
  public func refreshControlDidRefresh(_ refreshControl: UIRefreshControl) {
    viewModel.initialize()
  }
  
  public func emptyNotificationActionTapped(data: EmptyNotificationActionData) {
  }
  
  @IBAction private func addNewCardTapped(_ sender: Any) {
    showAddNewCard()
  }
  
  @IBAction private func bottomActionTapped(_ sender: Any) {
    delegate?.creditCardViewControllerShopCartNavigationTapped(viewController: self)
  }
}

// MARK: - NavigationProtocol
extension CreditCardViewController: NavigationProtocol {
}

// MARK: - AddNewCardPresenterProtocol
extension CreditCardViewController: AddNewCardPresenterProtocol {
}

// MARK: - ControllerProtocol
extension CreditCardViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("CreditCardViewController segueIdentifier not set")
  }
  
  public func setupUI() {
    view.backgroundColor = .white
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: .icLeftArrow, selector: #selector(popOrDismissViewController))
    viewModel.attachView(self)
    viewModel.initialize()
  }
  
  public func setupObservers() {
    observeRefresh(scrollView: tableView)
    frcHandler.delegate = self
  }
}

// MARK: - CreditCardView
extension CreditCardViewController: CreditCardView {
  public func reload() {
    title = delegate?.creditCardViewControllerTitle(viewController: self) ?? "CREDIT | DEBIT CARD"
    allowsDelete = delegate?.creditCardViewControllerAllowsDelete(viewController: self) ?? false
    tableView.allowsSelection = delegate?.creditCardViewControllerAllowsSelection(viewController:  self) ?? false
    if let appearanceType = delegate?.creditCardViewControllerShopCartNavigationType(viewController: self) {
      bottomActionContainerView.isHidden = false
      bottomActionButton.type = appearanceType
    } else {
      bottomActionContainerView.isHidden = true
    }
    frcHandler.reload(recipe: viewModel.cardsRecipe)
    updateSelection()
  }
  
  public func showLoading() {
    if frcHandler.numberOfObjectsInSection(0) == 0 {
      startRefreshing()
    }
  }
  
  public func hideLoading() {
    emptyNotificationActionData = viewModel.emptyNotificationActionData
    endRefreshing()
  }
  
  public func showError(message: String?) {
    showAlert(title: "Oops!", message: message)
  }
}

// MARK: - UITableViewDataSource
extension CreditCardViewController: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return frcHandler.numberOfObjectsInSection(section)
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let creditCardTCell = tableView.dequeueReusableCell(CreditCardTCell.self, atIndexPath: indexPath)
    creditCardTCell.allowsDelete = allowsDelete
    creditCardTCell.allowsSelection = tableView.allowsSelection
    creditCardTCell.card = frcHandler.object(at: indexPath)
    creditCardTCell.setPrimaryDidTapped = { [weak self] (card) in
      guard let `self` = self else { return }
      self.viewModel.setCardPrimary(card)
    }
    creditCardTCell.deleteDidTapped = { [weak self] (card) in
      guard let `self` = self else { return }
      let handler = DialogHandler()
      handler.message = "You are about to delete your card."
      handler.actions = [.cancel(title: "CANCEL"), .confirm(title: "PROCEED")]
      handler.actionCompletion = { [weak self] (action, dialogView) in
        dialogView.dismiss()
        guard let `self` = self else { return }
        if action.title == "PROCEED" {
          dialogView.dismiss()
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.viewModel.deleteCard(card)
          }
        }
      }
      PresenterViewController.show(
        presentVC: DialogViewController.load(handler: handler),
        onVC: self)
    }
    return creditCardTCell
  }
}

// MARK: - UITableViewDelegate
extension CreditCardViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    delegate?.creditCardViewControllerDidSelect(viewController: self, card: frcHandler.object(at: indexPath), action: true)
    updateSelection()
  }
  
  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return headerView
  }
  
  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 104.0
  }
}

// MARK: - FetchResultsControllerHandlerDelegate
extension CreditCardViewController: FetchResultsControllerHandlerDelegate {
  public func fetchResultsWillUpdateContent(hander: Any) {
  }
  
  public func fetchResultsDidUpdateContent(handler: Any) {
    updateSelection()
  }
}

public protocol CreditCardPresenterProtocol {
}

extension CreditCardPresenterProtocol where Self: ControllerProtocol & UIViewController {
  public func showCreditCard(delegate: CreditCardViewControllerDelegate, animated: Bool = true) {
    let creditCardViewController = UIStoryboard.get(.profile).getController(CreditCardViewController.self)
    creditCardViewController.delegate = delegate
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(creditCardViewController, animated: animated)
    } else {
      let navigationController = NavigationController(rootViewController: creditCardViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
  }
}
