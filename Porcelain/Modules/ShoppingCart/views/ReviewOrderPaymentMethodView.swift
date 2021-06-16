//
//  ReviewOrderPaymentMethodView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 2/26/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class ReviewOrderPaymentMethodView: DesignableView {
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
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var codeLabel: UILabel! {
    didSet {
      codeLabel.font = .openSans(style: .semiBold(size: 14.0))
      codeLabel.textColor = .gunmetal
    }
  }
  
  public var editDidTapped: VoidCompletion?
  
  public var paymentMethod: PaymentMethod? {
    didSet {
      if let image = paymentMethod?.image {
        imageView.isHidden = false
        imageView.image = image
      } else {
        imageView.isHidden = true
        imageView.image = nil
      }
      codeLabel.text = paymentMethod?.title
    }
  }
  
  public var card: Card? {
    didSet {
      if  let card = card, paymentMethod?.id == "stripe" {
        imageView.image = card.brandImage
        if let last4 = card.last4 {
          codeLabel.text = "**** **** **** \(last4)"
        } else {
          codeLabel.text = "N/A"
        }
      }
      imageView.isHidden = imageView.image == nil
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
    loadNib(ReviewOrderPaymentMethodView.self)
    addSubview(contentStack)
    contentStack.addSideConstraintsWithContainer()
  }
  
  @IBAction private func editTapped(_ sender: Any) {
    editDidTapped?()
  }
}
