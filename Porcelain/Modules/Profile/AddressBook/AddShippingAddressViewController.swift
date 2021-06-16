//
//  AddShippingAddressViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 19/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class AddShippingAddressViewController: UIViewController, TapToDismissProtocol {
  @IBOutlet private weak var scrollView: UIScrollView!
  @IBOutlet private weak var fullnameInputView: PPInputView! {
    didSet {
      fullnameInputView.title = "Full Name"
      fullnameInputView.textContentType = .name
      fullnameInputView.type = .text
    }
  }
  @IBOutlet private weak var emailInputView: PPInputView! {
    didSet {
      emailInputView.title = "Email"
      emailInputView.textContentType = .emailAddress
      emailInputView.type = .email
    }
  }
  @IBOutlet private weak var addressInputView: PPInputView! {
    didSet {
      addressInputView.title = "Address"
      addressInputView.textContentType = .streetAddressLine1
      addressInputView.type = .text
    }
  }
  @IBOutlet private weak var countryInputView: PPInputView! {
    didSet {
      countryInputView.title = "Country"
      countryInputView.textContentType = .countryName
      countryInputView.type = .dropdown
    }
  }
  @IBOutlet private weak var stateInputView: PPInputView! {
    didSet {
      stateInputView.title = "State, City"
      stateInputView.textContentType = .addressCityAndState
      stateInputView.type = .text
    }
  }
  @IBOutlet private weak var postalCodeInputView: PPInputView! {
    didSet {
      postalCodeInputView.title = "Postal Code"
      postalCodeInputView.textContentType = .postalCode
      postalCodeInputView.type = .number
    }
  }
  @IBOutlet private weak var contactInputView: PPInputView! {
    didSet {
      contactInputView.title = "Contact Number"
      contactInputView.textContentType = .telephoneNumber
      contactInputView.type = .phone
    }
  }
  @IBOutlet private weak var defaultShippingButton: UIButton! {
    didSet {
      defaultShippingButton.setAttributedTitle(
        UIImage.icCheckBoxUnSelected.attributed.add(.baseline(offset: -4.0)).append(
          attrs: "  Default shipping address".attributed.add([.color(.bluishGrey), .font(.openSans(style: .regular(size: 14.0)))])),
        for: .normal)
      defaultShippingButton.setAttributedTitle(
        UIImage.icCheckBoxSelected.attributed.add(.baseline(offset: -4.0)).append(
          attrs: "  Default shipping address".attributed.add([.color(.gunmetal), .font(.openSans(style: .regular(size: 14.0)))])),
        for: .selected)
    }
  }
  @IBOutlet private weak var submitContainerView: UIView!
  @IBOutlet private weak var submitButton: DesignableButton! {
    didSet {
      submitButton.cornerRadius = 7.0
      submitButton.backgroundColor = .greyblue
      submitButton.setAttributedTitle("ADD".attributed.add(.appearance(DialogButtonAttributedTitleAppearance())), for: .normal)
    }
  }
  
  private var submitTitle: String? {
    didSet {
      submitButton.setAttributedTitle(
        submitTitle?.attributed.add(.appearance(DialogButtonAttributedTitleAppearance())),
        for: .normal)
    }
  }
  
  private var viewModel: AddShippingAddressViewModelProtocol!
  
  public func configure(viewModel: AddShippingAddressViewModelProtocol) {
    self.viewModel = viewModel
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    updateSelectedPhoneCountryIfNeeded()
  }
  
  private func updateSelectedPhoneCountryIfNeeded() {
    if let phoneCode = viewModel.phoneCode {
      SelectCountryService.getCountry(query: .phoneCode(value: phoneCode)) { (country) in
        self.contactInputView.country = country
      }
    } else {
      SelectCountryService.getDefaultCountry { (country) in
        self.contactInputView.country = country
      }
    }
  }
  
  public func handleTapToDismiss(_ tapGesture: UITapGestureRecognizer) {
    view.endEditing(true)
  }
  
  @IBAction private func defaultShippingTapped(_ sender: UIButton) {
    sender.isSelected = !sender.isSelected
    viewModel.isPrimary = sender.isSelected
  }
  
  @IBAction private func submitTapped(_ sender: Any) {
    viewModel.name = fullnameInputView.text
    viewModel.email = emailInputView.text
    viewModel.address = addressInputView.text
    viewModel.country = countryInputView.text
    viewModel.state = stateInputView.text
    viewModel.postalCode = postalCodeInputView.text
    viewModel.phoneCode = contactInputView.country?.phoneCode
    viewModel.phone = contactInputView.text?.replacingOccurrences(of: " ", with: "")
    viewModel.isPrimary = defaultShippingButton.isSelected
    var isValid = true
    if !InputValidator.validate(text: viewModel.name, validationRegex: .range(min: 1, max: 999)).isValid {
      fullnameInputView.errorDescription = "Full Name is required."
      isValid = false
    }
    if !InputValidator.validate(text: viewModel.email, validationRegex: .email).isValid {
      emailInputView.errorDescription = "Email is invalid."
      isValid = false
    }
    if !InputValidator.validate(text: viewModel.address, validationRegex: .range(min: 1, max: 999)).isValid {
      addressInputView.errorDescription = "Address is required."
      isValid = false
    }
    if !InputValidator.validate(text: viewModel.country, validationRegex: .range(min: 1, max: 999)).isValid {
      countryInputView.errorDescription = "Country is required."
      isValid = false
    }
    if !InputValidator.validate(text: viewModel.state, validationRegex: .range(min: 1, max: 999)).isValid {
      stateInputView.errorDescription = "State, City is required."
      isValid = false
    }
    if !InputValidator.validate(text: viewModel.postalCode, validationRegex: .range(min: 1, max: 999)).isValid {
      postalCodeInputView.errorDescription = "Postal Code is required."
      isValid = false
    }
    if !InputValidator.validate(text: viewModel.phone, validationRegex: .range(min: 1, max: 999)).isValid {
      contactInputView.errorDescription = "Contact Number is required."
      isValid = false
    }
    guard isValid else { return }
    viewModel.submit()
  }
}

