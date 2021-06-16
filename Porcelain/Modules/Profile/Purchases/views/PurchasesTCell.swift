//
//  PurchaseCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 29/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

extension PurchaseStatus {
  fileprivate var color: UIColor {
    switch self {
    case .pendingPayment:
      return UIColor(hex: 0x3DB8DA)
    case .processing:
      return UIColor(hex: 0x3DB8DA)
    case .onHold:
      return UIColor(hex: 0xEB8741)
    case .completed:
      return UIColor(hex: 0x6BCC8E)
    case .cancelled:
      return UIColor(hex: 0xEF6E6E)
    case .refunded:
      return UIColor(hex: 0xEB8741)
    case .failed:
      return UIColor(hex: 0xEF6E6E)
    case .trash:
      return UIColor(hex: 0xEF6E6E)
    case .deleted:
      return UIColor(hex: 0xEF6E6E)
    }
  }
  
  fileprivate var font: UIFont {
    switch self {
    case .processing:
      return .openSans(style: .semiBoldItalic(size: 13.0))
    default:
      return .openSans(style: .semiBold(size: 13.0))
    }
  }
}

private struct AttributedTitleAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? = 0.5
  var alignment: NSTextAlignment? = nil
  var lineBreakMode: NSLineBreakMode? = nil
  var minimumLineHeight: CGFloat? = 20.0
  var font: UIFont? = .openSans(style: .semiBold(size: 13.0))
  var color: UIColor? = .gunmetal
}

private struct AttributedContentAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? = 0.5
  var alignment: NSTextAlignment? = nil
  var lineBreakMode: NSLineBreakMode? = nil
  var minimumLineHeight: CGFloat? = 20.0
  var font: UIFont? = .openSans(style: .regular(size: 13.0))
  var color: UIColor? = .bluishGrey
}

private struct AttributedButtonTitleAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? = 1.0
  var alignment: NSTextAlignment?
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat?
  var font: UIFont? = .idealSans(style: .book(size: 13.0))
  var color: UIColor? = .lightNavy
}

public final class PurchasesTCell: UITableViewCell {
  @IBOutlet private weak var shadowView: DesignableView!
  @IBOutlet private weak var containerView: DesignableView! {
    didSet {
      containerView.cornerRadius = 7.0
    }
  }
  @IBOutlet private weak var orderNoTitleLabel: UILabel! {
    didSet {
      orderNoTitleLabel.font = .openSans(style: .semiBold(size: 13.0))
      orderNoTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var orderNoLabel: UILabel! {
    didSet {
      orderNoLabel.font = .openSans(style: .semiBold(size: 13.0))
      orderNoLabel.textColor = .lightNavy
    }
  }
  @IBOutlet private weak var orderStatusLabel: UILabel!
  @IBOutlet private weak var sourceLabel: UILabel!
  @IBOutlet private weak var dateOfPurchaseLabel: UILabel!
  @IBOutlet private weak var totalLabel: UILabel!
  @IBOutlet private weak var orderAgainButton: UIButton! {
    didSet {
      var buttonTitleAppearance = AttributedButtonTitleAppearance()
      buttonTitleAppearance.color = .lightNavy
      orderAgainButton.setAttributedTitle("ORDER AGAIN".attributed.add(.appearance(buttonTitleAppearance)), for: .normal)
      orderAgainButton.backgroundColor = .white
    }
  }
  @IBOutlet private weak var leaveFeedbackButton: UIButton! {
    didSet {
      var buttonTitleAppearance = AttributedButtonTitleAppearance()
      buttonTitleAppearance.color = .white
      leaveFeedbackButton.setAttributedTitle("LEAVE A FEEDBACK".attributed.add(.appearance(buttonTitleAppearance)), for: .normal)
      leaveFeedbackButton.backgroundColor = .greyblue
    }
  }
  
  public var orderAgainDidTapped: ((Purchase) -> Void)?
  public var leaveFeedbackDidTapped: ((Purchase) -> Void)?
  
  public var purchase: Purchase? {
    didSet {
      orderNoLabel.text = "#\(purchase?.wcOrderNumber ?? purchase?.wcOrderID ?? "")"
      let titleApperance = AttributedTitleAppearance()
      var contentAppearance = AttributedContentAppearance()
      if let purchaseStatus = purchase?.purchaseStatus {
        contentAppearance.font = purchaseStatus.font
        contentAppearance.color = purchaseStatus.color
        orderStatusLabel.attributedText = "Order Status: ".attributed.add(.appearance(titleApperance)).append(
          attrs: purchaseStatus.title.attributed.add(.appearance(contentAppearance)))
        switch purchaseStatus {
        case .completed:
          leaveFeedbackButton.isHidden = false
        default:
          leaveFeedbackButton.isHidden = true
        }
      } else {
        if let status = purchase?.status {
          contentAppearance.color = .greenishTealTwo
          orderStatusLabel.attributedText = "Order Status: ".attributed.add(.appearance(titleApperance)).append(
            attrs: status.capitalizingFirstLetter().attributed.add(.appearance(contentAppearance)))
        } else {
          contentAppearance.color = .coral
          orderStatusLabel.attributedText = "Order Status: ".attributed.add(.appearance(titleApperance)).append(
            attrs: "N/A".attributed.add(.appearance(contentAppearance)))
        }
        leaveFeedbackButton.isHidden = true
      }
      contentAppearance.font = .openSans(style: .regular(size: 13.0))
      contentAppearance.color = .bluishGrey
      sourceLabel.attributedText = "Source: ".attributed.add(.appearance(titleApperance)).append(
        attrs: (purchase?.source ?? "-").attributed.add(.appearance(contentAppearance)))
      dateOfPurchaseLabel.attributedText = "Date of purchase: ".attributed.add(.appearance(titleApperance)).append(
        attrs: (purchase?.dateCreated?.toString(WithFormat: "dd MMM yyyy") ?? "N/A").attributed.add(.appearance(contentAppearance)))
      contentAppearance.font = .openSans(style: .semiBold(size: 13.0))
      contentAppearance.color = .gunmetal
      totalLabel.attributedText = "Total: ".attributed.add(.appearance(titleApperance)).append(
        attrs: String(format: "%@%.2f", AppConstant.currencySymbol, purchase?.totalAmount ?? 0.0).attributed.add(.appearance(contentAppearance)))
    }
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    shadowView.addShadow(appearance: .default)
  }
  
  @IBAction private func orderAgainTapped(_ sender: Any) {
    guard let purchase = purchase else { return }
    orderAgainDidTapped?(purchase)
  }
  
  @IBAction private func leaveFeedbackTapped(_ sender: Any) {
    guard let purchase = purchase else { return }
    leaveFeedbackDidTapped?(purchase)
  }
}

// MARK: - CellProtocol
extension PurchasesTCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 228.0)
  }
}
