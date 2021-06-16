//
//  ProductViewHeaderView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 3/9/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import SwiftyJSON

private struct AttributedTitleTextAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? = 0.0
  var alignment: NSTextAlignment? = .left
  var lineBreakMode: NSLineBreakMode? = .byWordWrapping
  var minimumLineHeight: CGFloat? = 26.0
  var font: UIFont? = .idealSans(style: .book(size: 18.0))
  var color: UIColor? = .gunmetal
}

private struct AttributedDescriptionTextAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? = 0.54
  var alignment: NSTextAlignment? = .left
  var lineBreakMode: NSLineBreakMode? = .byWordWrapping
  var minimumLineHeight: CGFloat? = 22.0
  var font: UIFont? = .openSans(style: .regular(size: 13.0))
  var color: UIColor? = .bluishGrey
}

public struct ProductViewHeaderData: ProductProtocol {
  public static let cleanRegex = #"body \{font[^ª]+px\}"#
  public init(product: Product, availableVariations: [ProductVariation]?) {
    self.product = product
    self.availableVariations = availableVariations
  }
  
  public var product: Product?
  
  public var inStock: Bool {
    return product?.inStock ?? false
  }
  
  public var availableVariations: [ProductVariation]?
  
  public var hasVariations: Bool {
    guard let availableVariations = availableVariations else { return false }
    return !availableVariations.isEmpty
  }

  public var reviewAndRating: NSAttributedString? {
    let reviewAndRatingAttText = NSMutableAttributedString()
    let reviewTitle: String
    if totalReviews == 0 {
      reviewTitle = "No Reviews"
    } else {
      reviewAndRatingAttText.append(
        String(format: "%.2f", averageRating).attributed.add([
          .color(.gunmetal),
          .font(.openSans(style: .semiBold(size: 14.0)))]))
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
      reviewTitle = "\(totalReviews) Review\(totalReviews > 1 ? "s": "")"
    }
    reviewAndRatingAttText.append(reviewTitle.attributed.add([
      .color(.gunmetal),
      .font(.openSans(style: .semiBold(size: 14.0)))]))
    return reviewAndRatingAttText
  }
}

public final class ProductViewHeaderView: UIView {
  @IBOutlet private weak var view: UIView!
  @IBOutlet private weak var imageGalleryView: ImageGalleryView!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var priceLabel: UILabel! {
    didSet {
      priceLabel.font = .openSans(style: .semiBold(size: 14.0))
      priceLabel.textColor = .lightNavy
    }
  }
  @IBOutlet private weak var regularPriceLabel: UILabel!
  @IBOutlet private weak var outOfStock: DesignableButton! {
    didSet {
      outOfStock.cornerRadius = 4.0
      outOfStock.borderWidth = 1.0
      outOfStock.borderColor = .coral
      outOfStock.isUserInteractionEnabled = false
    }
  }
  @IBOutlet private weak var ratingsLabel: UILabel!
  @IBOutlet private weak var descriptionLabel: UILabel! {
    didSet {
      descriptionLabel.isHidden = true
    }
  }
  @IBOutlet private weak var whatsIncludedStack: UIStackView!
  @IBOutlet private weak var whatsIncludedTitleLabel: UILabel! {
    didSet {
      whatsIncludedTitleLabel.font = .openSans(style: .semiBold(size: 14.0))
      whatsIncludedTitleLabel.textColor = .lightNavy
    }
  }
  @IBOutlet private weak var variationStack: UIStackView!
  @IBOutlet private weak var addToBasketButton: DesignableButton! {
    didSet {
      addToBasketButton.cornerRadius = 7.0
      addToBasketEnabled = false
    }
  }
  
  public private(set) var addToBasketEnabled: Bool = true {
    didSet {
      addToBasketButton.isUserInteractionEnabled = addToBasketEnabled
      addToBasketButton.backgroundColor = addToBasketEnabled ? .greyblue: .whiteThree
      addToBasketButton.setAttributedTitle(
        "ADD TO BASKET".attributed.add([
          .color(addToBasketEnabled ? .white: .bluishGrey),
          .font(.idealSans(style: .book(size: 14.0)))]),
        for: .normal)
    }
  }
  
