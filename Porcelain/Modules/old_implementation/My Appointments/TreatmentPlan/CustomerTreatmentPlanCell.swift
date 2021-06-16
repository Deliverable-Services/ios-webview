//
//  CustomerTreatmentPlanCell.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 19/01/2019.
//  Copyright © 2019 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit

class CustomerTreatmentPlanCell: UITableViewCell {
  @IBOutlet weak var treatmenNameLabel: UILabel!
  @IBOutlet weak var afterNumberOfDaysLabel: UILabel!
  @IBOutlet weak var sessionsLeftLabel: UILabel!
  @IBOutlet private weak var bookNowContainerView: UIView!
  @IBOutlet private weak var bookNowButton: DesignableButton!
  
  static var cornerRadius: CGFloat = 7.0
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var topSeparator: UIView!
  @IBOutlet weak var bottomSeparator: UIView!
  
  @IBOutlet weak var topSpace: NSLayoutConstraint!
  @IBOutlet weak var bottomSpace: NSLayoutConstraint!
  
  var bookNowDidTapped: StringCompletion?
  
  var roundCorners: CACornerMask = []
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    bookNowButton.setAttributedTitle(NSAttributedString(
      content: "Book Now",
      font: UIFont.Porcelain.openSans(14.0, weight: .semiBold),
      foregroundColor: UIColor.Porcelain.metallicBlue,
      paragraphStyle: .makeCustomStyle(
        lineHeight: 14.0,
        characterSpacing: 0.5)), for: .normal)
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    containerView.layer.shadowColor = UIColor.Porcelain.warmGrey.cgColor
    containerView.layer.shadowOffset = .zero
    containerView.layer.shadowRadius = 7.0
    containerView.layer.shadowOpacity = 0.3
    
    containerView.layer.cornerRadius = 7.0
    containerView.layer.maskedCorners = roundCorners
  }
  
  var addTopPadding: Bool? {
    didSet {
      self.topSpace.constant = (addTopPadding ?? false) ? 15: 0
      self.topSeparator.isHidden = (addTopPadding ?? false)
    }
  }
  
  var addBottomPadding: Bool? {
    didSet {
      self.bottomSpace.constant = (addBottomPadding ?? false) ? 15: 0
      self.bottomSeparator.isHidden = (addBottomPadding ?? false)
    }
  }
  
  private var model: CustomerTreatmentPlanModel?
  
  public func configure(_ model: CustomerTreatmentPlanModel) {
    self.model = model
    containerView.backgroundColor = model.backgroundColor
    treatmenNameLabel.attributedText = model.treatmentName
    afterNumberOfDaysLabel.attributedText = model.afterNumberOfDays
    sessionsLeftLabel.attributedText = model.sessionsLeft
    bookNowContainerView.isHidden = !model.showBookNow
  }
  
  @IBAction private func bookNowTapped(_ sender: Any) {
    guard let treatmentID = model?.treatmentID else { return }
    bookNowDidTapped?(treatmentID)
  }
}

/************************************************************************/

struct CustomerTreatmentPlanModel {
  var customerTreatmentPlan: CustomerTreatmentPlan
  
  var backgroundColor: UIColor {
    return UIColor.white
  }
  
  var treatmentName: NSAttributedString {
    let attributedTitle = NSMutableAttributedString(string: "")
    
    attributedTitle.append((customerTreatmentPlan.treatmentName ?? "")
      .withFont(UIFont.Porcelain.idealSans(14.0))
      .withTextColor(UIColor.Porcelain.metallicBlue)
      .withKern(0.5))
    return attributedTitle
  }
  
  var afterNumberOfDays: NSAttributedString {
    let attributedTitle = NSMutableAttributedString(string: "")
    
    attributedTitle.append("After no. of days: \(customerTreatmentPlan.afterNumberOfDays)"
      .withFont(UIFont.Porcelain.openSans(14.0, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.warmGrey)
      .withKern(0.5))
    return attributedTitle
  }
  
  var sessionsLeft: NSAttributedString {
    let attributedTitle = NSMutableAttributedString(string: "")
    
    attributedTitle.append("Sessions left: \(customerTreatmentPlan.sessionsLeft ?? 0)"
      .withFont(UIFont.Porcelain.openSans(14.0, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.warmGrey)
      .withKern(0.5))
    return attributedTitle
  }
  
  var treatmentID: String? {
    return customerTreatmentPlan.treatmentID
  }
  
  var showBookNow: Bool {
    return customerTreatmentPlan.showBookNow
  }
}
