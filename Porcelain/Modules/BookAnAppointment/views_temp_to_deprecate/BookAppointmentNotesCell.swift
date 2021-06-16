//
//  BookAppointmentNotesCell.swift
//  Porcelain
//
//  Created by Justine Rangel on 17/10/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public struct BookAppointmentNotesData {
  var title: String
  var content: String
  var placeholder: String
  var icon: UIImage?
}

public final class BookAppointmentNotesCell: UITableViewCell {
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var textView: DesignableTextView!
  @IBOutlet private weak var iconImageView: UIImageView!
  @IBOutlet private weak var separatorView: UIView!
  
  public var didUpdateText: StringCompletion?
  
  private var tempContent: String = ""
  public var data: BookAppointmentNotesData? {
    didSet {
      guard let data = data else { return }
      titleLabel.attributedText = NSAttributedString(
        content: data.title,
        font: UIFont.Porcelain.openSans(12.0, weight: .semiBold),
        foregroundColor: UIColor.Porcelain.greyishBrown,
        paragraphStyle: ParagraphStyle.makeCustomStyle(
          lineHeight: 18.0,
          characterSpacing: 0.4))
      if data.content.isEmpty {
        textView.text = data.placeholder
      } else {
        textView.text = data.content
      }
      iconImageView.image = data.icon
      titleLabel.isHidden = data.content.isEmpty
    }
  }
  
  public override func becomeFirstResponder() -> Bool {
    return textView.becomeFirstResponder()
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    iconImageView.tintColor = UIColor.Porcelain.greyishBrown
    let attributes = NSAttributedString.stringAttributesForFont(
      UIFont.Porcelain.openSans(14.0, weight: .regular),
      foregroundColor: UIColor.Porcelain.warmGrey,
      paragraphStyle: ParagraphStyle.makeCustomStyle(
        lineHeight: 14.0,
        characterSpacing: 0.5).wordWrapped())
    textView.typingAttributes = attributes
    textView.delegate = self
  }
}

// MARK: - CellProtocol
extension BookAppointmentNotesCell: CellProtocol {
  public static var defaultSize: CGSize {
    return .zero
  }
}

// MARK: - UITextViewDelegate
extension BookAppointmentNotesCell: UITextViewDelegate {
  public func textViewDidBeginEditing(_ textView: UITextView) {
    guard let content = data?.content else { return }
    if content.isEmpty && tempContent.isEmpty {
      titleLabel.isHidden = false
      textView.text = ""
      didUpdateText?(content)
    }
  }
  
  public func textViewDidEndEditing(_ textView: UITextView) {
    guard let content = data?.content else { return }
    if content.isEmpty && tempContent.isEmpty {
      titleLabel.isHidden = true
      textView.text = data?.placeholder
      didUpdateText?(content)
    }
  }
  
  public func textViewDidChange(_ textView: UITextView) {
    tempContent = textView.text
    didUpdateText?(textView.text)
  }
}
