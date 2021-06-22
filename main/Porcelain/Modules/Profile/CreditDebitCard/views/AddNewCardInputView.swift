//
//  AddNewCardInputView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 05/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import Stripe

public enum AddNewCardInputType {
  case name
  case creditCardNumber
  case expiration
  case ccv
}

private struct ErrorIndicatorAppearance: ErrorIndicatorAppearanceProtocol {
  var font: UIFont = .openSans(style: .regular(size: 12.0))
  var color: UIColor = .coral
  var position: ErrorIndicatorPosition = .bottomLeft(offset: CGSize(width: 0.0, height: -8.0))
}

public final class AddNewCardInputView: UIView, ErrorIndicatorViewProtocol {
  public var errorAppearance: ErrorIndicatorAppearanceProtocol = ErrorIndicatorAppearance()
  public var errorContainerView: UIView {
    return textField
  }
  public var errorDescription: String?
  
  @IBOutlet private weak var view: UIView!
  @IBOutlet private weak var placeholderLabel: UILabel! {
    didSet {
      placeholderLabel.font = .openSans(style: .regular(size: 14.0))
      placeholderLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var textField: UITextField! {
    didSet {
      textField.tintColor = .gunmetal
      textField.font = .openSans(style: .regular(size: 14.0))
      textField.textColor = .gunmetal
      textField.delegate = self
    }
  }
  @IBOutlet private weak var imageView: UIImageView!
  
  public var placeholder: String? {
    didSet {
      placeholderLabel.text = placeholder
    }
  }
  
  public var type: AddNewCardInputType = .name {
    didSet {
      switch type {
      case .name:
        textField.keyboardType = .default
        textField.textContentType = .name
        textField.inputAccessoryView = nil
        imageView.isHidden = true
      case .creditCardNumber:
        textField.keyboardType = .numberPad
        textField.textContentType = .creditCardNumber
        textField.inputAccessoryView = toolbar
        imageView.isHidden = false
        imageView.image = STPImageLibrary.brandImage(for: STPCardBrand.unknown)
      case .expiration:
        textField.keyboardType = .numberPad
        textField.textContentType = nil
        textField.inputAccessoryView = toolbar
        imageView.isHidden = true
      case .ccv:
        textField.keyboardType = .numberPad
        textField.textContentType = nil
        textField.inputAccessoryView = toolbar
        imageView.isHidden = true
      }
    }
  }
  
  public var text: String? {
    get {
      return textField.text
    }
    set {
      switch type {
      case .creditCardNumber:
        textField.text = newValue?.formatNumber(interval: 4, text: " ").value
      case .expiration:
        textField.text = newValue?.formatNumber(interval: 2, text: "/").value
      default:
        textField.text = newValue
      }
      if (textField.text?.isEmpty ?? true) {
        setInactive(animated: false)
      } else {
        setActive(animated: false)
      }
      validate()
    }
  }
  
  private lazy var toolbar: UIToolbar = {
    let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 48.0))
    toolbar.isTranslucent = true
    toolbar.barStyle = .default
    let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let done: UIBarButtonItem = UIBarButtonItem(title: "DONE", style: .done, target: self, action: #selector(doneTapped(_:)))
    toolbar.items = [flexSpace, done]
    toolbar.sizeToFit()
    return toolbar
  }()
  
  public var didUpdate: VoidCompletion?
  
  public var brand: STPCardBrand?
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    commonInit()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    commonInit()
  }
  
  private func commonInit() {
    loadNib(AddNewCardInputView.self)
    addSubview(view)
    view.addContainerBoundsResizingMask()
  }
  
  private func validate() {
    guard let text = textField.text, !text.isEmpty else { return }
    switch type {
    case .name: break
    case .creditCardNumber:
      let number = text.replacingOccurrences(of: " ", with: "")
      let brand = STPCardValidator.brand(forNumber: number)
      imageView.image = STPImageLibrary.brandImage(for: brand)
      self.brand = brand
      switch STPCardValidator.validationState(forNumber: number, validatingCardBrand: true) {
      case .valid:
        hideErrorIndicator()
      case .invalid:
        errorDescription = "Invalid Credit Card"
        showErrorIndicator()
      case .incomplete:
        errorDescription = "Incomplete Credit Card"
        showErrorIndicator()
      }
    case .expiration: break
    case .ccv:
      let cvc = text
      switch STPCardValidator.validationState(forCVC: cvc, cardBrand: brand ?? .unknown) {
      case .valid:
        hideErrorIndicator()
      case .invalid:
        errorDescription = "Invalid CCV"
        showErrorIndicator()
      case .incomplete:
        errorDescription = "Incomplete CCV"
        showErrorIndicator()
      }
    }
  }
  
