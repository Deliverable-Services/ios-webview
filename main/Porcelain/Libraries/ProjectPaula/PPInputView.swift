//
//  PPInputView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 17/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import Kingfisher
import PhoneNumberKit

public enum EditProfileInputType: Int  {
  case text = 0
  case email
  case phone
  case birthdate
  case gender
  case number
  case dropdown
}

extension GenderType {
  fileprivate var title: String  {
    switch self {
    case .notSpecified:
      return "Prefer not to say"
    case .female:
      return "Female"
    case .male:
      return "Male"
    case .others:
      return "Others"
    }
  }
}

private struct ErrorIndicatorAppearance: ErrorIndicatorAppearanceProtocol {
  var font: UIFont = .openSans(style: .regular(size: 12.0))
  var color: UIColor = .coral
  var position: ErrorIndicatorPosition = .bottomLeft(offset: CGSize(width: 0.0, height: -10.0))
}

@IBDesignable
public final class PPInputView: UIView, ErrorIndicatorViewProtocol {
  public var errorAppearance: ErrorIndicatorAppearanceProtocol = ErrorIndicatorAppearance()
  public var errorContainerView: UIView {
    return textField
  }
  
  public var errorDescription: String? {
    didSet {
      if errorDescription != nil {
        showErrorIndicator()
      } else {
        hideErrorIndicator()
      }
    }
  }
  
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
  
  public var type: EditProfileInputType = .text {
    didSet {
      switch type {
      case .text:
        textField.leftView = nil
        textField.rightView = nil
        textField.keyboardType = .default
        textField.inputView = nil
      case .email:
        textField.leftView = nil
        textField.rightView = nil
        textField.keyboardType = .emailAddress
        textField.inputView = nil
      case .phone:
        updatePhoneCodeIfNeeded()
        textField.keyboardType = .numberPad
        textField.rightView = nil
        textField.inputView = nil
        setActive(animated: false)
      case .birthdate:
        textField.leftView = nil
        textField.rightView = nil
        textField.keyboardType = .default
        textField.inputView = InputAccessoryPresenterView(view: datePicker)
      case .gender:
        textField.leftView = nil
        textField.rightView = nil
        textField.keyboardType = .default
        textField.inputView = InputAccessoryPresenterView(view: genderPicker)
      case .number:
        textField.leftView = nil
        textField.rightView = nil
        textField.keyboardType = .numberPad
        textField.inputView = nil
      case .dropdown:
        textField.leftView = nil
        textField.generateRightImage(.icChevronDown)
        textField.keyboardType = .default
        textField.inputView = nil
      }
    }
  }
  
  public var title: String?  {
    didSet {
      titleLabel.text = title
    }
  }
  
  public var country: CountryData? {
    get {
      return phoneCodeButton.country
    }
    set {
      phoneCodeButton.country = newValue
      updatePhoneCodeIfNeeded()
    }
  }
  
  public var text: String? {
    get {
      return textField.text
    }
    set {
      textField.text = newValue
      updatePhoneCodeIfNeeded()
      if (textField.text?.isEmpty ?? true) && type != .phone {
        setInactive(animated: false)
      } else {
        setActive(animated: false)
      }
    }
  }
  
  public var date: Date? {
    didSet {
      text = date?.toString(WithFormat: "MM/dd/yyyy")
    }
  }
  
  public var gender: GenderType? {
    didSet {
      text = gender?.title
    }
  }
  
  private lazy var phoneCodeButton: PhoneCodeButton = {
    let phoneCodeButton = PhoneCodeButton(frame: .zero)
    phoneCodeButton.addTarget(self, action: #selector(phoneCodeTapped(_:)), for: .touchUpInside)
    return phoneCodeButton
  }()
  private lazy var datePicker: UIDatePicker = {
    let datePicker = UIDatePicker()
    datePicker.datePickerMode = .date
    datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    return datePicker
  }()
  private lazy var genders: [GenderType] = [.male, .female, .others]
  private lazy var genderPicker: UIPickerView = {
    let genderPicker = UIPickerView()
    genderPicker.dataSource = self
    genderPicker.delegate = self
    return genderPicker
  }()
  
  public var phoneCodeDidTapped: VoidCompletion?
  public var dropdownDidTapped: VoidCompletion?
  
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
    loadNib(PPInputView.self)
    addSubview(view)
    view.addContainerBoundsResizingMask()
  }
  
