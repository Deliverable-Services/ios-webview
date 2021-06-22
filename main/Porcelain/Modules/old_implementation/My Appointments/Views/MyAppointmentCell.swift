//
//  MyAppointmentCell.swift
//  Porcelain
//
//  Created by Jean on 6/29/18.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import SwiftyAttributes

class MyAppointmentCell: UITableViewCell {
  static var identifier: String = String(describing: MyAppointmentCell.self)
  static var dateFormat: String = "h:mmaa"
  static var cellHeight: CGFloat = 256.0
  
  @IBOutlet private var dateContainerView: UIView!
  @IBOutlet private var addOnsTitleLbl: UILabel!
  @IBOutlet private var addOnsLbl: UILabel!
  @IBOutlet private var timeLbl: UILabel!
  @IBOutlet private var therepistsTitleLbl: UILabel!
  @IBOutlet private var therapistsLbl: UILabel!
  @IBOutlet private var locationTitleLbl: UILabel!
  @IBOutlet private var locationLbl: UILabel!
  @IBOutlet private var noteLbl: UILabel!
  @IBOutlet private var calendarStack: UIStackView!
  @IBOutlet private var topMargin: NSLayoutConstraint!
  
  private var dateView: DateCalendarView!
  private var contactUsBlock: (() -> ())?
  
  @IBOutlet private var containerView: UIView!

  override func awakeFromNib() {
    super.awakeFromNib()
    initLocationTap()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    containerView.layer.shadowColor = UIColor.black.cgColor
    containerView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
    containerView.layer.shadowOpacity = 0.2
    containerView.layer.shadowRadius = 4.0
    containerView.layer.masksToBounds = false
    containerView.layer.cornerRadius = 7.0
    containerView.backgroundColor = UIColor.white
  }
  
