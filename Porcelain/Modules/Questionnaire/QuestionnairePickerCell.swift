//
//  QuestionnaireCell.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 01/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit

class QuestionnairePickerCell: UITableViewCell {
  static var identifier: String = String(describing: QuestionnairePickerCell.self)
  static var estimatedCellHeight: CGFloat = 250.0
  
  private struct Constant {
    static let dateFormat = "MMMM dd, yyyy"
  }
  
  @IBOutlet private weak var pickerLabel: UILabel!
  @IBOutlet private weak var pickerButton: UIButton!
  
  var pickerButtonClickedBlock: (() -> ())?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.pickerButton.addCustomShadow()
  }
  
  @IBAction func pickerButtonClicked(_ sender: Any) {
    self.pickerButtonClickedBlock?()
  }
  
  func configure(buttonLabel: String?, backgroundColor: UIColor) {
    contentView.backgroundColor = backgroundColor
    self.pickerButton.setTitle(buttonLabel, for: .normal)
  }
}