  public override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    
    titleLabel.text = "Title"
  }
  
  private func updatePhoneCodeIfNeeded() {
    guard type == .phone else { return }
    phoneCodeButton.invalidateIntrinsicContentSize()
    phoneCodeButton.frame = CGRect(origin: .zero, size: phoneCodeButton.intrinsicContentSize)
    textField.leftView = phoneCodeButton
    textField.leftViewMode = .always
  }
  
  @objc
  private func phoneCodeTapped(_ sender: Any) {
    phoneCodeDidTapped?()
  }
  
  @objc
  private func dateChanged(_ sender: UIDatePicker) {
    date = sender.date
  }
  
  @objc
  private func doneTapped(_ sender: Any) {
    switch type {
    case .birthdate:
      date = datePicker.date
    case .gender:
      gender = genders[genderPicker.selectedRow(inComponent: 0)]
    default: break
    }
    textField.resignFirstResponder()
  }
}

extension PPInputView {
  private func setActive(animated: Bool) {
    if animated {
      UIView.animate(withDuration: 0.1, animations: {
        self.titleLabel.transform = .init(translationX: 0.0, y: -24.0)
      }, completion: { (_) in
        self.titleLabel.text = self.title?.uppercased()
      })
    } else {
      titleLabel.transform = .init(translationX: 0.0, y: -24.0)
      titleLabel.text = title?.uppercased()
    }
  }
  
  private func setInactive(animated: Bool) {
    if animated {
      UIView.animate(withDuration: 0.1, animations: {
        self.titleLabel.transform = .init(translationX: 0.0, y: 0.0)
      }, completion: { (_) in
        self.titleLabel.text = self.title
      })
    } else {
      titleLabel.transform = .init(translationX: 0.0, y: 0.0)
      titleLabel.text = title
    }
  }
}

// MARK: - UITextFieldDelegate
extension PPInputView: UITextFieldDelegate  {
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
  
  public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    errorDescription = nil
    switch type {
    case .birthdate:
      setActive(animated: true)
      let currentDate = Date()
      datePicker.maximumDate = currentDate
      datePicker.minimumDate = currentDate.dateByAdding(years: -100)
      datePicker.date = date ?? currentDate.dateByAdding(years: -18)
      return true
    case .gender:
      setActive(animated: true)
      if let row = genders.firstIndex(where: { $0 == gender }) {
        genderPicker.selectRow(row, inComponent: 0, animated: true)
      }
      return true
    case .dropdown:
      dropdownDidTapped?()
      return false
    default:
      setActive(animated: true)
      return true
    }
  }
  
  public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    if (textField.text?.isEmpty ?? true) && type != .phone {
      setInactive(animated: true)
    }
    return true
  }
  
  public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    switch type {
    case .phone:
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
          self.country = country
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
    default:
      return true
    }
  }
}

// MARK: - UIPickerViewDataSource
extension PPInputView: UIPickerViewDataSource {
  public func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return genders.count
  }
  
  public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    return genders[row].title.attributed.add([.color(.gunmetal), .font(.idealSans(style: .book(size: 16.0)))])
  }
}

// MARK: - UIPickerViewDelegate
extension PPInputView: UIPickerViewDelegate {
  public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    gender = genders[row]
  }
}

private final class PhoneCodeButton: UIDesignableControl {
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.spacing = 8.0
    stackView.isUserInteractionEnabled = false
    return stackView
  }()
  private lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  private lazy var label: UILabel = {
    let label = UILabel()
    label.font = .idealSans(style: .book(size: 16.0))
    label.textColor = .gunmetal
    return label
  }()
  
  var country: CountryData? {
    didSet {
      if let flagImageURL = country?.flagImageURL, let url = URL(string: flagImageURL) {
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
          with: ImageResource(downloadURL: url),
          options: [.processor(DownsamplingImageProcessor(size: CGSize(width: 24.0, height: 16.0)))])
      } else {
        imageView.image = nil
      }
      label.text = ["(+", country?.phoneCode, ")"].compactMap({ $0 }).joined()
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    commonInit()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    commonInit()
  }
  
  private func commonInit() {
    imageView.addHeightConstraint(16.0)
    imageView.addWidthConstraint(24.0)
    stackView.addArrangedSubview(imageView)
    stackView.addArrangedSubview(label)
    self.addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 8.0),
      NSLayoutConstraint(item: stackView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 8.0)])
  }
  
  override var intrinsicContentSize: CGSize {
    return CGSize(width: 24.0 + 8.0 + label.intrinsicContentSize.width + 16.0, height: 36.0)
  }
}
