//
//  BookAppointmentTextFieldCell.swift
//  Porcelain
//
//  Created by Justine Rangel on 15/10/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public struct BookAppointmentTextFieldData {
  var title: String
  var content: String
  var placeholder: String
  var icon: UIImage?
}

public final class BookAppointmentTextFieldCell: UITableViewCell {
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var textField: UITextField!
  @IBOutlet private weak var iconImageView: UIImageView!
  @IBOutlet private weak var separatorView: UIView!
  
  public var didBeginEditing: VoidCompletion?
  
  public var data: BookAppointmentTextFieldData? {
    didSet {
      guard let data = data else { return }
      titleLabel.attributedText = NSAttributedString(
        content: data.title,
        font: UIFont.Porcelain.openSans(12.0, weight: .semiBold),
        foregroundColor: UIColor.Porcelain.greyishBrown,
        paragraphStyle: ParagraphStyle.makeCustomStyle(
          lineHeight: 18.0,
          characterSpacing: 0.4))
      textField.text = data.content
      textField.attributedPlaceholder = NSAttributedString(
        content: data.placeholder,
        font: UIFont.Porcelain.openSans(14.0, weight: .regular),
        foregroundColor: UIColor.Porcelain.warmGrey,
        paragraphStyle: ParagraphStyle.makeCustomStyle(
          lineHeight: 14.0,
          characterSpacing: 0.5))
      iconImageView.image = data.icon
      titleLabel.isHidden = data.content.isEmpty
    }
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    iconImageView.tintColor = UIColor.Porcelain.greyishBrown
    let attributes = NSAttributedString.stringAttributesForFont(
      UIFont.Porcelain.openSans(14.0, weight: .regular),
      foregroundColor: UIColor.Porcelain.warmGrey,
      paragraphStyle: ParagraphStyle.makeCustomStyle(
        lineHeight: 14.0,
        characterSpacing: 0.5))
    textField.defaultTextAttributes = attributes
    textField.typingAttributes = attributes
    textField.delegate = self
  }
}

// MARK: - CellProtocol
extension BookAppointmentTextFieldCell: CellProtocol {
  public static var defaultSize: CGSize {
    return .zero
  }
}

// MARK: - UITextFieldDelegate
extension BookAppointmentTextFieldCell: UITextFieldDelegate {
  public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    didBeginEditing?()
    return false
  }
}
