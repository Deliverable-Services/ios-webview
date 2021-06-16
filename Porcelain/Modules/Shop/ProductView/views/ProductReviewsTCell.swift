//
//  ProductReviewsTCell.swift
//  Porcelain
//
//  Created by Justine Rangel on 24/11/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct ProductReviewTextAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? = 0.43
  var alignment: NSTextAlignment?
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat? = 22.0
  var font: UIFont? = .openSans(style: .italic(size: 13.0))
  var color: UIColor? = .bluishGrey
}

public final class ProductReviewsTCell: UITableViewCell {
  @IBOutlet private weak var containerView: DesignableView!
  @IBOutlet private weak var ratingLabel: UILabel!
  @IBOutlet private weak var dateLabel: UILabel! {
    didSet {
      dateLabel.font = .openSans(style: .regular(size: 12.0))
      dateLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var descriptionLabel: UILabel!
  @IBOutlet private weak var reviewerNameLabel: UILabel! {
    didSet {
      reviewerNameLabel.font = .openSans(style: .semiBold(size: 12.0))
      reviewerNameLabel.textColor = .gunmetal
    }
  }
  
  private var size: CGSize = .zero
  
  public var review: Review? {
    didSet {
      let rate = max(review?.rate ?? 0, 1)
      let attributedRateString = NSMutableAttributedString()
      for indx in (1...5) {
        if rate >= indx {
          attributedRateString.append(MaterialDesignIcon.star.attributed.add([
            .color(.marigold),
            .font(.materialDesign(size: 14.0))]))
        } else {
          attributedRateString.append(MaterialDesignIcon.star.attributed.add([
            .color(.whiteThree),
            .font(.materialDesign(size: 14.0))]))
        }
      }
      ratingLabel.attributedText = attributedRateString
      dateLabel.text = review?.dateCreated?.toString(WithFormat: "MM/dd/yy")
      descriptionLabel.attributedText = review?.review?.attributed.add(.appearance(ProductReviewTextAppearance()))
      reviewerNameLabel.text = review?.reviewer
    }
  }
  
  public override func layoutIfNeeded() {
    super.layoutIfNeeded()
    
    if size != frame.size {
      size = frame.size
      containerView.addShadow(appearance: .default)
    }
  }
}

// MARK: - CellProtocol
extension ProductReviewsTCell: CellProtocol {
  public static var defaultSize: CGSize {
    return .zero
  }
}
