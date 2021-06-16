//
//  MakeReviewInputView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 13/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public enum MakeReviewInputType: Int {
  case text = 0
  case email
}

private struct ErrorIndicatorAppearance: ErrorIndicatorAppearanceProtocol {
  var font: UIFont = .openSans(style: .regular(size: 12.0))
  var color: UIColor = .coral
  var position: ErrorIndicatorPosition = .bottomLeft(offset: CGSize(width: 0.0, height: -10.0))
}

public final class MakeReviewInputView: UIView, ErrorIndicatorViewProtocol {
  public var errorAppearance: ErrorIndicatorAppearanceProtocol = ErrorIndicatorAppearance()
  public var errorContainerView: UIView {
    return textField
  }
  public var errorDescription: String?
  
  @IBOutlet private weak var view: UIView!
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .regular(size: 12.0))
      titleLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var textField: UITextField! {
    didSet {
      textField.tintColor = .gunmetal
      textField.font = .idealSans(style: .book(size: 16.0))
      textField.textColor = .gunmetal
      textField.inputAccessoryView = toolbar
      textField.delegate = self
    }
  }
  @IBOutlet private weak var separatorView: UIView! {
    didSet {
      separatorView.backgroundColor = .whiteThree
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
  
  public var textContentType: UITextContentType? {
    didSet {
      guard let textContentType = textContentType else { return }
      textField.textContentType = textContentType
    }
  }
  
  public var type: MakeReviewInputType = .text {
    didSet {
      switch type {
      case .text:
        textField.leftView = nil
        textField.keyboardType = .default
        textField.inputView = nil
      case .email:
        textField.leftView = nil
        textField.keyboardType = .emailAddress
        textField.inputView = nil
      }
    }
  }
  
  public var title: String?  {
    didSet {
      titleLabel.text = title
    }
  }
  
  public var text: String? {
    get {
      return textField.text
    }
    set {
      textField.text = newValue
      if (textField.text?.isEmpty ?? true) {
        setInactive(animated: false)
      } else {
        setActive(animated: false)
      }
      validate()
    }
  }
  
  public var didUpdate: VoidCompletion?
  
  @discardableResult
  public override func becomeFirstResponder() -> Bool {
    return textField.becomeFirstResponder()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    commonInit()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    commonInit()
  }
  
  private func commonInit() {
    loadNib(MakeReviewInputView.self)
    addSubview(view)
    view.addContainerBoundsResizingMask()
  }
  
  private func validate() {
    guard let text = textField.text, !text.isEmpty else { return }
    switch type {
    case .text: break
    case .email:
      if InputValidator.validate(text: text, validationRegex: .email).isValid {
        hideErrorIndicator()
      } else {
        errorDescription = "Invalid Email"
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

extension MakeReviewInputView {
  private func setActive(animated: Bool) {
    if animated {
      UIView.animate(withDuration: 0.3) {
        self.titleLabel.transform = .init(translationX: 0.0, y: -13.0)
        self.textField.transform = .init(translationX: 0.0, y: 12.0)
      }
    } else {
      titleLabel.transform = .init(translationX: 0.0, y: -13.0)
      textField.transform = .init(translationX: 0.0, y: 12.0)
    }
  }
  
  private func setInactive(animated: Bool) {
    if animated {
      UIView.animate(withDuration: 0.3) {
        self.titleLabel.transform = .init(translationX: 0.0, y: 0.0)
        self.textField.transform = .init(translationX: 0.0, y: 0.0)
      }
    } else {
      titleLabel.transform = .init(translationX: 0.0, y: 0.0)
      textField.transform = .init(translationX: 0.0, y: 0.0)
    }
  }
}

// MARK: - UITextFieldDelegate
extension MakeReviewInputView: UITextFieldDelegate {
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
    if textField.text?.isEmpty ?? true {
      setInactive(animated: true)
    }
    return true
  }
}