  @objc
  private func doneTapped(_ sender: Any) {
    textField.resignFirstResponder()
  }
  
  @IBAction private func textEditingChanged(_ sender: Any) {
    didUpdate?()
  }
}

extension AddNewCardInputView {
  private func setActive(animated: Bool) {
    if animated {
      UIView.animate(withDuration: 0.1, animations: {
        self.placeholderLabel.transform = .init(translationX: 0.0, y: -24.0)
      }, completion: { (_) in
        self.placeholderLabel.text = self.placeholder?.uppercased()
      })
    } else {
      placeholderLabel.transform = .init(translationX: 0.0, y: -24.0)
      placeholderLabel.text = placeholder?.uppercased()
    }
  }
  
  private func setInactive(animated: Bool) {
    if animated {
      UIView.animate(withDuration: 0.1, animations: {
        self.placeholderLabel.transform = .init(translationX: 0.0, y: 0.0)
      }, completion: { (_) in
        self.placeholderLabel.text = self.placeholder
      })
    } else {
      placeholderLabel.transform = .init(translationX: 0.0, y: 0.0)
      placeholderLabel.text = placeholder
    }
  }
}

// MARK: - UITextFieldDelegate
extension AddNewCardInputView: UITextFieldDelegate {
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
  
  public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    setActive(animated: true)
    return true
  }
  
  public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    validate()
    if (textField.text?.isEmpty ?? true) {
      setInactive(animated: true)
      hideErrorIndicator()
    }
    return true
  }
  
  public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard string != " " else { return true }
    guard let text = textField.text else {
      didUpdate?()
      return false
    }
    guard let swRange =  Range(range, in: text) else {
      didUpdate?()
      return false
    }
    let newString = textField.text!.replacingCharacters(in: swRange, with: string)
    switch type {
    case .name:
      return true
    case .creditCardNumber:
      var currentPosition = 0
      if let selectedRange = textField.selectedTextRange {
        currentPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
      }
      let result = newString.formatNumber(interval: 4, text: " ")
      textField.text = result.value
      if string == "" {
        currentPosition = currentPosition - 1
      } else {
        if result.intervals.contains(range.location) {
          currentPosition = currentPosition + 2
        } else {
          currentPosition = currentPosition + 1
        }
      }
      if let newPosition = textField.position(from: textField.beginningOfDocument, offset: currentPosition) {
        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
      }
      let brand = STPCardValidator.brand(forNumber: textField.text?.replacingOccurrences(of: " ", with: "") ?? "")
      imageView.image = STPImageLibrary.brandImage(for: brand)
      didUpdate?()
      return false
    case .expiration:
      guard newString.count <= 5 else { return false }
      var currentPosition = 0
      if let selectedRange = textField.selectedTextRange {
        currentPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
      }
      let result = newString.formatNumber(interval: 2, text: "/")
      let expirations = result.value.components(separatedBy: "/")
      if let expMonth = expirations.first, expMonth.toNumber().intValue > 12 || expMonth == "00"  {
        didUpdate?()
        return false
      }
      if let expYear = expirations.last, expYear.toNumber().intValue > 31 || expYear == "00" {
        didUpdate?()
        return false
      }
      textField.text = result.value
      if string == "" {
        currentPosition = currentPosition - 1
      } else {
        if result.intervals.contains(range.location) {
          currentPosition = currentPosition + 2
        } else {
          currentPosition = currentPosition + 1
        }
      }
      if let newPosition = textField.position(from: textField.beginningOfDocument, offset: currentPosition) {
        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
      }
      didUpdate?()
      return false
    case .ccv:
      guard newString.count <= 4 else { return false }
      return true
    }
  }
}
