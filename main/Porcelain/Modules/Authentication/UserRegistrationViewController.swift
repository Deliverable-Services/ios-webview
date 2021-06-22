//
//  UserRegistrationViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 23/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import PhoneNumberKit

private struct Constant {
  static let firstnamePlaceholder = "First name"
  static let lastnamePlaceholder = "Last name"
  static let emailPlaceholder = "Email"
  static let mobilePlaceholder = "9XXX XXXX"
}

public enum UserRegistrationType {
  case signUp
  case emailOnly
  
  public var title: String {
    switch self {
    case .signUp:
      return "Sign Up"
    case .emailOnly:
      return "Email Registration"
    }
  }
  
  public var subtitle: String {
    switch self {
    case .signUp:
      return "Fill-up the missing details to continue."
    case .emailOnly:
      return "Fill-up the missing details to continue."
    }
  }
}

public protocol UserRegistrationViewModelProtocol {
  var userRegistrationType: UserRegistrationType { get }
  var firstname: String? { get set }
  var lastname: String? { get set }
  var email: String? { get set }
  var isEmailVerified: Bool  { get set }
  var country: CountryData? { get set }
  var phone: String? { get set }
  var isMobileVerified: Bool { get }
  var isMobileEditable: Bool { get }
  
  func userRegistratinContinue()
}

public final class UserRegistrationViewController: UIViewController {
  @IBOutlet private weak var scrollView: UIScrollView! {
    didSet {
      scrollView.alwaysBounceVertical = false
      scrollView.keyboardDismissMode = .interactive
    }
  }
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .light(size: 30.0))
      titleLabel.textColor = .white
    }
  }
  @IBOutlet private weak var subtitleLabel: UILabel! {
    didSet {
      subtitleLabel.font = .openSans(style: .light(size: 16.0))
      subtitleLabel.textColor = .white
    }
  }
  @IBOutlet private weak var firstnameTextField: DesignableTextField! {
    didSet {
      firstnameTextField.textContentType = .givenName
      firstnameTextField.leftEdgeInset = 16.0
      firstnameTextField.rightEdgeInset = 16.0
      firstnameTextField.font = .openSans(style: .semiBold(size: 14.0))
      firstnameTextField.textColor = .white
      firstnameTextField.keyboardType = .default
      firstnameTextField.tintColor = .white
      firstnameTextField.attributedPlaceholder = Constant.firstnamePlaceholder.attributed.add([
        .color(PorcelainColor.white.withAlphaComponent(0.5)),
        .font(.openSans(style: .regular(size: 14.0)))])
    }
  }
  @IBOutlet private weak var lastnameTextField: DesignableTextField! {
    didSet {
      lastnameTextField.textContentType = .familyName
      lastnameTextField.leftEdgeInset = 16.0
      lastnameTextField.rightEdgeInset = 16.0
      lastnameTextField.font = .openSans(style: .semiBold(size: 14.0))
      lastnameTextField.textColor = .white
      lastnameTextField.keyboardType = .default
      lastnameTextField.tintColor = .white
      lastnameTextField.attributedPlaceholder = Constant.lastnamePlaceholder.attributed.add([
        .color(PorcelainColor.white.withAlphaComponent(0.5)),
        .font(.openSans(style: .regular(size: 14.0)))])
    }
  }
  @IBOutlet private weak var emailTextField: DesignableTextField! {
    didSet {
      emailTextField.textContentType = .emailAddress
      emailTextField.leftEdgeInset = 16.0
      emailTextField.rightEdgeInset = 16.0
      emailTextField.font = .openSans(style: .semiBold(size: 14.0))
      emailTextField.textColor = .white
      emailTextField.keyboardType = .emailAddress
      emailTextField.tintColor = .white
      emailTextField.attributedPlaceholder = Constant.emailPlaceholder.attributed.add([
        .color(PorcelainColor.white.withAlphaComponent(0.5)),
        .font(.openSans(style: .regular(size: 14.0)))])
    }
  }
  @IBOutlet private weak var mobileStack: UIStackView!
  @IBOutlet private weak var countryPhoneCodeButton: CountryPhoneCodeButton! {
    didSet {
      countryPhoneCodeButton.backgroundColor = UIColor.white.withAlphaComponent(0.3)
    }
  }
  @IBOutlet private weak var mobileTextField: DesignableTextField! {
    didSet {
      mobileTextField.textContentType = .telephoneNumber
      mobileTextField.leftEdgeInset = 16.0
      mobileTextField.leftEdgeInset = 16.0
      mobileTextField.font = .openSans(style: .semiBold(size: 18.0))
      mobileTextField.textColor = .white
      mobileTextField.keyboardType = .numberPad
      mobileTextField.tintColor = .white
      mobileTextField.attributedPlaceholder = Constant.mobilePlaceholder.attributed.add([
        .color(PorcelainColor.white.withAlphaComponent(0.5)),
        .font(.openSans(style: .semiBold(size: 18.0)))])
      mobileTextField.inputAccessoryView = inputAccessoryPresenterView
      mobileTextField.delegate = self
    }
  }
  
  private lazy var inputAccessoryPresenterView = InputAccessoryPresenterView(view: continueToolBar)
  
  private lazy var continueToolBar: UIToolbar = {
    let continueToolBar = UIToolbar(frame: .zero)
    continueToolBar.addHeightConstraint(48.0)
    continueToolBar.isTranslucent = true
    continueToolBar.barStyle = .default
    continueToolBar.setShadowImage(UIImage(), forToolbarPosition: .any)
    continueToolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
    let continueButton = UIButton(frame: .zero)
    continueButton.setAttributedTitle("Continue".attributed.add([
      .color(.white),
      .font(.openSans(style: .semiBold(size: 15.0)))]), for: .normal)
    continueButton.setAttributedTitle("Continue".attributed.add([
      .color(PorcelainColor.white.withAlphaComponent(0.3)),
      .font(.openSans(style: .semiBold(size: 15.0)))]), for: .highlighted)
    continueButton.addTarget(self, action: #selector(continueTapped(_:)), for: .touchUpInside)
    continueToolBar.items = [
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      UIBarButtonItem(customView: continueButton),
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)]
    return continueToolBar
  }()
  
  private var viewModel: UserRegistrationViewModelProtocol!
  
  public func configure(viewModel: UserRegistrationViewModelProtocol) {
    self.viewModel = viewModel
  }
  
  public override var inputAccessoryView: UIView? {
    return inputAccessoryPresenterView
  }
  
  public override var canBecomeFirstResponder: Bool {
    return true
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    updateSelectedCountryIfNeeded()
  }
  
  private func updateSelectedCountryIfNeeded() {
    if let country = viewModel.country {
      countryPhoneCodeButton.country = country
    } else {
      SelectCountryService.getDefaultCountry { (country) in
        self.viewModel.country = country
        self.countryPhoneCodeButton.country = country
      }
    }
  }
  
  @objc
  private func continueTapped(_ sender: Any) {
    viewModel.firstname = firstnameTextField.text
    viewModel.lastname = lastnameTextField.text
    viewModel.email = emailTextField.text
    if !viewModel.isMobileVerified {
      viewModel.country = countryPhoneCodeButton.country
      viewModel.phone = mobileTextField.text?.replacingOccurrences(of: " ", with: "")
    }
    viewModel.userRegistratinContinue()
  }
  
  @IBAction private func countryPhoneCodeTapped(_ sender: Any) {
    let handler = SelectCountryHandler()
    handler.didSelectCountry = { [weak self] (country) in
      guard let `self` = self else  { return }
      self.viewModel.country = country
      self.countryPhoneCodeButton.country = country
    }
    SelectCountryViewController.load(handler: handler, in: self)
  }
}

