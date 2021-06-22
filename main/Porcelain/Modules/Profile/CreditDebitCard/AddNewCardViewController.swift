//
//  AddNewCardViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 04/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import Stripe
import CardScan

public final class AddNewCardViewController: UIViewController {
  @IBOutlet private weak var scrollView: UIScrollView!
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .regular(size: 20.0))
      titleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var cardholderNameInputView: AddNewCardInputView! {
    didSet {
      cardholderNameInputView.placeholder = "Cardholder Name"
      cardholderNameInputView.type = .name
    }
  }
  @IBOutlet private weak var creditcardNumberInputView: AddNewCardInputView! {
    didSet {
      creditcardNumberInputView.placeholder = "Credit Card Number"
      creditcardNumberInputView.type = .creditCardNumber
    }
  }
  @IBOutlet private weak var expirationDateInputView: AddNewCardInputView! {
    didSet {
      expirationDateInputView.placeholder = "Expiration Date (MM/YY)"
      expirationDateInputView.type = .expiration
    }
  }
  @IBOutlet private weak var ccvInputView: AddNewCardInputView! {
    didSet {
      ccvInputView.placeholder = "CCV"
      ccvInputView.type = .ccv
    }
  }
  @IBOutlet private weak var termsTitleLabel: UILabel! {
    didSet {
      termsTitleLabel.font = .openSans(style: .regular(size: 12.0))
      termsTitleLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var termsAndConditionsButton: UIButton! {
    didSet {
      termsAndConditionsButton.setAttributedTitle(
        "Terms and Conditions".attributed.add([
          .color(.lightNavy),
          .font(.openSans(style: .semiBold(size: 12.0)))]), for: .normal)
    }
  }
  @IBOutlet private weak var addContainerView: UIView!
  @IBOutlet private weak var addButton: DesignableButton! {
    didSet {
      addButton.cornerRadius = 7.0
      addButton.backgroundColor = .greyblue
      addButton.setAttributedTitle(
        "ADD".attributed.add(.appearance(DialogButtonAttributedTitleAppearance())),
        for: .normal)
    }
  }
  
  private lazy var viewModel: AddNewCardViewModelProtocol = AddNewCardViewModel()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  @objc
  private func scanTapped(_ sender: Any) {
    guard let scanViewController = ScanViewController.createViewController(withDelegate: self) else { return }
    present(scanViewController, animated: true) {
    }
  }
  
  @IBAction private func termsAndConditionsTapped(_ sender: Any) {
    showTermsAndConditions()
  }
  
  @IBAction private func addTapped(_ sender: Any) {
    viewModel.addStripeCard()
  }
}

// MARK: - NavigationProtocol
extension AddNewCardViewController: NavigationProtocol {
}

// MARK: - TACsPresenterProtocol
extension AddNewCardViewController: TACsPresenterProtocol {
}

// MARK: - ControllerProtocol
extension AddNewCardViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("AddNewCardViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: .icLeftArrow, selector: #selector(popOrDismissViewController))
    if ScanViewController.isCompatible() {
      generateRightNavigationButton(image: .icScan, selector: #selector(scanTapped(_:)))
    }
    viewModel.attachView(self)
    viewModel.initialize()
  }
  
  public func setupObservers() {
    observeKeyboard()
    cardholderNameInputView.didUpdate = { [weak self] in
      guard let `self` = self else { return }
      self.viewModel.card.name = self.cardholderNameInputView.text
      self.viewModel.validate()
    }
    creditcardNumberInputView.didUpdate = { [weak self] in
      guard let `self` = self else { return }
      self.ccvInputView.brand = self.creditcardNumberInputView.brand//set brand
      self.viewModel.card.number = self.creditcardNumberInputView.text?.replacingOccurrences(of: " ", with: "")
      self.viewModel.validate()
    }
    expirationDateInputView.didUpdate = { [weak self] in
      guard let `self` = self else { return }
      if let expirations = self.expirationDateInputView.text?.components(separatedBy: "/"), expirations.count == 2 {
        self.viewModel.card.expMonth = UInt(expirations.first!)!
        self.viewModel.card.expYear = 2000 + UInt(expirations.last!)!
      }
      self.viewModel.validate()
    }
    ccvInputView.didUpdate = { [weak self] in
      guard let `self` = self else { return }
      self.viewModel.card.cvc = self.ccvInputView.text
      self.viewModel.validate()
    }
  }
}

// MARK: - AddNewCardView
extension AddNewCardViewController: AddNewCardView {
  public func reload() {
    cardholderNameInputView.text = viewModel.card.name
    creditcardNumberInputView.text = viewModel.card.number
    if viewModel.card.expYear > 2000 {
      expirationDateInputView.text = "\(viewModel.card.expMonth)\(viewModel.card.expYear - 2000)"
    } else {
      expirationDateInputView.text = nil
    }
    ccvInputView.text = viewModel.card.cvc
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
  
  public func updateButtonInteraction() {
    let isValid = viewModel.isValid
    var appearance = DialogButtonAttributedTitleAppearance()
    appearance.color = isValid ? .white: .bluishGrey
    addButton.backgroundColor = isValid ? .greyblue: .whiteThree
    addButton.setAttributedTitle("ADD".attributed.add(.appearance(appearance)), for: .normal)
  }
  
  public func successAddStripe() {
    popOrDismissViewController()
  }
}

// MARK: - KeyboardHandlerProtocol
extension AddNewCardViewController: KeyboardHandlerProtocol {
  public func keyboardWillHide(_ notification: Notification) {
    scrollView.contentInset = .zero
  }
  
  public func keyboardWillShow(_ notification: Notification) {
    let height = evaluateKeyboardFrameFromNotification(notification).height - (view.safeAreaInsets.bottom + addContainerView.bounds.height)
    scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: height, right: 0.0)
  }
}

// MARK: - ScanDelegate
extension AddNewCardViewController: ScanDelegate {
  public func userDidCancel(_ scanViewController: ScanViewController) {
    scanViewController.dismiss(animated: true) {
    }
  }
  
  public func userDidSkip(_ scanViewController: ScanViewController) {
    scanViewController.dismiss(animated: true) {
    }
  }
  
  public func userDidScanCard(_ scanViewController: ScanViewController, creditCard: CreditCard) {
    viewModel.card.number = creditCard.cardParams().number
    viewModel.card.expMonth = creditCard.cardParams().expMonth
    viewModel.card.expYear = creditCard.cardParams().expYear
    viewModel.reload()
    scanViewController.dismiss(animated: true) {
    }
  }
}

public protocol AddNewCardPresenterProtocol {
}

extension AddNewCardPresenterProtocol where Self: ControllerProtocol & UIViewController {
  public func showAddNewCard(animated: Bool = true) {
    let addNewCardViewController = UIStoryboard.get(.profile).getController(AddNewCardViewController.self)
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(addNewCardViewController, animated: animated)
    } else {
      let navigationController = NavigationController(rootViewController: addNewCardViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
  }
}
