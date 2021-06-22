//
//  ProfileMainCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 16/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct ProfileNameAttributedAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? {
    return 1.0
  }
  var alignment: NSTextAlignment?
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat?
  var font: UIFont? {
    return .openSans(style: .semiBold(size: 20.0))
  }
  var color: UIColor? {
    return .lightNavy
  }
}

private struct BalanceAttributedAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? {
    return 0.5
  }
  var alignment: NSTextAlignment?
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat?
  var font: UIFont? {
    return .openSans(style: .regular(size: 30.0))
  }
  var color: UIColor? {
    return .gunmetal
  }
}

public final class ProfileMainCell: UITableViewCell, UserProtocol {
  @IBOutlet private weak var profileImageContainerView: DesignableView!
  @IBOutlet private weak var profileImageView: LoadingImageView! {
    didSet {
      profileImageView.contentMode = .scaleAspectFill
      profileImageView.placeholderImage = .imgProfilePlaceholder
    }
  }
  @IBOutlet private weak var nameLabel: UILabel! {
    didSet {
      nameLabel.font = .openSans(style: .semiBold(size: 20.0))
      nameLabel.textColor = .lightNavy
    }
  }
  @IBOutlet private weak var emailLabel: UILabel! {
    didSet {
      emailLabel.font = .openSans(style: .regular(size: 13.0))
      emailLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var phoneLabel: UILabel! {
    didSet {
      phoneLabel.font = .openSans(style: .regular(size: 13.0))
      phoneLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var branchLabel: UILabel! {
    didSet {
      branchLabel.font = .openSans(style: .regular(size: 13.0))
      branchLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var customerIDLabel: UILabel! {
    didSet {
      customerIDLabel.font = .openSans(style: .regular(size: 13.0))
      customerIDLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var editProfileButton: DesignableButton! {
    didSet {
      editProfileButton.cornerRadius = 18.0
      editProfileButton.borderColor = .lightNavy
      editProfileButton.borderWidth = 1.0
      editProfileButton.setAttributedTitle(
        "Edit Profile".attributed.add([
          .color(.lightNavy),
          .font(.idealSans(style: .book(size: 14.0)))]),
        for: .normal)
    }
  }
  @IBOutlet private weak var accountBalanceTitleLabel: UILabel! {
    didSet {
      accountBalanceTitleLabel.font = .openSans(style: .semiBold(size: 13.0))
      accountBalanceTitleLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var accountBalanceLabel: UILabel! {
    didSet {
      accountBalanceLabel.font = .openSans(style: .regular(size: 30.0))
      accountBalanceLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var separatorView: UIView! {
    didSet {
      separatorView.backgroundColor = .whiteThree
    }
  }
  @IBOutlet private weak var outstandingBalanceTitleLabel: UILabel! {
    didSet {
      outstandingBalanceTitleLabel.font = .openSans(style: .semiBold(size: 13.0))
      outstandingBalanceTitleLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var outstandingBalanceLabel: UILabel!
  
  public var editDidTapped: VoidCompletion?
  
  public var user: Customer? {
    didSet {
      profileImageView.url = avatar
      nameLabel.attributedText = fullname?.attributed
        .add(.appearance(ProfileNameAttributedAppearance()))
      emailLabel.text = email
      var phones: [String] = []
      if let phoneCode = phoneCode {
        phones.append("+\(phoneCode)")
      }
      if let phone = phone {
        phones.append(phone.formatMobile())
      }
      phoneLabel.text = phones.joined(separator: " ").emptyToNil
      branchLabel.text = [personalAddress?.address, personalAddress?.postalCode].compactMap({ $0 }).joined().emptyToNil
      customerIDLabel.text = "Customer ID: \(identificationNumber ?? "-")"
      accountBalanceLabel.attributedText = "\(AppConstant.currencySymbol)\(String(format: "%.2f", accountBalance))".attributed
        .add(.appearance(BalanceAttributedAppearance()))
      if let outstandingBalance = outstandingBalance {
        outstandingBalanceLabel.attributedText = "\(AppConstant.currencySymbol)\(String(format: "%.2f", outstandingBalance))".attributed
          .add(.appearance(BalanceAttributedAppearance()))
      } else {
        outstandingBalanceLabel.attributedText = "None".attributed.add([.color(.bluishGrey), .font(.openSans(style: .regular(size: 16.0)))])
      }
    }
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    profileImageContainerView.cornerRadius = profileImageContainerView.bounds.width/2
  }
  
  @IBAction private func editTapped(_ sender: Any) {
    editDidTapped?()
  }
}

// MARK: - CellProtocol
extension ProfileMainCell: CellProtocol {
  public static var defaultSize: CGSize {
    fatalError("ProfileMainCell defaultSize not set")
  }
}