  func configure(
    appointment app: AppointmentStruct,
    isSoon: Bool,
    contactUsBlock blk: (() -> ())? = nil) {

    CalendarEventUtil.searchEvent(query: app.id) { (events) in
      if events.isEmpty {
        self.calendarStack.isHidden = true
        self.topMargin.isActive = true
      } else {
        self.calendarStack.isHidden = false
        self.topMargin.isActive = false
      }
    }

    contactUsBlock = blk
    timeLbl.attributedText = getDuration(app: app)
      .withFont(UIFont.Porcelain.openSans(14, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.greyishBrown)
      .withKern(0.4)
    addOnsTitleLbl.attributedText = "ADD-ONS".localized()
      .withFont(UIFont.Porcelain.openSans(14, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.greyishBrown)
      .withKern(0.4)
    addOnsLbl.attributedText = getAddOns(app: app)
      .withFont(UIFont.Porcelain.openSans(14, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.metallicBlue)
      .withKern(0.4)
    therepistsTitleLbl.attributedText = "THERAPIST".localized()
      .withFont(UIFont.Porcelain.openSans(14, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.greyishBrown)
      .withKern(0.4)
    locationTitleLbl.attributedText =
      "LOCATION ".localized()
      .withFont(UIFont.Porcelain.openSans(14, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.greyishBrown)
      .withKern(0.4)
    + MaterialDesignIcon.pin.rawValue
      .withFont(UIFont.Porcelain.materialDesign(14))
      .withTextColor(UIColor.Porcelain.red)
      .withKern(0.4)
    locationLbl.attributedText = "\(app.branch()!.name), \(app.branch()!.address)"
      .withFont(UIFont.Porcelain.openSans(14, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.metallicBlue)
      .withKern(0.4)
    
    initDateView(appointment: app)
    therapistsLbl.attributedText = therapists(app: app)
    
    configureNote(appointment: app, isSoon: isSoon)
  }

  private func initLocationTap() {
    let tapGesture = UITapGestureRecognizer(
      target: self, action: #selector(MyAppointmentCell.contactBlck))
    locationLbl.addGestureRecognizer(tapGesture)
    locationLbl.isUserInteractionEnabled = true
  }

  private func getDuration(app: AppointmentStruct) -> String {
    guard let tStart = app.timeStart,
          let tEnd = app.timeEnd else { return "N/A" }
    return "\(tStart.toString(WithFormat: MyAppointmentCell.dateFormat)) - \(tEnd.toString(WithFormat: MyAppointmentCell.dateFormat)) | \(duration(start: tStart, end: tEnd)) mins"
  }
  
  private func duration(start: Date, end: Date) -> String {
    let hours = end.hoursFrom(start)
    var mins = end.minutesFrom(start)
    if hours > 0 { mins += (hours * 60) }
    return "\(mins)"
  }
  
  private func initDateView(appointment: AppointmentStruct) {
    guard let nibView =
      Bundle.main.loadNibNamed(DateCalendarView.identifier,
                               owner: nil, options: nil)?.first as? DateCalendarView
      else { return }
    nibView.configure(date: (appointment.timeStart ?? Date()), style: .light)
    nibView.frame = CGRect(origin: .zero, size: dateContainerView.frame.size)
    nibView.roundCorners(radius: 3)
    dateContainerView.addSubview(nibView)
  }

  private func getAddOns(app: AppointmentStruct) -> String {
    if app.addOns.count == 0 { return "None".localized() }
    return app.addOns.joined(separator: ", ")
  }
  
  private func therapists(app: AppointmentStruct) -> NSAttributedString {
    let attributes: [Attribute] = [
      .font(UIFont.Porcelain.openSans(14)),
      .textColor(UIColor.Porcelain.warmGrey),
      .kern(0.5)
    ]
//    if app.preferredTherapists.count == 0 {
//      return "No Preference".localized().withAttributes(attributes)
//    }
    
//    var pTherapists = app.preferredTherapists
//    var therapists = pTherapists.removeFirst()
//    pTherapists.forEach { (str) in
//      therapists += ", \(str)"
//    }
    
    if app.preferredTherapists == "" {
      return "No Preference".localized().withAttributes(attributes)
    }
    
    return app.preferredTherapists.withAttributes(attributes)
  }

//  private func setupCannotCancel() {
//    noteLbl.isHidden = false
//    noteLbl.attributedText = "You cannot cancel your appointment at this time. Cancellation with less than 72 hours notice will result in a cancellation charge.".localized()
//      .withFont(UIFont.Porcelain.openSans(12))
//      .withTextColor(UIColor.Porcelain.warmGrey)
//      .withKern(0.5)
//  }

  private func setupProcessing() {
    noteLbl.isHidden = false
    noteLbl.attributedText = "Note: Your request is being processed. We’ll respond as soon as possible.".localized()
      .withFont(UIFont.Porcelain.openSans(12))
      .withTextColor(UIColor.Porcelain.warmGrey)
      .withKern(0.5)
  }

  private func setupContactToCancel() {
    noteLbl.isHidden = false
    noteLbl.attributedText = "Note: If you would like to cancel your appointment, ".localized()
      .withFont(UIFont.Porcelain.openSans(13))
      .withTextColor(UIColor.Porcelain.warmGrey)
      .withKern(0.5)
      +
    "please contact us."
      .withFont(UIFont.Porcelain.openSans(13, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.metallicBlue)
      .withKern(0.5)
    noteLbl.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(contactBlck))
    )
    noteLbl.isUserInteractionEnabled = true
  }

  private func configureNote(appointment: AppointmentStruct, isSoon: Bool) {
    let type = AppointmentType(rawValue: appointment.type)!
    switch (type, isSoon) {
    case (.requested, true):
      setupContactToCancel()
    case (.requested, false):
      setupProcessing()
    case (.reserved, true):
      setupContactToCancel()
    case (.reserved, false):
      noteLbl.isHidden = true
    case (.confirmed, _):
      setupContactToCancel()
    }
  }
  
  @objc func contactBlck() {
    contactUsBlock?()
  }
}
