//
//  ProductsCCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 30/08/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import Kingfisher

public final class ProductsCCell: UICollectionViewCell, Shadowable, ProductProtocol {
  public var shadowLayer: CAShapeLayer!
  @IBOutlet private weak var containerView: DesignableView! {
    didSet {
      containerView.cornerRadius = 7.0
    }
  }
  @IBOutlet private weak var imageView: LoadingImageView! {
    didSet {
      imageView.cornerRadius = 1.0
      imageView.contentMode = .scaleAspectFit
    }
  }
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .idealSans(style: .book(size: 13.0))
      titleLabel.textColor = .lightNavy
    }
  }
  @IBOutlet private weak var priceLabel: UILabel! {
    didSet {
      priceLabel.font = .openSans(style: .regular(size: 13.0))
      priceLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var ratingLabel: UILabel!
  
  public var product: Product? {
    didSet {
      imageView.url = image?.url
      titleLabel.text = product?.name
      priceLabel.text = String(format: "%@%.2f", AppConstant.currencySymbol, product?.price ?? 0.0)
      let reviewAndRatingAttText = NSMutableAttributedString()
      let attributedRateString = NSMutableAttributedString()
      for indx in (1...5) {
        attributedRateString.append(" ".attributed)
        if averageRating >= Double(indx) {
          attributedRateString.append(MaterialDesignIcon.star.attributed.add([
            .color(.marigold),
            .font(.materialDesign(size: 14.0))]))
        } else {
          if averageRating.rounded() == averageRating || averageRating.rounded() < Double(indx) {
            attributedRateString.append(MaterialDesignIcon.star.attributed.add([
              .color(.whiteThree),
              .font(.materialDesign(size: 14.0))]))
          } else {
            attributedRateString.append(MaterialDesignIcon.starHalf.attributed.add([
              .color(.marigold),
              .font(.materialDesign(size: 14.0))]))
          }
        }
      }
      attributedRateString.append(" ".attributed)
      reviewAndRatingAttText.append(attributedRateString)
      if totalReviews > 1 {
        reviewAndRatingAttText.append("(\(totalReviews))".attributed.add([
          .color(.bluishGrey),
          .font(.openSans(style: .regular(size: 13.0)))]))
      }
      ratingLabel.attributedText = reviewAndRatingAttText    
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
extension ProductsCCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 167.0, height: 278.0)
  }
}
