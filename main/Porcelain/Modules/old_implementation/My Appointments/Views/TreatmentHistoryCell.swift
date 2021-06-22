//
//  TreatmentHistoryCell.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 04/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import UIKit
import SwiftyAttributes

protocol TreatmentHistoryCellDelegate: class {
  func rebook(with treatmentID: String, therapistID: String?, locationID: String)
}

class TreatmentHistoryCell: UITableViewCell {
  static var identifier: String = String(describing: TreatmentHistoryCell.self)
  static var estimatedCellHeight: CGFloat = 129
  static var dateFormat = "MMM dd, yyyy '|' EEEE"
  static var timeFormat = "h:mmaa"

  private var treatment: TreatmentHistory?
  
  @IBOutlet weak var containerView: UIView!
  
  @IBOutlet weak var dateLbl: UILabel!
  @IBOutlet weak var nameLbl: UILabel!
  @IBOutlet weak var addOnsLbl: UILabel!
  @IBOutlet weak var timeLbl: UILabel!
  @IBOutlet weak var therapistLbl: UILabel!
  @IBOutlet weak var productsLbl: UILabel!
  @IBOutlet weak var locationLbl: UILabel!
  @IBOutlet weak var rebookBtn: UIButton!

  weak var delegate: TreatmentHistoryCellDelegate?

  @IBAction func rebook() {
    guard let tID = treatment?.treatmentID,
          let lID = treatment?.locationID else { return }
    delegate?.rebook(with: tID, therapistID: treatment?.therapistID, locationID: lID)
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    style()
  }
  
  func configure(treatment: TreatmentHistory) {
    self.treatment = treatment
    dateLbl.attributedText = (treatment.startDate! as Date).toString(WithFormat: TreatmentHistoryCell.dateFormat)
      .withFont(UIFont.Porcelain.openSans(13, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.greyishBrown)
      .withKern(0.5)
    nameLbl.attributedText = (treatment.name ?? "")
      .withFont(UIFont.Porcelain.openSans(16, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.metallicBlue)
      .withKern(0.5)
    timeLbl.attributedText = "\((treatment.startDate! as Date).toString(WithFormat: TreatmentHistoryCell.timeFormat)) - \((treatment.endDate! as Date).toString(WithFormat: TreatmentHistoryCell.timeFormat))"
      .withFont(UIFont.Porcelain.openSans(14, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.warmGrey)
      .withKern(0.5)
    therapistLbl.attributedText =
      "Therapist: "
      .withFont(UIFont.Porcelain.openSans(13, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.greyishBrown)
      .withKern(0.5)
      + (treatment.therapist == "" ? "No preference" : treatment.therapist!)
      .withFont(UIFont.Porcelain.openSans(13))
      .withTextColor(UIColor.Porcelain.warmGrey)
      .withKern(0.5)
//    productsLbl.attributedText =
//      "Products Used: "
//        .withFont(UIFont.Porcelain.openSans(13, weight: .semiBold))
//        .withTextColor(UIColor.Porcelain.greyishBrown)
//        .withKern(0.5)
//      + getProducts(products: treatment.productsUsed)
//        .withFont(UIFont.Porcelain.openSans(13))
//        .withTextColor(UIColor.Porcelain.warmGrey)
//        .withKern(0.5)
    productsLbl.isHidden = true
    locationLbl.attributedText =
      "Location: "
        .withFont(UIFont.Porcelain.openSans(13, weight: .semiBold))
        .withTextColor(UIColor.Porcelain.greyishBrown)
        .withKern(0.5)
      + (treatment.location ?? "")
        .withFont(UIFont.Porcelain.openSans(13))
        .withTextColor(UIColor.Porcelain.warmGrey)
        .withKern(0.5)
    addOnsLbl.attributedText =
      "Add-ons: "
        .withFont(UIFont.Porcelain.openSans(13, weight: .semiBold))
        .withTextColor(UIColor.Porcelain.greyishBrown)
        .withKern(0.5)
    + getAddOns(treatment: treatment)
      .withFont(UIFont.Porcelain.openSans(13))
      .withTextColor(UIColor.Porcelain.warmGrey)
      .withKern(0.5)
  }

  private func getAddOns(treatment: TreatmentHistory) -> String {
    if treatment.addOns.count == 0 { return "None".localized() }
    return treatment.addOns.joined(separator: ", ")
  }

  private func getProducts(products: [String]?) -> String {
    guard let prod = products,
          prod.count > 0 else { return "None".localized() }
    return prod.joined(separator: ", ")
  }

  private func style() {
    backgroundColor = UIColor.Porcelain.white
    containerView.layer.cornerRadius = 7.0
    containerView.layer.borderColor = UIColor.Porcelain.whiteFour.cgColor
    containerView.layer.borderWidth = 1.0
    containerView.backgroundColor = UIColor.white

    rebookBtn.setAttributedTitle(
      "REBOOK".localized()
        .withFont(UIFont.Porcelain.openSans(14, weight: .semiBold))
        .withTextColor(UIColor.Porcelain.metallicBlue)
        .withKern(1), for: .normal)
  }
}
