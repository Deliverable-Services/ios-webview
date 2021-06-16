//
//  FeedbackPurchaseView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 16/08/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import Kingfisher

public final class FeedbackPurchaseView: DesignableView, PurchaseProtocol {
  @IBOutlet private weak var view: UIView!
  @IBOutlet private weak var fpPurchaseTableView: FeedbackProductPurchaseTableView!
  @IBOutlet private weak var separatorView: UIView!
  @IBOutlet private weak var subTotalTitleLabel: UILabel! {
    didSet {
      subTotalTitleLabel.font = .openSans(style: .regular(size: 14.0))
      subTotalTitleLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var subTotalLabel: UILabel! {
    didSet {
      subTotalLabel.font = .openSans(style: .regular(size: 14.0))
      subTotalLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var shippingTitleLabel: UILabel! {
    didSet {
      shippingTitleLabel.font = .openSans(style: .regular(size: 14.0))
      shippingTitleLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var shippingLabel: UILabel! {
    didSet {
      shippingLabel.font = .openSans(style: .regular(size: 14.0))
      shippingLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var totalDiscountStack: UIStackView!
  @IBOutlet private weak var totalDiscountTitleLabel: UILabel! {
    didSet {
      totalDiscountTitleLabel.font = .openSans(style: .regular(size: 14.0))
      totalDiscountTitleLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var totalDiscountLabel: UILabel! {
    didSet {
      totalDiscountLabel.font = .openSans(style: .regular(size: 14.0))
      totalDiscountLabel.textColor = UIColor(hex: 0xc86767)
    }
  }
  @IBOutlet private weak var totalAmountTitleLabel: UILabel! {
    didSet {
      totalAmountTitleLabel.font = .openSans(style: .semiBold(size: 14.0))
      totalAmountTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var totalAmountLabel: UILabel! {
    didSet {
      totalAmountLabel.font = .openSans(style: .semiBold(size: 14.0))
      totalAmountLabel.textColor = .gunmetal
    }
  }
  
  public var purchase: Purchase? {
    didSet {
      updateUI()
    }
  }
  
  public convenience init(purchase: Purchase) {
    self.init(frame: .zero)
    
    self.purchase = purchase
    updateUI()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    commonInit()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    commonInit()
  }
  
  private func commonInit() {
    loadNib(FeedbackPurchaseView.self)
    addSubview(view)
    view.addContainerBoundsResizingMask()
    cornerRadius = 7.0
    borderWidth = 1.0
    borderColor = .whiteThree
    backgroundColor = .white
  }
  
  private func updateUI() {
    fpPurchaseTableView.productVariations = purchase?.productVariations
    fpPurchaseTableView.purchasedItems = purchasedItems
    subTotalLabel.text = String(format: "%@%.2f", AppConstant.currencySymbol, subtotal)
    if shipping > 0.0 {
      shippingLabel.text = String(format: "%@%.2f", AppConstant.currencySymbol, shipping)
    } else {
      shippingLabel.text = "Free"
    }
    totalDiscountStack.isHidden = totalDiscount == 0
    totalDiscountLabel.text = String(format: "-%@%.2f", AppConstant.currencySymbol, totalDiscount)
    totalAmountLabel.text = String(format: "%@%.2f", AppConstant.currencySymbol, totalAmount)
  }
}

public final class FeedbackProductPurchaseTableView: ResizingContentTableView {
  public var productVariations: [ProductVariation]?
  public var purchasedItems: [Purchase.Item]? {
    didSet {
      reloadData()
    }
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    separatorStyle = .none
    registerWithNib(FeedbackProductPurchaseTCell.self)
    dataSource = self
    delegate = self
  }
}

// MARK: - UITableViewDataSource
extension FeedbackProductPurchaseTableView: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return purchasedItems?.count ?? 0
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let feedbackProductPurchaseTCell = tableView.dequeueReusableCell(FeedbackProductPurchaseTCell.self, atIndexPath: indexPath)
    feedbackProductPurchaseTCell.productVariations = productVariations
    feedbackProductPurchaseTCell.purchasedItem = purchasedItems?[indexPath.row]
    return feedbackProductPurchaseTCell
  }
}

// MARK: - UITableViewDelegate
extension FeedbackProductPurchaseTableView: UITableViewDelegate {
}

public final class FeedbackProductPurchaseTCell: UITableViewCell {
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
  
  public var productVariations: [ProductVariation]?
  public var purchasedItem: Purchase.Item? {
    didSet {
      productImageView.url = purchasedItem?.product?.images?.first?.url
      nameLabel.text = [purchasedItem?.product?.categoryName, purchasedItem?.product?.name].compactMap({ $0 }).joined(separator: ", ")
      priceLabel.text = String(format: "%@%.2f | Quantity: %d", AppConstant.currencySymbol, purchasedItem?.price ?? 0.0, purchasedItem?.quantity ?? 0)
      if let metaData = productVariations?.first(where: { $0.id == purchasedItem?.variationID })?.metaData, !metaData.isEmpty {
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
extension FeedbackProductPurchaseTCell: CellProtocol {
}
