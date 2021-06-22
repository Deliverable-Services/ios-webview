//
//  BookAppointmentHeaderView.swift
//  Porcelain
//
//  Created by Jean on 6/29/18.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit

class BookAppointmentHeaderView: UIView {
  static var identifier = String(describing: BookAppointmentHeaderView.self)
  @IBOutlet private var bookBtn: UIButton!
  
  private var didTapBookBlock: (() -> ())?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    bookBtn.addTarget(self, action: #selector(didTapButton),
                      for: .touchUpInside)
    style()
  }
  
  private func style() {
    bookBtn.setAttributedTitle(
      "BOOK AN APPOINTMENT".localized()
        .withFont(UIFont.Porcelain.idealSans(14))
        .withTextColor(UIColor.Porcelain.metallicBlue)
        .withKern(0.5), for: .normal)
    bookBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8.0)
  }
  
  func configure(_ didTapBlock: (() -> ())?) {
    didTapBookBlock = didTapBlock
  }
  
  @objc func didTapButton() {
    didTapBookBlock?()
  }
}
