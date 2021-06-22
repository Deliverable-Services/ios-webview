//
//  SyncProfileCell.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 04/07/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit

class SyncProfileTextFieldCell: UITableViewCell {
  var updatedTextFieldBlock: ((String)->())?
  @IBOutlet weak var textField: UITextField! 
  
  static var identifier: String = String(describing: SyncProfileTextFieldCell.self)
  
  public func configure(text: String?, placeholder: String) {
    self.textField.placeholder = placeholder
    self.textField.text = text
  }
  
  @IBAction func editingChanged(textField: UITextField) {
    self.updatedTextFieldBlock?(textField.text!)
  }
}
