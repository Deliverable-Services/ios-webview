//
//  ShippingMethodTCell.swift
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

public final class ShippingMethodTCell: UITableViewCell {
  @IBOutlet private weak var selectionImageView: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .semiBold(size: 14.0))
      titleLabel.numberOfLines = 2
      titleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var descriptionLabel: UILabel!
  
  public var shippingMethod: ShippingMethod? {
    didSet {
      if let shippingCost = shippingMethod?.cost, shippingCost > 0 {
        titleLabel.text = [shippingMethod?.title, String(format: "%@%.2f", AppConstant.currencySymbol, shippingCost)].compactMap({ $0 }).joined(separator: ": ")
      } else {
        titleLabel.text = shippingMethod?.title
      }
      descriptionLabel.attributedText = shippingMethod?.description?.attributed.add(.appearance(AttributedDescriptionAppearance()))
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
}

// MARK: - CellProtocol
extension ShippingMethodTCell: CellProtocol {
}
