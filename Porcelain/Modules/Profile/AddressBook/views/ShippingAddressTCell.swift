//
//  ShippingAddressTCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 23/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import PhoneNumberKit

private struct AddressAttributedAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? = 0.46
  var alignment: NSTextAlignment? = .left
  var lineBreakMode: NSLineBreakMode? = .byWordWrapping
  var minimumLineHeight: CGFloat? = 18.0
  var font: UIFont? = .openSans(style: .regular(size: 13.0))
  var color: UIColor? = .bluishGrey
}

public final class ShippingAddressTCell: UITableViewCell, ShippingAddressProtocol {
  @IBOutlet private weak var containerView: DesignableView! {
    didSet {
      containerView.cornerRadius = 7.0
      containerView.borderColor = .whiteThree
      containerView.borderWidth = 1.0
    }
  }
  @IBOutlet private weak var defaultButton: UIButton!
  @IBOutlet private weak var editButton: UIButton! {
    didSet {
      editButton.setImage(
        UIImage.icPencil.maskWithColor(.lightNavy),
        for: .normal)
    }
  }
  @IBOutlet private weak var deleteButton: UIButton! {
    didSet {
      deleteButton.setImage(
        UIImage.icDelete.maskWithColor(.lightNavy),
        for: .normal)
    }
  }
  @IBOutlet private weak var separatorView: UIView! {
    didSet {
      separatorView.backgroundColor = .whiteThree
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
  
  private var isPrimary: Bool = false {
    didSet {
      if isPrimary {
        defaultButton.setAttributedTitle(
          UIImage.icCircleCheckSelected.attributed.add(.baseline(offset: -4.0)).append(
            attrs: "  Default shipping address".attributed.add([.color(.gunmetal), .font(.openSans(style: .regular(size: 14.0)))])),
          for: .normal)
      } else {
        defaultButton.setAttributedTitle(
          UIImage.icCircleCheckUnselected.attributed.add(.baseline(offset: -4.0)).append(
            attrs: "  Default shipping address".attributed.add([.color(.bluishGrey), .font(.openSans(style: .regular(size: 14.0)))])),
          for: .normal)
      }
    }
  }
  
  public var defaultDidTapped: ((ShippingAddress) -> Void)?
  public var editDidTapped: ((ShippingAddress) -> Void)?
  public var deleteDidTapped: ((ShippingAddress) -> Void)?
  
  public var allowsDelete: Bool = true
  public var allowsSelection: Bool = true
  
  public var shippingAddress: ShippingAddress? {
    didSet {
      isPrimary = isDefault
      nameLabel.text = name
      if let phoneNumber = try? PhoneNumberKit().parse(shippingAddress?.phone ?? "") {
        let nationalNumber = "\(phoneNumber.nationalNumber)"
        phoneLabel.text = "+\(phoneNumber.countryCode) " + " \(nationalNumber.formatNumber(interval: 4).value)".formatMobile()
      } else {
        phoneLabel.text = "Phone is invalid"
      }
      emailLabel.text = email
      addressLabel.attributedText = fullAddress?.attributed.add(.appearance(AddressAttributedAppearance()))
      deleteButton.isHidden = !allowsDelete
      updateSelection(isSelected)
    }
  }
  
  public override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    updateSelection(selected)
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    updateSelection(isSelected)
  }
  
  private func updateSelection(_ isSelected: Bool) {
    if allowsSelection {
      if isSelected {
        containerView.borderColor = .greyblue
        containerView.addShadow(appearance: .default)
      } else {
        containerView.borderColor = .whiteThree
        containerView.removeShadow()
      }
    } else {
      if isPrimary {
        containerView.borderColor = .greyblue
        containerView.addShadow(appearance: .default)
      } else {
        containerView.borderColor = .whiteThree
        containerView.removeShadow()
      }
    }
  }
  
  @IBAction private func defaultTapped(_ sender: Any) {
    guard let shippingAddress = shippingAddress else { return }
    defaultDidTapped?(shippingAddress)
  }
  
  @IBAction private func editTapped(_ sender: Any) {
    guard let shippingAddress = shippingAddress else { return }
    editDidTapped?(shippingAddress)
  }
  
  @IBAction private func deleteTapped(_ sender: Any) {
    guard let shippingAddress = shippingAddress else { return }
    deleteDidTapped?(shippingAddress)
  }
}

// MARK: - CellProtocol
extension ShippingAddressTCell: CellProtocol {
}
