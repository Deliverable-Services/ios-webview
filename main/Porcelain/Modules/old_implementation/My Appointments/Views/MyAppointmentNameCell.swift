//
//  MyAppointmentNameCell.swift
//  Porcelain
//
//  Created by Jean on 6/29/18.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit

protocol MyAppointmentNameCellDelegate: class {
  func didAddToCalendar(appId: String)
}

class MyAppointmentNameCell: UITableViewCell {
  static var identifier = String(describing:MyAppointmentNameCell.self)
  
  @IBOutlet private var nameLbl: UILabel!
//  @IBOutlet private var sessionsLbl: UILabel!
  @IBOutlet private var addCalendarBtn: UIButton!
  @IBOutlet private var titleTopConstraint: NSLayoutConstraint!
  @IBOutlet private var titleBottomConstraint: NSLayoutConstraint!
  @IBOutlet private var addCalendarBtnHeight: NSLayoutConstraint!
  @IBOutlet private var containerView: DesignableView!
  
  private var appointment: AppointmentStruct?
  private var gradientLayer: CAGradientLayer?
  private var delegate: MyAppointmentNameCellDelegate?

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    style()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    addGradient()
  }
  
  private func style() {
    addCalendarBtn.setImage(#imageLiteral(resourceName: "calendar-add").withRenderingMode(.alwaysTemplate), for: .normal)
    addCalendarBtn.tintColor = UIColor.white
    backgroundColor = UIColor.Porcelain.metallicBlue
    translatesAutoresizingMaskIntoConstraints = false
  }

  private func addGradient() {
    if gradientLayer == nil {
      gradientLayer = CAGradientLayer()
      gradientLayer?.frame = contentView.bounds
      contentView.layer.insertSublayer(gradientLayer!, at: 0)
    }

    if self.appointment?.type == AppointmentType.confirmed.rawValue {
      gradientLayer?.colors = UIColor.Porcelain.gradientMetallicBlue
    } else {
      gradientLayer?.colors = UIColor.Porcelain.gradientBlueGray
    }
  }
  
  func configure(
    appointment app: AppointmentStruct,
    delegate _del: MyAppointmentNameCellDelegate?) {

    delegate = _del
    appointment = app
    nameLbl.attributedText = app.name
      .withTextColor(UIColor.Porcelain.whiteTwo)
      .withFont(UIFont.Porcelain.idealSans(22))
      .withKern(0.5)

//    sessionsLbl.isHidden = true
//    sessionsLbl.isHidden = app.isFromNotification
//    sessionsLbl.attributedText = "\(app.sessionsDone) of \(app.sessionsLeft+app.sessionsDone) sessions left"
//      .withTextColor(UIColor.Porcelain.whiteTwo)
//      .withFont(UIFont.Porcelain.openSans(14, weight: .semiBold))
//      .withKern(0.5)
    CalendarEventUtil.searchEvent(query: app.id) { (events) in
      if events.isEmpty &&
        (app.type == AppointmentType.confirmed.rawValue || app.type == AppointmentType.reserved.rawValue) {
        self.titleTopConstraint.constant = 88
        self.titleBottomConstraint.constant = 24
        self.addCalendarBtn.isHidden = false
        self.addCalendarBtn.tintColor = UIColor.white
        self.addCalendarBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
      } else {
        self.titleTopConstraint.constant = 40
        self.titleBottomConstraint.constant = 40
        self.addCalendarBtn.isHidden = true
      }
    }
  }
  
  @IBAction private func addToCalendarTapped(_ sender: Any) {
    guard let appointment = appointment else { return }
    guard let timeStart = appointment.timeStart else { return }
    guard let endTime = appointment.timeEnd else { return }
    CalendarEventUtil.saveOrUpdateEvent(eventModel:
      CalendarEventItem(
        title: appointment.name,
        startDate: timeStart,
        endDate: endTime,
        alarms: [.onTime, .oneHourBefore],
        notes: appointment.id)) { (eventId) in

        guard let _app = self.appointment else { return }
        self.configure(appointment: _app, delegate: self.delegate)
        self.delegate?.didAddToCalendar(appId: appointment.id)
    }
  }
}