  public var didUpdateBasket: VoidCompletion?
  public var addToBasketDidTapped: VoidCompletion?
  
  private var attributesCount = 0
  private var metaData: [String: String] = [:]
  public private(set) var productVariation: ProductVariation?
  
  public var didUpdateSize: VoidCompletion?
  
  public var hasError: Bool = false
  
  public var data: ProductViewHeaderData? {
    didSet {
      if let images = data?.images, !images.isEmpty {
        imageGalleryView.isHidden = false
        imageGalleryView.galleryImages = images.map({ $0.url })
      } else {
        imageGalleryView.isHidden = true
      }
      titleLabel.attributedText = data?.productName?.attributed.add(.appearance(AttributedTitleTextAppearance()))
      priceLabel.text = String(format: "%@%.2f", AppConstant.currencySymbol, data?.price ?? 0.0)
      if let onSale = data?.onSale, onSale {
        regularPriceLabel.isHidden = false
        regularPriceLabel.attributedText = String(format: "%@%.2f", AppConstant.currencySymbol, data?.regularPrice ?? 0.0).attributed.add([
          .color(.coral),
          .font(.openSans(style: .semiBold(size: 14.0))),
          .strikethroughColor(.coral),
          .strikethroughStyle(.styleSingle)
        ])
      } else {
        regularPriceLabel.isHidden = true
      }
      outOfStock.isHidden = data?.inStock ?? true
      ratingsLabel.attributedText = data?.reviewAndRating
      if let attributes = data?.attributes, !attributes.isEmpty, data?.hasVariations ?? false {
        attributesCount = attributes.count
        whatsIncludedStack.isHidden = false
        variationStack.removeAllArrangedSubviews()
        attributes.forEach { (attribute) in
          let productVariationDropDown = ProductVariationDropDown()
          productVariationDropDown.attribute = attribute
          productVariationDropDown.delegate = self
          productVariationDropDown.reload()
          variationStack.addArrangedSubview(productVariationDropDown)
        }
      } else {
        attributesCount = 0
        whatsIncludedStack.isHidden = true
      }
      validateAddToBasket()
    }
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    didUpdateSize?()
  }
  
  private func validateAddToBasket() {
    let inStock = data?.inStock ?? false
    if attributesCount > 0 {//should have variation
      if let productVariation = data?.availableVariations?.first(where: { $0.metaData == metaData }) {
        self.productVariation = productVariation
        priceLabel.text = String(format: "%@%.2f", AppConstant.currencySymbol, productVariation.price)
        addToBasketEnabled = productVariation.inStock && !hasError
      } else {
        productVariation = nil
        addToBasketEnabled = false
      }
    } else {
      productVariation = nil
      if data?.hasVariations ?? false {
        addToBasketEnabled = attributesCount == metaData.count && inStock
      } else {
        addToBasketEnabled = inStock && !hasError
      }
    }
    didUpdateBasket?()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    commonInit()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    commonInit()
  }
  
  private func commonInit() {
    loadNib(ProductViewHeaderView.self)
    addSubview(view)
    view.addSideConstraintsWithContainer()
  }
  
  @IBAction private func addToBasketTapped(_ sender: Any) {
    addToBasketDidTapped?()
  }
}

private struct DropDownData: DropDownDataProtocol {
  var title: String?
  
  var subtitle: String? { return nil }
}

// MARK: - ProductVariationDropDownDelegate
extension ProductViewHeaderView: ProductVariationDropDownDelegate {
  public func productVariationDropDownMetaData(dropDown: ProductVariationDropDown) -> [String : String]? {
    return metaData
  }
  
  public func productVariationDropDownDidUpdateMetaData(dropDown: ProductVariationDropDown, metaData: [String : String]?) {
    self.metaData = metaData ?? [:]
    validateAddToBasket()
  }
}
