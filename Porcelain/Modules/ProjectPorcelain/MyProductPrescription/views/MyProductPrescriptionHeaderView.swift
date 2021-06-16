//
//  MyProductPrescriptionHeaderView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 27/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public protocol MyProductPrescriptionHeaderViewModel {
  func shopNowDidTapped()
  func myProductsDidTapped()
}

public final class MyProductPrescriptionHeaderView: UIView {
  @IBOutlet private weak var curtainView: UIView!
  @IBOutlet private weak var showNowButton: ProjectPorcelainHeaderButton! {
    didSet {
      showNowButton.fillColor = .greyblue
      showNowButton.image = UIImage.icShopNow
      showNowButton.title = "SHOP NOW"
    }
  }
  @IBOutlet private weak var myProductsButton: ProjectPorcelainHeaderButton! {
    didSet {
      myProductsButton.fillColor = .lightNavy
      myProductsButton.image = UIImage.icMyProducts
      myProductsButton.title = "MY PRODUCTS"
    }
  }

  public var viewModel: MyProductPrescriptionHeaderViewModel?
  
  @IBAction private func showNowTapped(_ sender: Any) {
    viewModel?.shopNowDidTapped()
  }
  
  @IBAction private func myProductsTapped(_ sender: Any) {
    viewModel?.myProductsDidTapped()
  }
}

public final class ProjectPorcelainHeaderButton: DesignableControl {
  @IBOutlet private weak var contentStack: UIStackView!
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .idealSans(style: .light(size: 12.0))
      titleLabel.textColor = .white
    }
  }
  
  public var image: UIImage?
  public var title: String?
  public var fillColor: UIColor? {
    didSet {
      var appearance = ShadowAppearance.default
      if let fillColor = fillColor {
        appearance.fillColor = fillColor
      }
      addShadow(appearance: appearance)
    }
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    imageView.image = image
    titleLabel.text = title
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    var appearance = ShadowAppearance.default
    if let fillColor = fillColor {
      appearance.fillColor = fillColor
    }
    addShadow(appearance: appearance)
  }
  
  public override var isHighlighted: Bool {
    didSet {
      contentStack.alpha = isHighlighted ? 0.8: 1.0
    }
  }
}
