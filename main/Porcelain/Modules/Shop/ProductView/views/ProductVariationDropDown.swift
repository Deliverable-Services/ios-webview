//
//  ProductVariationDropDown.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 3/9/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

extension ProductVariationAttribute {
  fileprivate var placeholder: String? {
    return "Select ".appending(name)
  }
}

public protocol ProductVariationDropDownDelegate: class {
  func productVariationDropDownMetaData(dropDown: ProductVariationDropDown) -> [String: String]?
  func productVariationDropDownDidUpdateMetaData(dropDown: ProductVariationDropDown, metaData: [String: String]?)
}

public final class ProductVariationDropDown: UIView {
  @IBOutlet private weak var view: UIView!
  @IBOutlet private weak var textField: DesignableTextField! {
    didSet {
      textField.font = .openSans(style: .regular(size: 14.0))
      textField.textColor = .gunmetal
      textField.tintColor = .gunmetal
      textField.canPerformAction = false
      textField.generateRightImage(.icChevronDown)
      textField.inputAccessoryView = toolbar
      textField.inputView = InputAccessoryPresenterView(view: optionsPicker)
      textField.delegate = self
    }
  }
  
  public weak var delegate: ProductVariationDropDownDelegate?
  
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
  
  private lazy var optionsPicker: UIPickerView = {
    let optionsPicker = UIPickerView()
    optionsPicker.dataSource = self
    optionsPicker.delegate = self
    return optionsPicker
  }()
  
  public var attribute: ProductVariationAttribute? {
    didSet {
      textField.placeholder = attribute?.placeholder
    }
  }
  
  public func reload() {
    var metaData = delegate?.productVariationDropDownMetaData(dropDown: self)
    if textField.text?.isEmpty ?? true,  attribute?.options?.count == 1, let key = attribute?.name {
      metaData?[key] = attribute?.options?.first
      delegate?.productVariationDropDownDidUpdateMetaData(dropDown: self, metaData: metaData)
    }
    textField.text = metaData?[attribute?.name ?? ""]
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
    loadNib(ProductVariationDropDown.self)
    addSubview(view)
    view.addSideConstraintsWithContainer()
  }
  
  @objc
  private func doneTapped(_ sender: Any) {
    textField.resignFirstResponder()
    guard let key = attribute?.name else { return }
    guard var metaData = delegate?.productVariationDropDownMetaData(dropDown: self) else { return }
    metaData[key] = attribute?.options?[optionsPicker.selectedRow(inComponent: 0)]
    textField.text = attribute?.options?[optionsPicker.selectedRow(inComponent: 0)]
    delegate?.productVariationDropDownDidUpdateMetaData(dropDown: self, metaData: metaData)
  }
}

// MARK: - UITextFieldDelegate
extension ProductVariationDropDown: UITextFieldDelegate {
  public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return false
  }
}

// MARK: - UIPickerViewDataSource
extension ProductVariationDropDown: UIPickerViewDataSource {
  public func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return attribute?.options?.count ?? 0
  }
  
  public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    return attribute?.options?[row].attributed.add([.color(.gunmetal), .font(.openSans(style: .regular(size: 13.0)))])
  }
}

// MARK: - UIPickerViewDelegate
extension ProductVariationDropDown: UIPickerViewDelegate {
  public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    guard let key = attribute?.name else { return }
    guard var metaData = delegate?.productVariationDropDownMetaData(dropDown: self) else { return }
    metaData[key] = attribute?.options?[row]
    textField.text = attribute?.options?[row]
    delegate?.productVariationDropDownDidUpdateMetaData(dropDown: self, metaData: metaData)
  }
}
