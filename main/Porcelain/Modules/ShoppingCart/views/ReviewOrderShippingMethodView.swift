//
//  ReviewOrderShippingMethodView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 2/26/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class ReviewOrderShippingMethodView: DesignableView {
  @IBOutlet private weak var contentStack: UIStackView!
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .semiBold(size: 14.0))
      titleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var editButton: UIButton! {
    didSet {
      editButton.setAttributedTitle(
        "EDIT".attributed.add([.color(.lightNavy), .font(.openSans(style: .semiBold(size: 13.0)))]),
        for: .normal)
    }
  }
  @IBOutlet private weak var nameLabel: UILabel! {
    didSet {
      nameLabel.font = .openSans(style: .regular(size: 14.0))
      nameLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var descriptionLabel: UILabel! {
    didSet {
      descriptionLabel.font = .openSans(style: .regular(size: 14.0))
      descriptionLabel.textColor = .bluishGrey
    }
  }
  
  public var editDidTapped: VoidCompletion?
  
  public var shippingMethod: ShippingMethod? {
    didSet {
      if let shippingCost = shippingMethod?.cost, shippingCost > 0 {
        nameLabel.text = [shippingMethod?.title, String(format: "%@%.2f", AppConstant.currencySymbol, shippingCost)].compactMap({ $0 }).joined(separator: ": ")
      } else {
        nameLabel.text = shippingMethod?.title
      }
      descriptionLabel.text = nil
    }
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
    loadNib(ReviewOrderShippingMethodView.self)
    addSubview(contentStack)
    contentStack.addSideConstraintsWithContainer()
  }
  
  @IBAction private func editTapped(_ sender: Any) {
    editDidTapped?()
  }
}
