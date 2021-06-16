//
//  OrderReceivedAddressView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 3/24/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import PhoneNumberKit

private struct AttributedDescriptionAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? = 0.46
  var alignment: NSTextAlignment? = .left
  var lineBreakMode: NSLineBreakMode? = .byWordWrapping
  var minimumLineHeight: CGFloat? = 18.0
  var font: UIFont? = .openSans(style: .regular(size: 14.0))
  var color: UIColor? = .bluishGrey
}

public final class OrderReceivedAddressView: DesignableView {
  @IBOutlet private weak var view: UIView!
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .regular(size: 13.0))
      titleLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var nameLabel: UILabel! {
    didSet {
      nameLabel.font = .openSans(style: .semiBold(size: 14.0))
      nameLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var phoneLabel: UILabel! {
    didSet {
      phoneLabel.font = .openSans(style: .semiBold(size: 14.0))
      phoneLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var emailLabel: UILabel! {
    didSet {
      emailLabel.font = .openSans(style: .semiBold(size: 14.0))
      emailLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var addressLabel: UILabel!
  
  public var shippingAddress: ORShippingAddress? {
    didSet {
      nameLabel.text = shippingAddress?.name
      if let phoneNumber = try? PhoneNumberKit().parse(shippingAddress?.phone ?? "") {
        let nationalNumber = "\(phoneNumber.nationalNumber)"
        phoneLabel.text = "+\(phoneNumber.countryCode) " + " \(nationalNumber.formatNumber(interval: 4).value)".formatMobile()
      } else {
        phoneLabel.text = "Phone is invalid"
      }
      emailLabel.text = shippingAddress?.email
      addressLabel.attributedText = fullAddress?.attributed.add(.appearance(AttributedDescriptionAppearance()))
    }
  }
  
  private var fullAddress: String? {
    return [
      shippingAddress?.address,
      shippingAddress?.state,
      shippingAddress?.postalCode,
      shippingAddress?.country].compactMap({ $0 }).joined(separator: ", ").emptyToNil
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
    loadNib(OrderReceivedAddressView.self)
    addSubview(view)
    view.addSideConstraintsWithContainer()
  }
}