// MARK: - ControllerProtocol
extension UserRegistrationViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("UserRegistrationViewController segueIdentifier not set")
  }
  
  public func setupUI() {
    switch viewModel.userRegistrationType {
    case .signUp:
      firstnameTextField.isHidden = false
      lastnameTextField.isHidden = false
      emailTextField.isHidden = false
    case .emailOnly:
      firstnameTextField.isHidden = true
      lastnameTextField.isHidden = true
      emailTextField.isHidden = false
    }
    if !viewModel.isEmailVerified {
      emailTextField.isEnabled = true
      emailTextField.alpha = 1.0
    } else {
      emailTextField.isEnabled = false
      emailTextField.alpha = 0.5
    }
    if viewModel.isMobileVerified || !viewModel.isMobileEditable {
      countryPhoneCodeButton.isEnabled = false
      countryPhoneCodeButton.alpha = 0.5
      mobileTextField.isEnabled = false
      mobileTextField.alpha = 0.5
    } else {
      countryPhoneCodeButton.isEnabled = true
      countryPhoneCodeButton.alpha = 1.0
      mobileTextField.isEnabled = true
      mobileTextField.alpha = 1.0
    }
  }
  
  public func setupController() {
    titleLabel.text = viewModel.userRegistrationType.title
    subtitleLabel.text = viewModel.userRegistrationType.subtitle
    firstnameTextField.text = viewModel.firstname
    lastnameTextField.text = viewModel.lastname
    emailTextField.text = viewModel.email
    mobileTextField.text = viewModel.phone?.formatMobile()
  }
  
  public func setupObservers() {
    observeKeyboard()
  }
}

// MARK: - UITextFieldDelegate
extension UserRegistrationViewController: UITextFieldDelegate {
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
  
  public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard string != " " else { return true }
    guard let text = textField.text else { return false }
    guard let swRange =  Range(range, in: text) else { return false }
    let newString = textField.text!.replacingCharacters(in: swRange, with: string)
    var currentPosition = 0
    if let selectedRange = textField.selectedTextRange {
      currentPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
    }
    if newString.contains("+"), newString.count > 8 {
      let phoneNumber = try? PhoneNumberKit().parse(newString)
      SelectCountryService.getCountry(query: .phoneCode(value: phoneNumber?.countryCode.stringValue)) { (country) in
        self.viewModel.country = country
        self.countryPhoneCodeButton.country = country
      }
      textField.text = phoneNumber?.nationalNumber.stringValue.formatMobile()
      currentPosition = textField.text?.count ?? 0
    } else {
      textField.text = newString.formatMobile()
      if string == "" {
        currentPosition = currentPosition - 1
      } else {
        if range.location == 4 || range.location == 9 {
          currentPosition = currentPosition + 2
        } else {
          currentPosition = currentPosition + 1
        }
      }
    }
    if let newPosition = textField.position(from: textField.beginningOfDocument, offset: currentPosition) {
      textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
    }
    return false
  }
}

// MARK: - KeyboardHandlerProtocol
extension UserRegistrationViewController: KeyboardHandlerProtocol {
  public func keyboardWillShow(_ notification: Notification) {
    let height = evaluateKeyboardFrameFromNotification(notification).height
    scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: height, right: 0.0)
  }
  
  public func keyboardWillHide(_ notification: Notification) {
    scrollView.contentInset = .zero
  }
}
