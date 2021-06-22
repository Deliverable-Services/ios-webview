//
//  WelcomeAuthMobileViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 22/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import Kingfisher
import PhoneNumberKit

private struct Constant {
  static let title = "Hello there!"
  static let subtitle = "Enter your mobile number to continue."
  static let mobilePlaceholder = "9XXX XXXX"
  static let socialContainerHeight: CGFloat = 207.0
}

public protocol WelcomeAuthMobileViewModelProtocol {
  var country: CountryData? { get set }
  var phone: String? { get set }
  
  func reset()
  func authMobileContinue()
  func authenticateWithFB()
  func authenticateWithGoogle()
}

public final class WelcomeAuthMobileViewController: UIViewController {
  @IBOutlet private weak var scrollView: UIScrollView! {
    didSet {
      scrollView.alwaysBounceVertical = false
      scrollView.keyboardDismissMode = .interactive
    }
  }
  @IBOutlet private weak var porcelainImageView: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .idealSans(style: .light(size: 30.0))
      titleLabel.textColor = .white
      titleLabel.text = Constant.title
    }
  }
  @IBOutlet private weak var subtitleLabel: UILabel! {
    didSet {
      subtitleLabel.font = .openSans(style: .light(size: 16.0))
      subtitleLabel.textColor = .white
      subtitleLabel.text = Constant.subtitle
    }
  }
  @IBOutlet private weak var countryPhoneCodeButton: CountryPhoneCodeButton! {
    didSet {
      countryPhoneCodeButton.backgroundColor = UIColor.white.withAlphaComponent(0.3)
    }
  }
  @IBOutlet private weak var mobileTextField: DesignableTextField! {
    didSet {
      mobileTextField.textContentType = .telephoneNumber
      mobileTextField.backgroundColor = UIColor.white.withAlphaComponent(0.3)
      mobileTextField.leftEdgeInset = 16.0
      mobileTextField.rightEdgeInset = 16.0
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
  @IBOutlet private weak var envSwitchContainerStack: UIStackView!
  @IBOutlet private weak var envSwitch: UISwitch! {
    didSet {
      envSwitch.isOn = AppUserDefaults.isProduction
    }
  }
  @IBOutlet private weak var envLabel: UILabel! {
    didSet {
      envLabel.font = .openSans(style: .semiBold(size: 14.0))
      envLabel.textColor = .white
      envLabel.text = AppUserDefaults.isProduction ? "PRODUCTION": "STAGING"
    }
  }
  @IBOutlet private weak var versionContainerView: UIView!
  @IBOutlet private weak var versionLabel: UILabel! {
    didSet {
      versionLabel.font = .openSans(style: .regular(size: 12.0))
      versionLabel.textColor = .white
      versionLabel.text = "\(AppUserDefaults.isProduction ? "": "Staging ")Version \(AppMainInfo.version ?? "") (\(AppMainInfo.build ?? ""))"
    }
  }
  @IBOutlet private weak var socialNetworkAuthView: SocialNetworkAuthView!
  
  private lazy var inputAccessoryPresenterView = InputAccessoryPresenterView(view: continueToolBar)
  
  private lazy var continueToolBar: UIToolbar = {
    let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 48.0)
    let continueToolBar = UIToolbar(frame:frame )
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
    continueButton.sizeToFit()
    continueButton.addTarget(self, action: #selector(continueTapped(_:)), for: .touchUpInside)
    continueToolBar.items = [
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      UIBarButtonItem(customView: continueButton),
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)]
    return continueToolBar
  }()
  
  private var viewModel: WelcomeAuthMobileViewModelProtocol!
  
  public func configure(viewModel: WelcomeAuthMobileViewModelProtocol) {
    self.viewModel = viewModel
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    viewModel.reset()
    
    UIView.animate(withDuration: 0.3) {
      self.porcelainImageView.alpha = 1.0
      self.socialNetworkAuthView.transform = .init(translationX: 0.0, y: 0.0)
    }
    
    updateSelectedCountryIfNeeded()
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    UIView.animate(withDuration: 0.3) {
      self.porcelainImageView.alpha = 0.0
      self.socialNetworkAuthView.transform = .init(translationX: 0.0, y: Constant.socialContainerHeight)
    }
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
    viewModel.reset()
    viewModel.phone = mobileTextField.text?.replacingOccurrences(of: " ", with: "")
    viewModel.authMobileContinue()
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
  
  @IBAction private func envTapped(_ sender: Any) {
    AppUserDefaults.isProduction = envSwitch.isOn
    APIServiceConstant.isProduction = AppUserDefaults.isProduction
    envLabel.text = AppUserDefaults.isProduction ? "PRODUCTION": "STAGING"
    versionLabel.text = "\(AppUserDefaults.isProduction ? "": "Staging ")Version \(AppMainInfo.version ?? "") (\(AppMainInfo.build ?? ""))"
  }
}

// MARK: - ControllerProtocol
extension WelcomeAuthMobileViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("WelcomeAuthMobileViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    envSwitchContainerStack.isHidden = AppConfiguration.isProduction
    APIServiceConstant.isProduction = AppUserDefaults.isProduction
    versionContainerView.isHidden = AppConfiguration.enableSocialLogin
    socialNetworkAuthView.isHidden = !AppConfiguration.enableSocialLogin
  }
  
  public func setupObservers() {
    socialNetworkAuthView.facebookSignInDidTapped = { [weak self] in
      guard let `self` = self else { return }
      self.viewModel.authenticateWithFB()
    }
    socialNetworkAuthView.googleSignInDidTapped = { [weak self] in
      guard let `self` = self else { return }
      self.viewModel.authenticateWithGoogle()
    }
  }
}

// MARK: - UITextFieldDelegate
extension WelcomeAuthMobileViewController: UITextFieldDelegate {
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
  
  public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    UIView.animate(withDuration: 0.3) {
      self.porcelainImageView.alpha = 0.0
      self.socialNetworkAuthView.transform = .init(translationX: 0.0, y: Constant.socialContainerHeight)
    }
    return true
  }
  
  public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    UIView.animate(withDuration: 0.3) {
      self.porcelainImageView.alpha = 1.0
      self.socialNetworkAuthView.transform = .init(translationX: 0.0, y: 0.0)
    }
    return true
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

extension UInt64 {
  public var stringValue: String {
    return "\(self)"
  }
}

public final class CountryPhoneCodeButton: UIDesignableControl {
  @IBOutlet private weak var countryImageView: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .semiBold(size: 13.0))
      titleLabel.textColor = .white
      titleLabel.text = nil
    }
  }
  
  public var country: CountryData? {
    didSet {
      if let url = URL(string: country?.flagImageURL ?? "") {
        countryImageView.kf.indicatorType = .activity
        countryImageView.kf.setImage(
          with: ImageResource(downloadURL: url),
          options: [.processor(DownsamplingImageProcessor(size: CGSize(width: 24.0, height: 16.0)))])
      } else {
        countryImageView.image = nil
      }
      if let phoneCode = country?.phoneCode {
        titleLabel.text = "(+\(phoneCode))"
      } else {
        titleLabel.text = nil
      }
    }
  }
  
  public override var isHighlighted: Bool {
    didSet {
      alpha = isHighlighted ? 0.8: 1.0
    }
  }
}
