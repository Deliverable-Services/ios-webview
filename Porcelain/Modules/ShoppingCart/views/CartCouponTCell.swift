//
//  CartCouponTCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 2/22/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public struct CartCouponData {
  public var code: String
  public var content: String
}

public final class CartCouponTCell: UITableViewCell {
  @IBOutlet private weak var couponTitleLabel: UILabel! {
    didSet {
      couponTitleLabel.font = .openSans(style: .regular(size: 14.0))
      couponTitleLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var couponLabel: UILabel! {
    didSet {
      couponLabel.font = .openSans(style: .regular(size: 14.0))
      couponLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var valueLabel: UILabel! {
    didSet {
      valueLabel.font = .openSans(style: .regular(size: 14.0))
      valueLabel.textColor = .greyblue
    }
  }
  @IBOutlet private weak var removeButton: UIButton! {
    didSet {
      removeButton.setAttributedTitle(
        "Remove".attributed.add([.color(.coral), .font(.openSans(style: .semiBold(size: 14.0)))]),
        for: .normal)
    }
  }
  
  public var removeDidTapped: VoidCompletion?
  public var data: CartCouponData? {
    didSet {
      couponLabel.text = data?.code
      valueLabel.text = data?.content
    }
  }
  
  @IBAction private func removeTapped(_ sender: Any) {
    removeDidTapped?()
  }
}

// MARK: - CellProtocol
extension CartCouponTCell: CellProtocol {
}
