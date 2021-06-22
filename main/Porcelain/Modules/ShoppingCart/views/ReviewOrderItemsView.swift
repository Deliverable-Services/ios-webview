//
//  OrdersListView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 18/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import Kingfisher

public final class ReviewOrderItemsView: ResizingContentTableView, Designable {
  @IBInspectable
  public var cornerRadius: CGFloat = 0.0 {
    didSet {
      updateLayer()
    }
  }
  
  @IBInspectable
  public var borderWidth: CGFloat = 0.0 {
    didSet {
      updateLayer()
    }
  }
  
  @IBInspectable
  public var borderColor: UIColor = .clear {
    didSet {
      updateLayer()
    }
  }
  
  public var cartItems: [ShoppingCartItem]? {
    didSet {
      reloadData()
    }
  }
  
  public var purchasedItems: [ORPurchasedItem]? {
    didSet {
      reloadData()
    }
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    setAutomaticDimension()
    registerWithNib(ReviewOrderItemsTCell.self)
    separatorStyle = .singleLine
    separatorColor = .whiteThree
    separatorInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
    isScrollEnabled = false
    dataSource = self
    updateLayer()
  }
}

// MARK: - UITableViewDataSource
extension ReviewOrderItemsView: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cartItems?.count ?? purchasedItems?.count ?? 0
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let reviewOrderItemsTCell = tableView.dequeueReusableCell(ReviewOrderItemsTCell.self, atIndexPath: indexPath)
    if let cartItems = cartItems {
      reviewOrderItemsTCell.data = cartItems[indexPath.row]
    } else {
      reviewOrderItemsTCell.purchasedItem = purchasedItems?[indexPath.row]
    }
    return reviewOrderItemsTCell
  }
}

public final class ReviewOrderItemsTCell: UITableViewCell {
  @IBOutlet private weak var productImageView: LoadingImageView! {
    didSet {
      productImageView.cornerRadius = 1.0
      productImageView.contentMode = .scaleAspectFill
    }
  }
  @IBOutlet private weak var nameLabel: UILabel! {
    didSet {
      nameLabel.font = .idealSans(style: .book(size: 16.0))
      nameLabel.textColor = .lightNavy
    }
  }
  @IBOutlet private weak var priceLabel: UILabel! {
    didSet {
      priceLabel.font = .openSans(style: .semiBold(size: 14.0))
      priceLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var variationStack: UIStackView!
  
  public var data: ShoppingCartItem? {
    didSet {
      let product = data?.product
      productImageView.url = data?.image?.url
      nameLabel.text = [product?.categoryName, product?.name].compactMap({ $0 }).joined(separator: ", ")
      priceLabel.text = String(format: "%@%.2f | Quantity: %d", AppConstant.currencySymbol, data?.price ?? 0.0, data?.quantity ?? 0)
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
  
  public var purchasedItem: ORPurchasedItem? {
    didSet {
      productImageView.url = purchasedItem?.image
      nameLabel.text = purchasedItem?.name
      priceLabel.text = String(format: "%@%.2f | Quantity: %d", AppConstant.currencySymbol, purchasedItem?.price ?? 0.0, purchasedItem?.quantity ?? 0)
      if let metaData = purchasedItem?.productVariation?.metaData, !metaData.isEmpty {
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
}

// MARK: - CellProtocol
extension ReviewOrderItemsTCell: CellProtocol {
}
