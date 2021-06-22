//
//  PackageEmptyCell.swift
//  Porcelain
//
//  Created by Jean on 7/7/18.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import LUExpandableTableView

class PackageEmptyCell: LUExpandableTableViewSectionHeader {
  static var identifier: String = String(describing: PackageEmptyCell.self)
  static var estimatedCellHeight: CGFloat = 76
  
  @IBOutlet private weak var containerView: UIView!
  @IBOutlet private weak var titleLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    style()
  }
  
  func configure(text: String) {
    self.titleLabel.attributedText = text
      .withTextColor(UIColor.Porcelain.warmGrey)
      .withFont(UIFont.Porcelain.openSans(14))
      .withKern(0.5)
  }
  
  private func style() {
    isUserInteractionEnabled = false
    containerView.layer.borderColor = UIColor.Porcelain.whiteFour.cgColor
    containerView.layer.borderWidth = 1.0
    containerView.layer.cornerRadius = 7.0
  }
}
