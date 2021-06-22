//
//  OrderReceivedSummaryView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 3/4/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class OrderReceivedSummaryView: DesignableView {
  @IBOutlet private weak var view: UIView!
  @IBOutlet private weak var orderNumberTitleLabel: UILabel! {
    didSet {
      orderNumberTitleLabel.font = .openSans(style: .regular(size: 13.0))
      orderNumberTitleLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var orderNumberLabel: UILabel! {
    didSet {
      orderNumberLabel.font = .openSans(style: .semiBold(size: 14.0))
      orderNumberLabel.textColor = .lightNavy
    }
  }
  @IBOutlet private weak var dateTitleLabel: UILabel! {
    didSet {
      dateTitleLabel.font = .openSans(style: .regular(size: 13.0))
      dateTitleLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var dateLabel: UILabel! {
    didSet {
      dateLabel.font = .openSans(style: .semiBold(size: 14.0))
      dateLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var subtotalTitleLabel: UILabel! {
    didSet {
      subtotalTitleLabel.font = .openSans(style: .regular(size: 13.0))
      subtotalTitleLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var subtotalLabel: UILabel! {
    didSet {
      subtotalLabel.font = .openSans(style: .semiBold(size: 14.0))
      subtotalLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var discountStack: UIStackView!
  @IBOutlet private weak var discountTitleLabel: UILabel! {
    didSet {
      discountTitleLabel.font = .openSans(style: .regular(size: 13.0))
      discountTitleLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var discountLabel: UILabel! {
    didSet {
      discountLabel.font = .openSans(style: .semiBold(size: 14.0))
      discountLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var shippingTitleLabel: UILabel! {
    didSet {
      shippingTitleLabel.font = .openSans(style: .regular(size: 13.0))
      shippingTitleLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var shippingLabel: UILabel! {
    didSet {
      shippingLabel.font = .openSans(style: .semiBold(size: 14.0))
      shippingLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var paymentMethodStack: UIStackView!
  @IBOutlet private weak var paymentMethodTitleLabel: UILabel! {
    didSet {
      paymentMethodTitleLabel.font = .openSans(style: .regular(size: 13.0))
      paymentMethodTitleLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var paymentMethodLabel: UILabel! {
    didSet {
      paymentMethodLabel.font = .openSans(style: .semiBold(size: 14.0))
      paymentMethodLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var totalTitleLabel: UILabel! {
    didSet {
      totalTitleLabel.font = .openSans(style: .regular(size: 13.0))
      totalTitleLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var totalLabel: UILabel! {
    didSet {
      totalLabel.font = .openSans(style: .semiBold(size: 14.0))
      totalLabel.textColor = .lightNavy
    }
  }
  
  public var orderReceivedData: OrderReceivedData? {
    didSet {
      orderNumberLabel.text = orderReceivedData?.orderNumber ?? orderReceivedData?.orderID ?? "-"
      dateLabel.text = orderReceivedData?.orderDate?.toString(WithFormat: "MMMM dd, yyyy") ?? "-"
      subtotalLabel.text = String(format: "%@%.2f", AppConstant.currencySymbol, orderReceivedData?.orderSubtotal ?? 0.0)
      if let discount = orderReceivedData?.orderDiscount, discount > 0.0 {
        discountStack.isHidden = false
        discountLabel.text = String(format: "-%@%.2f", AppConstant.currencySymbol, discount)
      } else {
        discountStack.isHidden = true
      }
      let attributedShipping = NSMutableAttributedString()
      let shippingFeeString: String
      if let orderShippingFee = orderReceivedData?.orderShippingFee, orderShippingFee > 0 {
        shippingFeeString = String(format: "%@%.2f", AppConstant.currencySymbol, orderShippingFee)
        attributedShipping.append(shippingFeeString.attributed.add([
          .color(.gunmetal),
          .font(.openSans(style: .semiBold(size: 14.0)))]))
        if let orderShipping = orderReceivedData?.orderShipping {
           attributedShipping.append(" via \(orderShipping.title)".attributed.add([
             .color(.gunmetal),
             .font(.openSans(style: .regular(size: 14.0)))]))
         }
      } else {
        shippingFeeString = "Free"
        attributedShipping.append(shippingFeeString.attributed.add([
          .color(.gunmetal),
          .font(.openSans(style: .semiBold(size: 14.0)))]))
      }
      shippingLabel.attributedText = attributedShipping
      paymentMethodLabel.text = orderReceivedData?.subPayment ?? orderReceivedData?.orderPaymentMethod?.title ?? "-"
      totalLabel.text = orderReceivedData?.orderTotal ?? "-"
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
    loadNib(OrderReceivedSummaryView.self)
    addSubview(view)
    view.addSideConstraintsWithContainer()
  }
}
