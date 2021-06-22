//
//  PackageCell.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 04/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import UIKit
import LUExpandableTableView

class PackageCellHeader: LUExpandableTableViewSectionHeader {
  static var identifier: String = String(describing: PackageCellHeader.self)
  
  @IBOutlet private var containerView: UIView!
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
  
  func roundTop() {
    containerView.layer.cornerRadius = 7.0
    containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    setNeedsLayout()
  }
  
  func roundBottom() {
    containerView.layer.cornerRadius = 7.0
    containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    setNeedsLayout()
  }
  
  func removeRound() {
    containerView.layer.cornerRadius = 0
    setNeedsLayout()
  }
  
  func configure(_ title: String, _ desc: String, toggable: Bool = true) {
    self.toggable = toggable
    titleLbl.attributedText = title
      .withFont(UIFont.Porcelain.idealSans(16))
      .withTextColor(UIColor.Porcelain.greyishBrown)
      .withKern(0.5)
    
    descLbl.attributedText = desc
      .withFont(UIFont.Porcelain.idealSans(16))
      .withTextColor(UIColor.Porcelain.greyishBrown)
      .withKern(0.5)
    
    titleLbl.numberOfLines = 0
    descLbl.numberOfLines = 1
    
    isUserInteractionEnabled = toggable
    arrow.isHidden = !toggable
    descLbl.isHighlighted = toggable
  }
}

class PackageCell: UITableViewCell {
  static var identifier: String = String(describing: PackageCell.self)
  static var estimatedCellHeight: CGFloat = 70.0
  
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var treatmentLabel: UILabel!
  @IBOutlet weak var sessionsLeftLabel: UILabel!
  @IBOutlet weak var arrowImageView: UIImageView!
  @IBOutlet weak var topSpace: NSLayoutConstraint!
  @IBOutlet weak var bottomSpace: NSLayoutConstraint!
  @IBOutlet weak var leadingSpace: NSLayoutConstraint!
  @IBOutlet private var expirationLabel: UILabel!
  
  func roundBottom() {
    containerView.layer.cornerRadius = 7.0
    containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    setNeedsLayout()
  }
  
  func removeRound() {
    containerView.layer.cornerRadius = 0
    setNeedsLayout()
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  func configure(treatmentName: String, sessions: Int, expiration: String?, isSubgroup: Bool) {
    if isSubgroup {
      self.configureSubgroup(treatmentName: treatmentName, sessions: sessions, expiration: expiration)
    } else {
      self.arrowImageView.isHidden = true
      self.sessionsLeftLabel.isHidden = false
      self.treatmentLabel.attributedText = treatmentName
        .withFont(UIFont.Porcelain.idealSans(16))
        .withTextColor(UIColor.Porcelain.greyishBrown)
        .withKern(0.5)
      self.sessionsLeftLabel.attributedText = "x \(sessions)"
        .withFont(UIFont.Porcelain.idealSans(16))
        .withTextColor(UIColor.Porcelain.greyishBrown)
        .withKern(0.5)
      if let dateString = expiration?.toDate(format: "yyyy-MM-dd'T'HH:mm:ss")?.toString(WithFormat: "MM/dd/yy") {
        expirationLabel.isHidden = false
        expirationLabel.attributedText = concatenate("Expiry date: ", dateString)
          .withFont(UIFont.Porcelain.openSans(13.0, weight: .regular))
          .withTextColor(UIColor.Porcelain.warmGrey)
          .withKern(0.46)
      } else {
        expirationLabel.isHidden = true
      }
      self.containerView.backgroundColor = UIColor.Porcelain.greySeparator
      self.leadingSpace.constant = 15
    }
  }
  
  private func configureSubgroup(treatmentName: String, sessions: Int, expiration: String?) {
    self.arrowImageView.isHidden = true
    self.sessionsLeftLabel.isHidden = false
    self.treatmentLabel.attributedText = treatmentName
      .withFont(UIFont.Porcelain.idealSans(16))
      .withTextColor(UIColor.Porcelain.greyishBrown)
      .withKern(0.5)
    self.sessionsLeftLabel.attributedText = "x \(sessions)"
      .withFont(UIFont.Porcelain.idealSans(16))
      .withTextColor(UIColor.Porcelain.greyishBrown)
      .withKern(0.5)
    if let dateString = expiration?.toDate(format: "yyyy-MM-dd'T'HH:mm:ss")?.toString(WithFormat: "MM/dd/yy") {
      expirationLabel.isHidden = false
      expirationLabel.attributedText = concatenate("Expiry date: ", dateString)
        .withFont(UIFont.Porcelain.openSans(13.0, weight: .regular))
        .withTextColor(UIColor.Porcelain.warmGrey)
        .withKern(0.46)
    } else {
      expirationLabel.isHidden = false
      expirationLabel.attributedText = concatenate("Expiry date: None")
        .withFont(UIFont.Porcelain.openSans(13.0, weight: .regular))
        .withTextColor(UIColor.Porcelain.warmGrey)
        .withKern(0.46)
    }
    self.containerView.backgroundColor = UIColor.white
    self.leadingSpace.constant = 32
  }
}
