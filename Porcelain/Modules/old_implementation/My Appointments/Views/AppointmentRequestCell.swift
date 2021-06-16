//
//  AppointmentRequestCell.swift
//  Porcelain
//
//  Created by Jean on 6/28/18.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit

struct AppointmentRequest {
  var id: String
  var name: String
  var sessionsLeft: Int
  var nextSessionDate: Date
}

class AppointmentRequestCell: UITableViewCell {
  static var identifier: String = String(describing: AppointmentRequestCell.self)
  static var cornerRadius: CGFloat = 7.0
  static var dateFormat: String = "EEEE, MMM dd"
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var addOnsLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!

  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var topSeparator: UIView!
  @IBOutlet weak var bottomSeparator: UIView!
  
  @IBOutlet weak var topSpace: NSLayoutConstraint!
  @IBOutlet weak var bottomSpace: NSLayoutConstraint!
  
  var roundCorners: CACornerMask = []
  
  override func awakeFromNib() {
    super.awakeFromNib()
    selectionStyle = .none
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
  
  func configure(appointment: AppointmentStruct) {
    nameLabel.attributedText = appointment.name
      .withFont(UIFont.Porcelain.idealSans(16))
      .withTextColor(UIColor.Porcelain.metallicBlue)
      .withKern(0.5)
    addOnsLabel.attributedText = getAddOns(app: appointment)
      .withFont(UIFont.Porcelain.openSans(14, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.metallicBlue)
      .withKern(0.5)
    dateLabel.attributedText = appointment.timeStart?.toString(WithFormat: AppointmentRequestCell.dateFormat)
      .withFont(UIFont.Porcelain.openSans(14, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.greyishBrown)
      .withKern(0.4)
    timeLabel.attributedText = getDuration(app: appointment)
      .withFont(UIFont.Porcelain.openSans(14, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.greyishBrown)
      .withKern(0.4)
    locationLabel.attributedText = (appointment.branch()?.name ?? "")
      .withFont(UIFont.Porcelain.openSans(14, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.warmGrey)
      .withKern(0.5)
//    sessionLabel.attributedText = "\(appointment.sessionsLeft) sessions left"
//      .withFont(UIFont.Porcelain.idealSans(13))
//      .withTextColor(UIColor.Porcelain.greyishBrown)
//      .withKern(0.5)
//    suggestedLabel.attributedText = "Suggested Next Session: In \(Int(((appointment.timeStart?.timeIntervalSinceNow ?? 0)/86400))) days"
//      .withFont(UIFont.Porcelain.idealSans(14))
//      .withTextColor(UIColor.Porcelain.warmGrey)
//      .withKern(0.5)
//
//    sessionLabel.isHidden = appointment.sessionsLeft == 0
//    sessionLabelHeight.constant = appointment.sessionsLeft == 0 ? 0 : 20
  }

  private func getAddOns(app: AppointmentStruct) -> String {
    var addOnStr = ""
    if app.addOns.count == 0 { return addOnStr + "None".localized() }
    let addOns = app.addOns.joined(separator: ", ")
    addOnStr += addOns
    return addOnStr
  }

  private func getDuration(app: AppointmentStruct) -> String {
    guard let tStart = app.timeStart,
      let tEnd = app.timeEnd else { return "N/A" }
    var time = "\(tStart.toString(WithFormat: "hh:mmaa")) - \(tEnd.toString(WithFormat: "hh:mmaa"))"
    time = time + " | \(duration(start: app.timeStart!, end: app.timeEnd!))"
    return time
  }

  private func duration(start: Date, end: Date) -> String {
    let hours = end.hoursFrom(start)
    var mins = end.minutesFrom(start)
    if hours > 0 { mins += (hours * 60) }
    return "\(mins) mins"
  }
}