// MARK: - NavigationProtocol
extension AddShippingAddressViewController: NavigationProtocol {
}

// MARK: - ControllerProtocol
extension AddShippingAddressViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("AddShippingAddressViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: .icLeftArrow, selector: #selector(popViewController))
    viewModel.attachView(self)
    viewModel.initialize()
  }
  
  public func setupObservers() {
    observeKeyboard()
    observeTapToDismiss(view: view)
    countryInputView.dropdownDidTapped = { [weak self] in
      guard let `self` = self else { return }
      let handler = SelectCountryHandler()
      handler.didSelectCountry = { [weak self] (country) in
        guard let `self` = self else  { return }
        self.countryInputView.text = country.name
      }
      SelectCountryViewController.load(handler: handler, in: self)
    }
    contactInputView.phoneCodeDidTapped = { [weak self] in
      guard let `self` = self else { return }
      let handler = SelectCountryHandler()
      handler.didSelectCountry = { [weak self] (country) in
        guard let `self` = self else  { return }
        self.contactInputView.country = country
        self.contactInputView.becomeFirstResponder()
      }
      SelectCountryViewController.load(handler: handler, in: self)
    }
  }
}

// MARK: - AddShippingAddressView
extension AddShippingAddressViewController: AddShippingAddressView {
  public func reload() {
    let currentUser = AppUserDefaults.customer
    title = viewModel.navTitle
    fullnameInputView.text = viewModel.name
    emailInputView.text = viewModel.email ?? currentUser?.email
    addressInputView.text = viewModel.address
    countryInputView.text = viewModel.country
    stateInputView.text = viewModel.state
    postalCodeInputView.text = viewModel.postalCode
    contactInputView.text = viewModel.phone?.formatMobile() ?? currentUser?.phone?.formatMobile()
    defaultShippingButton.isSelected = viewModel.isPrimary
    submitTitle = viewModel.submitTitle
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
  
  public func successSubmit() {
    popOrDismissViewController()
  }
}

// MARK: - KeyboardHandlerProtocol
extension AddShippingAddressViewController: KeyboardHandlerProtocol {
  public func keyboardWillHide(_ notification: Notification) {
    scrollView.contentInset = .zero
  }
  
  public func keyboardWillShow(_ notification: Notification) {
    let height = evaluateKeyboardFrameFromNotification(notification).height - (view.safeAreaInsets.bottom + submitContainerView.bounds.height)
    scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: height, right: 0.0)
  }
}

public protocol AddShippingAddressPresenterProtocol {
}

extension AddShippingAddressPresenterProtocol where Self: ControllerProtocol & UIViewController {
  public func showAddShippingAddress(type: AddShippingAddressType, animated: Bool = true) {
    let addShippingAddressViewController = UIStoryboard.get(.profile).getController(AddShippingAddressViewController.self)
    addShippingAddressViewController.configure(viewModel: AddShippingAddressViewModel(type: type))
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(addShippingAddressViewController, animated: animated)
    } else {
      let navigationController = NavigationController(rootViewController: addShippingAddressViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
  }
}
