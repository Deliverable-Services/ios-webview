//
//  CartProgressView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 2/22/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class CartProgressView: UIView {
  @IBOutlet private weak var progressLineView: UIView!
  @IBOutlet private weak var cartButton: DesignableButton! {
    didSet {
      cartButton.tag = 0
    }
  }
  @IBOutlet private weak var shippingAddressButton: DesignableButton! {
    didSet {
      shippingAddressButton.tag = 1
    }
  }
  @IBOutlet private weak var shippingMethodButton: DesignableButton! {
    didSet {
      shippingMethodButton.tag = 2
    }
  }
  @IBOutlet private weak var paymentMethodButton: DesignableButton! {
    didSet {
      paymentMethodButton.tag = 3
    }
  }
  @IBOutlet private weak var reviewOrderButton: DesignableButton! {
    didSet {
      reviewOrderButton.tag = 4
    }
  }
  
  private lazy var buttons: [DesignableButton] = [cartButton, shippingAddressButton, shippingMethodButton, paymentMethodButton, reviewOrderButton]
  
  public var didUpdateSection: VoidCompletion?
  
  public var section: ShopCartSection = .cart {
    didSet {
      switch section {
      case .cart:
        updateSelection(cartButton)
      case .shippingAddress:
        updateSelection(shippingAddressButton)
      case .shippingMethod:
        updateSelection(shippingMethodButton)
      case .paymentMethod:
        updateSelection(paymentMethodButton)
      case .reviewOrder:
        updateSelection(reviewOrderButton)
      }
    }
  }
  
  private func updateSelection(_ sender: DesignableButton) {
    buttons.forEach { (button) in
      if button.tag <= sender.tag {
        button.borderColor = .lightNavy
        button.backgroundColor = .lightNavy
      } else {
        button.borderColor = .bluishGrey
        button.backgroundColor = .white
      }
    }
  }
  
  @IBAction private func cartProgressTapped(_ sender: DesignableButton) {
//    guard let section = ShopCartSection(rawValue: sender.tag) else { return }
//    self.section = section
//    didUpdateSection?()
  }
}
