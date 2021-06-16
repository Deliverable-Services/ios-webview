//
//  UpcomingAppointmentCell.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 04/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import UIKit

class UpcomingAppointmentCell: UITableViewCell {
  static var identifier: String = String(describing: UpcomingAppointmentCell.self)
  static var estimatedCellHeight: CGFloat = 112
  
  @IBOutlet private weak var containerView: DesignableView!
  @IBOutlet private weak var confirmedLabel: UILabel!
  @IBOutlet private weak var nameLabel: UILabel!
  @IBOutlet private weak var addOnLabel: UILabel!
  @IBOutlet private weak var timeLabel: UILabel!
  @IBOutlet private weak var branchNameLabel: UILabel!
  @IBOutlet private weak var branchAddressLabel: UILabel!
  @IBOutlet private weak var dateContainerView: UIView!
  @IBOutlet private weak var icon: UIImageView!
  @IBOutlet private weak var timeIcon: UIImageView!
  @IBOutlet private weak var checkIconWidth: NSLayoutConstraint!
  @IBOutlet weak var statusLeftMargin: NSLayoutConstraint!
  private weak var dateView: DateCalendarView!
  private var appointment: AppointmentStruct!
  private var gradientLayer: CAGradientLayer?
  private var calendarView: DateCalendarView?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    timeIcon.image = #imageLiteral(resourceName: "time").withRenderingMode(.alwaysTemplate)
    timeIcon.tintColor = UIColor.white
    containerView.frame = contentView.frame
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    style()
  }
  
  private func style() {
    //containerView.frame = contentView.frame
    
    if gradientLayer == nil {
      gradientLayer = containerView
        .addGradientBackground(colors: UIColor.Porcelain.gradientMetallicBlue)
    }

    if appointment.type == AppointmentType.confirmed.rawValue {
      gradientLayer?.colors = UIColor.Porcelain.gradientMetallicBlue
    } else {
      gradientLayer?.colors = UIColor.Porcelain.gradientBlueGray
    }
    containerView.roundCorners(radius: 7)
    selectionStyle = .none
  }
  
  private func initDateView() {
    if calendarView != nil { calendarView?.removeFromSuperview() }
    guard let nibView =
      Bundle.main.loadNibNamed(DateCalendarView.identifier,
      owner: nil, options: nil)?.first as? DateCalendarView
    else { return }
    nibView.configure(date: appointment.timeStart ?? Date())
    nibView.frame = CGRect(origin: .zero, size: dateContainerView.frame.size)
    nibView.backgroundColor = appointment.type == AppointmentType.confirmed.rawValue ?
      UIColor.Porcelain.lightMetallicBlue : UIColor.white.withAlphaComponent(0.1)
    nibView.roundCorners(radius: 3)
    calendarView = nibView
    dateContainerView.addSubview(nibView)
  }
  
  func configure(_ appointment: AppointmentStruct) {
    self.appointment = appointment
    initDateView()

    if appointment.type == AppointmentType.confirmed.rawValue {
      confirmedLabel.attributedText = "CONFIRMED".localized()
        .withFont(UIFont.Porcelain.openSans(14, weight: .semiBold))
        .withTextColor(UIColor.Porcelain.whiteTwo)
        .withKern(0.5)
      icon.isHidden = false
      confirmedLabel.isHidden = false
      checkIconWidth.constant = 15.0
    } else {
      confirmedLabel.attributedText = "RESERVED".localized()
        .withFont(UIFont.Porcelain.openSans(14, weight: .semiBold))
        .withTextColor(UIColor.Porcelain.whiteTwo)
        .withKern(0.5)
      icon.isHidden = true
      checkIconWidth.constant = 0
      statusLeftMargin.constant = 0
    }

    nameLabel.attributedText = appointment.name.uppercased()
      .withFont(UIFont.Porcelain.openSans(16, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.whiteTwo)
      .withKern(0.5)
    addOnLabel.attributedText = getAddOns(app: appointment)
      .withFont(UIFont.Porcelain.openSans(14))
      .withTextColor(UIColor.Porcelain.whiteTwo)
      .withKern(0.5)
    timeLabel.attributedText = getDuration(app: appointment)
      .withFont(UIFont.Porcelain.openSans(14))
      .withTextColor(UIColor.Porcelain.whiteTwo)
      .withKern(0.5)
    branchNameLabel.attributedText = appointment.branch()!.name
      .withFont(UIFont.Porcelain.openSans(14, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.whiteTwo)
      .withKern(0.5)
    branchAddressLabel.attributedText = "\(appointment.branch()!.address)"
      .withFont(UIFont.Porcelain.openSans(14))
      .withTextColor(UIColor.Porcelain.whiteTwo)
      .withKern(0.5)
    branchAddressLabel.numberOfLines = 2
    branchAddressLabel.lineBreakMode = .byTruncatingTail
    icon.image = #imageLiteral(resourceName: "check")
    icon.contentMode = .scaleAspectFit
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
    return "\(tStart.toString(WithFormat: "hh:mmaa")) - \(tEnd.toString(WithFormat: "hh:mmaa"))"
  }
}
