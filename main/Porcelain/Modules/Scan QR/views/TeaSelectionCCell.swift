//
//  TeaSelectionCCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 01/10/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct AttributedTitleAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? {
    return 1.0
  }
  var alignment: NSTextAlignment? {
    return .center
  }
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat? {
    return 23.0
  }
  var font: UIFont? {
    return .openSans(style: .semiBold(size: 13.0))
  }
  var color: UIColor? {
    return .lightNavy
  }
}

private struct AttributedDescriptionAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? {
    return 1.0
  }
  var alignment: NSTextAlignment? {
    return .center
  }
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat? {
    return 22.0
  }
  var font: UIFont? {
    return .idealSans(style: .book(size: 16.0))
  }
  var color: UIColor? {
    return .gunmetal
  }
}

public final class TeaSelectionCCell: UICollectionViewCell {
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var descriptionLabel: UILabel!
  
  public var data: TeaItemData? {
    didSet {
      titleLabel.attributedText = data?.name?.attributed.add(.appearance(AttributedTitleAppearance()))
      descriptionLabel.attributedText = data?.description?.attributed.add(.appearance(AttributedDescriptionAppearance()))
    }
  }
  
  public override var alpha: CGFloat {
    didSet {
      guard imageView != nil else { return }
      imageView.image = imageView.image?.maskWithColor(alpha > 0.7 ? .lightNavy:.gunmetal)
    }
  }
}

// MARK: - CellProtocol
extension TeaSelectionCCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 180.0, height: 200.0)
  }
}
