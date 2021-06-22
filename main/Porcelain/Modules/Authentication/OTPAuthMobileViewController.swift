//
//  OTPAuthMobileViewController.swift
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
  static let title = "Enter the 6-digit code sent to:"
}

public protocol OTPAuthMobieViewModelProtocol {
  var country: CountryData? { get }
  var phone: String? { get }
  var linkingPhone: String? { get }
  
  func otpMobileValidate(otp: String)
  func otpRequestNewCode(completion: @escaping APIResponseCompletion)
}

public final class OTPAuthMobieViewController: UIViewController {
  @IBOutlet private weak var scrollView: UIScrollView! {
    didSet {
      scrollView.alwaysBounceVertical = false
      scrollView.keyboardDismissMode = .interactive
    }
  }
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .light(size: 16.0))
      titleLabel.textColor = .white
      titleLabel.text = Constant.title
    }
  }
  @IBOutlet private weak var mobileLabel: UILabel! {
    didSet {
      mobileLabel.font = .openSans(style: .semiBold(size: 16.0))
      mobileLabel.textColor = .white
    }
  }
  @IBOutlet private weak var otpTextField: DesignableTextField! {
    didSet {
      if #available(iOS 12.0, *) {
        otpTextField.textContentType = .oneTimeCode
      } else {
        // Fallback on earlier versions
      }
      otpTextField.leftEdgeInset = 16.0
      otpTextField.rightEdgeInset = 16.0
      otpTextField.font = .openSans(style: .semiBold(size: 24.0))
      otpTextField.textColor = .white
      otpTextField.keyboardType = .numberPad
      otpTextField.tintColor = .white
      otpTextField.delegate = self
    }
  }
  
  private lazy var requestCodeView: OTPRequestCodeView = {
    let otpRequestCode = Bundle.main.loadNibNamed(OTPRequestCodeView.identifier, owner: nil, options: nil)?.first as! OTPRequestCodeView
    otpRequestCode.setRequestAction(.default)
    return otpRequestCode
  }()
  
  private var viewModel: OTPAuthMobieViewModelProtocol!
  
  public func configure(viewModel: OTPAuthMobieViewModelProtocol) {
    self.viewModel = viewModel
  }
  
  public override var inputAccessoryView: UIView? {
    return requestCodeView
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
    
    if otpTextField.text?.isEmpty ?? false {
      otpTextField.becomeFirstResponder()
    }
  }
}


// MARK: - ControllerProtocol
extension OTPAuthMobieViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("OTPAuthMobieViewController segueIdentifier not set")
  }
  
  public func setupUI() {
    if let linkingPhone = viewModel.linkingPhone {
      mobileLabel.text = linkingPhone.maskedPhone
    } else {
      let phoneNumber = try? PhoneNumberKit().parse([viewModel.country?.phoneCode, viewModel.phone].compactMap({ $0 }).joined())
      mobileLabel.text = phoneNumber?.numberString
    }
  }
  
  public func setupController() {
    requestCodeView.setRequestAction(.start)
  }
  
  public func setupObservers() {
    requestCodeView.resendDidTapped = { [weak self] in
      guard let `self` = self else { return }
      self.viewModel.otpRequestNewCode { (response) in
        switch response {
        case .success:
          self.requestCodeView.setRequestAction(.start)
        case .failure:
          self.requestCodeView.setRequestAction(.failed)
        }
      }
    }
  }
}

// MARK: - UITextFieldDelegate
extension OTPAuthMobieViewController: UITextFieldDelegate {
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
  
  public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let text = textField.text else { return false }
    guard let swRange =  Range(range, in: text) else { return false }
    let otp = textField.text!.replacingCharacters(in: swRange, with: string)
    if otp.count == 6 {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.viewModel.otpMobileValidate(otp: otp)
      }
    }
    return otp.count <= 6
  }
}
