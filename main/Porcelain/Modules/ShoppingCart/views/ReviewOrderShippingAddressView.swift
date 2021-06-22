//
//  ReviewOrderShippingAddressView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 2/26/20.
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

public final class ReviewOrderShippingAddressView: DesignableView, ShippingAddressProtocol {
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
  @IBOutlet private weak var phoneLabel: UILabel! {
    didSet {
      phoneLabel.font = .openSans(style: .regular(size: 14.0))
      phoneLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var emailLabel: UILabel! {
    didSet {
      emailLabel.font = .openSans(style: .regular(size: 14.0))
      emailLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var addressLabel: UILabel!
  
  public var editDidTapped: VoidCompletion?
  
  public var shippingAddress: ShippingAddress? {
    didSet {
      nameLabel.text = name
      if let phoneNumber = try? PhoneNumberKit().parse(phone ?? "") {
        let nationalNumber = "\(phoneNumber.nationalNumber)"
        phoneLabel.text = "+\(phoneNumber.countryCode) " + " \(nationalNumber.formatNumber(interval: 4).value)".formatMobile()
      } else {
        phoneLabel.text = "Phone is invalid"
      }
      emailLabel.text = email
      addressLabel.attributedText = fullAddress?.attributed.add(.appearance(AttributedDescriptionAppearance()))
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
    loadNib(ReviewOrderShippingAddressView.self)
    addSubview(contentStack)
    contentStack.addSideConstraintsWithContainer()
  }
  
  @IBAction private func editTapped(_ sender: Any) {
    editDidTapped?()
  }
}
