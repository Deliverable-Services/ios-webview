//
//  Localizable.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 31/05/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit

/**************************************************************/

@IBDesignable final class UILocalizableLabel: UILabel {
  override func awakeFromNib() {
    super.awakeFromNib()
    text = text?.localized()
  }
  
  @IBInspectable var tableName:  String? = "Localizable" {
    didSet {
      guard let tableName = tableName else { return }
      text = text?.localized(tableName: tableName)
    }
  }
}

@IBDesignable final class UILocalizableButton: UIButton {
  override func awakeFromNib() {
    super.awakeFromNib()
    setTitle(titleLabel?.text?.localized(), for: .normal)
  }
  
  @IBInspectable var tableName:  String? = "Localizable" {
    didSet {
      guard let tableName = tableName else { return }
      setTitle(titleLabel?.text?.localized(tableName: tableName), for: .normal)
    }
  }
}

/**************************************************************/

protocol  Localizable {
  var tableName: String { get }
  var localized: String { get }
}

extension Localizable where Self: RawRepresentable, Self.RawValue == String {
  var localized: String {
    return rawValue.localized(tableName: tableName)
  }
}

enum LoginStrings: String, Localizable {
  case fb = "fb"
  
  var tableName: String {
    return "Login"
  }
  // use as LoginStrings.fb.localized
}

extension String {
  func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
    return NSLocalizedString(self, tableName: tableName, bundle: bundle, value: "\(self)", comment: "")
  }
}

/**************************************************************/
