//
//  BookAppointmentCell.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 03/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import UIKit

class BookAppointmentCell: UITableViewCell {
  static var identifier: String = String(describing: BookAppointmentCell.self)
  static var estimatedCellHeight: CGFloat = 48
  
//  @IBOutlet private weak var containerView: DesignableView!
  @IBOutlet private weak var button: DesignableButton!
  private var didTapBook: (() -> ())?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    style()
  }
  
  @IBAction private func didTapBookAppointment() {
    didTapBook?()
  }
  
  func configure(didTapButtonBlock: (() -> ())?) {
    didTapBook = didTapButtonBlock
  }
  
  // MARK: - Private methods
  private func style() {
    button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8.0)
    button.setAttributedTitle("BOOK AN APPOINTMENT".localized()
      .withFont(UIFont.Porcelain.idealSans(14))
      .withTextColor(UIColor.Porcelain.metallicBlue)
      .withKern(0.5), for: .normal)
  }
}
