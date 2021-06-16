//
//  CartItemsTCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 2/22/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import SwipeCellKit

public protocol CartItemsTCellDelegate: class {
  func cartItemsTCellWillRemoveProduct(item: ShoppingCartItem)
  func cartItemsTCellDidUpdateProduct(item: ShoppingCartItem)
}

public final class CartItemsTCell: SwipeTableViewCell {
  @IBOutlet private weak var containerView: DesignableView! {
    didSet {
      containerView.cornerRadius = 7.0
    }
  }
  @IBOutlet private weak var productImageView: LoadingImageView! {
    didSet {
      productImageView.cornerRadius = 1.0
      productImageView.contentMode = .scaleAspectFill
    }
  }
  @IBOutlet private weak var nameLabel: UILabel! {
    didSet {
      nameLabel.font = .idealSans(style: .book(size: 14.0))
      nameLabel.textColor = .lightNavy
    }
  }
  @IBOutlet private weak var priceLabel: UILabel! {
    didSet {
      priceLabel.font = .openSans(style: .semiBold(size: 14.0))
      priceLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var decrementButton: DesignableButton! {
    didSet {
      decrementButton.cornerRadius = 4.0
      decrementButton.backgroundColor = .greyblue
      decrementButton.setAttributedTitle(
        "–".attributed.add([
        .baseline(offset: 2.0),
        .color(.white),
        .font(.openSans(style: .semiBold(size: 22.0)))]),
      for: .normal)
    }
  }
  @IBOutlet private weak var countButton: UIButton!
  @IBOutlet private weak var incrementButton: DesignableButton! {
    didSet {
      incrementButton.cornerRadius = 4.0
      incrementButton.backgroundColor = .greyblue
      incrementButton.setAttributedTitle(
        "+".attributed.add([
        .color(.white),
        .font(.openSans(style: .semiBold(size: 22.0)))]),
      for: .normal)
    }
  }
  @IBOutlet private weak var variationStack: UIStackView!
  
  private var count: String? {
    didSet {
      countButton.setAttributedTitle(
        count?.attributed.add([
          .color(.gunmetal),
          .font(.openSans(style: .semiBold(size: 18.0)))]),
        for: .normal)
    }
  }
  
  public weak var cellDelegate: CartItemsTCellDelegate?
  
  public var data: ShoppingCartItem? {
    didSet {
      let product = data?.product
      productImageView.url = data?.image?.url
      nameLabel.text = [product?.categoryName, product?.name].compactMap({ $0 }).joined(separator: ", ")
      priceLabel.text = String(format: "%@%.2f", AppConstant.currencySymbol, data?.price ?? 0)
      count = "\(data?.quantity ?? 0)"
      if let metaData = data?.productVariation?.metaData, !metaData.isEmpty {
        variationStack.removeAllArrangedSubviews()
        variationStack.isHidden = false
        metaData.sorted(by: { $0.key < $1.key }).forEach { (dict) in
          let variationHorizontalStack = UIStackView()
          variationHorizontalStack.axis = .horizontal
          variationHorizontalStack.spacing = 8.0
          variationHorizontalStack.alignment = .top
          let contentTitleLabel = UILabel()
          contentTitleLabel.font = .openSans(style: .semiBold(size: 13.0))
          contentTitleLabel.textColor = .gunmetal
          contentTitleLabel.text = "\(dict.key):"
          contentTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
          variationHorizontalStack.addArrangedSubview(contentTitleLabel)
          let contentLabel = UILabel()
          contentLabel.font = .openSans(style: .regular(size: 13.0))
          contentLabel.numberOfLines = 0
          contentLabel.textColor = .bluishGrey
          contentLabel.text = dict.value
          variationHorizontalStack.addArrangedSubview(contentLabel)
          variationStack.addArrangedSubview(variationHorizontalStack)
        }
      } else {
        variationStack.isHidden = true
      }
    }
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
  
    containerView.addShadow(appearance: .default)
  }
  
  @IBAction private func decrementTapped(_ sender: Any) {
    guard let item = data else { return }
    guard item.quantity > 1 else {
      cellDelegate?.cartItemsTCellWillRemoveProduct(item: item)
      return
    }
    item.quantity = item.quantity - 1
    ShoppingCart.shared.saveCart()
    count = "\(item.quantity)"
    cellDelegate?.cartItemsTCellDidUpdateProduct(item: item)
  }
  
  @IBAction private func incrementTapped(_ sender: Any) {
    guard let item = data else { return }
    item.quantity = item.quantity + 1
    ShoppingCart.shared.saveCart()
    count = "\(item.quantity)"
    cellDelegate?.cartItemsTCellDidUpdateProduct(item: item)
  }
}

// MARK: - CellProtocol
extension CartItemsTCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 86.0)
  }
}
