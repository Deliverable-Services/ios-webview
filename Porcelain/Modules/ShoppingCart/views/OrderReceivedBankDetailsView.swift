//
//  OrderReceivedBankDetailsView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 3/4/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import Toast_Swift

public final class OrderReceivedBankDetailsView: DesignableView {
  @IBOutlet private weak var view: UIView!
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .semiBold(size: 14.0))
      titleLabel.textColor = .lightNavy
    }
  }
  @IBOutlet private weak var bankTitleLabel: UILabel! {
    didSet {
      bankTitleLabel.font = .openSans(style: .regular(size: 13.0))
      bankTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var bankLabel: UILabel! {
    didSet {
      bankLabel.font = .openSans(style: .semiBold(size: 14.0))
      bankLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var accountNumberTitleLabel: UILabel! {
    didSet {
      accountNumberTitleLabel.font = .openSans(style: .regular(size: 13.0))
      accountNumberTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var accountNumberLabel: UILabel! {
    didSet {
      accountNumberLabel.font = .openSans(style: .semiBold(size: 14.0))
      accountNumberLabel.textColor = .gunmetal
    }
  }
  
  public var bankDetails: ORBankDetails? {
    didSet {
      titleLabel.text = bankDetails?.accountName
      bankLabel.text = bankDetails?.name
      accountNumberLabel.text = bankDetails?.accountNumber
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
  
  @IBAction private func copyTapped(_ sender: Any) {
    if let accountNumber = bankDetails?.accountNumber {
      let pasteboard = UIPasteboard.general
      pasteboard.string = accountNumber
      UIApplication.shared.topViewController()?.view.makeToast("Copied.", duration: 3.0, position: .bottom)
    } else {
      UIApplication.shared.topViewController()?.view.makeToast("Cannot be copied.", duration: 3.0, position: .center)
    }
  }
  
  private func commonInit() {
    loadNib(OrderReceivedBankDetailsView.self)
    addSubview(view)
    view.addSideConstraintsWithContainer()
  }
}
