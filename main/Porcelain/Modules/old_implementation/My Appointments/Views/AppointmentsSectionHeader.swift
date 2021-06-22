//
//  AppointmentsSectionHeader.swift
//  Porcelain
//
//  Created by Jean on 6/29/18.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import LUExpandableTableView

class AppointmentsSectionHeader: LUExpandableTableViewSectionHeader {
  static var identifier: String = String(describing: AppointmentsSectionHeader.self)
  
  @IBOutlet private var titleLbl: UILabel!
  @IBOutlet private var descLbl: UILabel!
  @IBOutlet private var arrow: UIImageView!
  
  private var toggable: Bool = true
  
  override var isExpanded: Bool {
    didSet {
      arrow.image = !isExpanded ? #imageLiteral(resourceName: "arrowDown") : #imageLiteral(resourceName: "arrow_up")
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleSection)))
  }
  
  @objc func toggleSection() {
    delegate?.expandableSectionHeader(self, shouldExpandOrCollapseAtSection: section)
    delegate?.expandableSectionHeader(self, wasSelectedAtSection: section)
  }
  
  func configure(_ title: String, _ desc: String, toggable: Bool = true) {
    self.toggable = toggable
    titleLbl.attributedText = title
      .withFont(UIFont.Porcelain.idealSans(16))
      .withTextColor(UIColor.Porcelain.greyishBrown)
      .withKern(0.5)
    
    descLbl.attributedText = desc
      .withFont(UIFont.Porcelain.openSans(13))
      .withTextColor(UIColor.Porcelain.warmGrey)
      .withKern(0.5)
    
    titleLbl.numberOfLines = 1
    descLbl.numberOfLines = 0
    
    isUserInteractionEnabled = toggable
    arrow.isHidden = !toggable
  }
}
