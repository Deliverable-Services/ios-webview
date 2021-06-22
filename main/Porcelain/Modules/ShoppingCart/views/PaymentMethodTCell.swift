//
//  PaymentMethodTCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 2/26/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct AttributedDescriptionAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? = 0.46
  var alignment: NSTextAlignment? = .left
  var lineBreakMode: NSLineBreakMode? = .byWordWrapping
  var minimumLineHeight: CGFloat? = 20.0
  var font: UIFont? = .openSans(style: .regular(size: 13.0))
  var color: UIColor? = .gunmetal
}

public final class PaymentMethodTCell: UITableViewCell, CardProtocol {
  @IBOutlet private weak var selectionImageView: UIImageView!
  @IBOutlet private weak var titleImageView: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .semiBold(size: 14.0))
      titleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var descriptionLabel: UILabel!
  @IBOutlet private weak var cCardStack: UIStackView!
  @IBOutlet private weak var cCardImageView: UIImageView!
  @IBOutlet private weak var cCardLast4Label: UILabel! {
    didSet {
      cCardLast4Label.font = .openSans(style: .semiBold(size: 14.0))
      cCardLast4Label.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var cCardChageButton: UIButton! {
    didSet {
      cCardChageButton.setAttributedTitle(
        "CHANGE".attributed.add([
          .color(.lightNavy),
          .font(.openSans(style: .semiBold(size: 13.0)))]),
        for: .normal)
    }
  }
  @IBOutlet private weak var cCardExpLabel: UILabel! {
    didSet {
      cCardExpLabel.font = .openSans(style: .regular(size: 13.0))
      cCardExpLabel.textColor = .gunmetal
    }
  }
  
  public var changeDidTapped: VoidCompletion?
  
  public var paymentMethod: PaymentMethod? {
    didSet {
      if let image = paymentMethod?.image {
        titleImageView.isHidden = false
        titleImageView.image = image
      } else {
        titleImageView.isHidden = true
      }
      titleLabel.text = paymentMethod?.title
      descriptionLabel.attributedText = paymentMethod?.description?.attributed.add(.appearance(AttributedDescriptionAppearance()))
    }
  }
  
  public var card: Card? {
    didSet {
      if let card = card, paymentMethod?.id == "stripe" {
        cCardStack.isHidden = false
        cCardImageView.image = card.brandImage
        if let last4 = card.last4 {
          cCardLast4Label.text = "**** **** **** \(last4)"
        } else {
          cCardLast4Label.text = "N/A"
        }
        cCardExpLabel.text = "EXP. \(card.expMonth)/\(card.expYear)"
      } else {
        cCardStack.isHidden = true
      }
    }
  }
  
  public override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    updateSelection(isSelected: selected)
  }
  
  private func updateSelection(isSelected: Bool) {
    selectionImageView.image = isSelected ? .icRadioSelected: .icRadioUnselected
    backgroundColor = isSelected ? .white: .clear
  }
  
  @IBAction private func cCardChangeTapped(_ sender: Any) {
    changeDidTapped?()
  }
}

// MARK: - CellProtocol
extension PaymentMethodTCell: CellProtocol {
}
