//
//  CreditCardTCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 08/08/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import Stripe

public final class CreditCardTCell: UITableViewCell, CardProtocol {
  @IBOutlet private weak var containerView: DesignableView!
  @IBOutlet private weak var selectionButton: UIButton!
  @IBOutlet private weak var deleteButton: UIButton! {
    didSet {
      deleteButton.setImage(.icDelete, for: .normal)
    }
  }
  @IBOutlet private weak var cCardImageView: UIImageView!
  @IBOutlet private weak var cCardNumberLabel: UILabel! {
    didSet {
      cCardNumberLabel.font = .openSans(style: .semiBold(size: 14.0))
      cCardNumberLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var cCardExpirationLabel: UILabel! {
    didSet {
      cCardExpirationLabel.font = .openSans(style: .regular(size: 13.0))
      cCardExpirationLabel.textColor = .bluishGrey
    }
  }
  
  public var isPrimary: Bool = false {
    didSet {
      if isPrimary {
        selectionButton.setAttributedTitle(
          UIImage.icCircleCheckSelected.attributed.add(.baseline(offset: -4.0)).append(
            attrs: "  Set as Primary".attributed.add([.color(.gunmetal), .font(.openSans(style: .regular(size: 14.0)))])),
          for: .normal)
      } else {
        selectionButton.setAttributedTitle(
          UIImage.icRadioUnselected.attributed.add(.baseline(offset: -4.0)).append(
            attrs: "  Set as Primary".attributed.add([.color(.bluishGrey), .font(.openSans(style: .regular(size: 14.0)))])),
          for: .normal)
      }
    }
  }
  
  public var setPrimaryDidTapped: ((Card) -> Void)?
  public var deleteDidTapped: ((Card) -> Void)?
  
  public var allowsDelete: Bool = true
  public var allowsSelection: Bool = true
  
  public var card: Card? {
    didSet {
      isPrimary = isDefault
      cCardImageView.image = image
      cCardNumberLabel.text = "**** **** **** \(last4 ?? "")"
      cCardExpirationLabel.text = "EXP.\n\(expMonth)/\(expYear)"
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
  
  @IBAction private func setPrimaryTapped(_ sender: Any) {
    guard let card = card, !isDefault else { return }
    setPrimaryDidTapped?(card)
  }
  
  @IBAction private func deleteTapped(_ sender: Any) {
    guard let card = card else { return }
    deleteDidTapped?(card)
  }
}

// MARK: - CellProtocol
extension CreditCardTCell: CellProtocol {
}

extension CardProtocol {
  public var image: UIImage {
    switch brand {
    case .visa:
      return STPImageLibrary.visaCardImage()
    case .masterCard:
      return STPImageLibrary.masterCardCardImage()
    case .amex:
      return STPImageLibrary.amexCardImage()
    case .dinersClub:
      return STPImageLibrary.dinersClubCardImage()
    case .discover:
      return STPImageLibrary.discoverCardImage()
    case .jcb:
      return STPImageLibrary.jcbCardImage()
    case .unionPay:
      return STPImageLibrary.unionPayCardImage()
    case .unknown:
      return STPImageLibrary.unknownCardCardImage()
    }
  }
}
