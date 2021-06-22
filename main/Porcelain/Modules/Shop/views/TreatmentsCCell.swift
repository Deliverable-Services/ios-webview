//
//  TreatmentsCCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 22/08/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct TreatmentAttrDescriptionAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double?
  var alignment: NSTextAlignment?
  var lineBreakMode: NSLineBreakMode? {
    return .byTruncatingTail
  }
  var minimumLineHeight: CGFloat? {
    return 18.0
  }
  var font: UIFont?  {
    return .idealSans(style: .light(size: 12.0))
  }
  var color: UIColor? {
    return .bluishGrey
  }
}

public final class TreatmentsCCell: UICollectionViewCell, Shadowable {
  public var shadowLayer: CAShapeLayer!
  
  @IBOutlet private weak var imageView: LoadingImageView! {
    didSet {
      imageView.placeholderImage = .imgLandscapePlaceholder
      imageView.cornerRadius = 1.0
    }
  }
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .idealSans(style: .book(size: 12.0))
      titleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var descriptionLabel: UILabel!
  
  
  public var treatment: Treatment? {
    didSet {
      imageView.url = treatment?.image
      titleLabel.text = treatment?.name?.uppercased()
      descriptionLabel.attributedText = treatment?.desc?.attributed.add(.appearance(TreatmentAttrDescriptionAppearance()))
    }
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    addShadow(appearance: .default)
  }
  
  public override func prepareForReuse() {
    super.prepareForReuse()
    
    imageView.kf.cancelDownloadTask()
    imageView.image = nil
  }
}

// MARK: - CellProtocol
extension TreatmentsCCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 234.0)
  }
}
