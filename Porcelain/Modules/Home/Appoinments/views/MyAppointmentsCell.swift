//
//  MyAppointmentsCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 08/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class MyAppointmentsCell: UICollectionViewCell, AppointmentProtocol, Shadowable {
  public var shadowLayer: CAShapeLayer!
  
  @IBOutlet private weak var containerView: DesignableView! {
    didSet {
      containerView.cornerRadius = 7.0
    }
  }
  @IBOutlet private weak var dayLabel: UILabel! {
    didSet {
      dayLabel.font = .openSans(style: .semiBold(size: 24.0))
      dayLabel.textColor = .lightNavy
    }
  }
  @IBOutlet private weak var ddMMlabel: UILabel! {
    didSet {
      ddMMlabel.font = .openSans(style: .semiBold(size: 13.0))
      ddMMlabel.textColor = .lightNavy
    }
  }
  @IBOutlet private weak var serviceNameLabel: UILabel! {
    didSet {
      serviceNameLabel.font = .idealSans(style: .book(size: 13.0))
      serviceNameLabel.textColor = .lightNavy
    }
  }
  @IBOutlet private weak var timeLabel: UILabel! {
    didSet {
      timeLabel.font = .openSans(style: .regular(size: 12.0))
      timeLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var addOnsTitleLabel: UILabel! {
    didSet {
      addOnsTitleLabel.font = .openSans(style: .semiBold(size: 12.0))
      addOnsTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var addOnsLabel: UILabel! {
    didSet {
      addOnsLabel.font = .openSans(style: .regular(size: 12.0))
      addOnsLabel.textColor = .lightNavy
    }
  }
  @IBOutlet private weak var therapistTitleLabel: UILabel! {
    didSet {
      therapistTitleLabel.font = .openSans(style: .semiBold(size: 12.0))
      therapistTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var therapistLabel: UILabel! {
    didSet {
      therapistLabel.font = .openSans(style: .regular(size: 12.0))
      therapistLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var locationLabel: UILabel! {
    didSet {
      locationLabel.font = .openSans(style: .semiBold(size: 12.0))
      locationLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var footerView: UIView! {
    didSet {
      footerView.backgroundColor = .greyblue
    }
  }
  @IBOutlet private weak var statusLabel: UILabel! {
    didSet {
      sessionsLabel.font = .openSans(style: .semiBold(size: 13.0))
      sessionsLabel.textColor = .white

    }
  }
  @IBOutlet private weak var sessionsLabel: UILabel! {
    didSet {
      sessionsLabel.font = .openSans(style: .semiBold(size: 12.0))
      sessionsLabel.textColor = .white
    }
  }
  
  public var appointment: Appointment? {
    didSet {
      dayLabel.text = startDate?.toString(WithFormat: "E").uppercased()
      ddMMlabel.text = startDate?.toString(WithFormat: "d MMM").uppercased()
      serviceNameLabel.text = treatment?.name
      let times = [startDate?.toString(WithFormat: "h:mma"), endDate?.toString(WithFormat: "h:mma")].compactMap({ $0 })
      timeLabel.attributedText = MaterialDesignIcon.time.attributed.add([
        .color(.gunmetal),
        .font(.materialDesign(size: 12.0))]).append(
          attrs: " \(times.joined(separator: " - "))".attributed.add([.color(.gunmetal), .font(.openSans(style: .regular(size: 12.0)))]))
      let addonsT = addons?.map({ $0.name }).compactMap({ $0 })
      addOnsLabel.text = addonsT?.joined(separator: ", ").emptyToNil ?? "-"
      therapistLabel.text = therapist?.fullName.emptyToNil ?? "-"
      let locationT = center?.name ?? "-"
      locationLabel.attributedText = MaterialDesignIcon.pin.attributed.add([.color(.lightNavy), .font(.materialDesign(size: 12.0))]).append(
        attrs: " \(locationT)".attributed.add([.color(.gunmetal), .font(.openSans(style: .regular(size: 12.0)))]))
      switch appointmentState {
      case .confirmed:
        statusLabel.attributedText = MaterialDesignIcon.check.attributed.add([.color(.white), .font(.materialDesign(size: 14.0))]).append(
          attrs: " CONFIRMED".attributed.add([.color(.white), .font(.openSans(style: .semiBold(size: 13.0)))]))
        footerView.backgroundColor = .greyblue
      case .reserved:
        statusLabel.attributedText = "RESERVED".attributed.add([.color(.white), .font(.openSans(style: .semiBold(size: 13.0)))])
        footerView.backgroundColor = .lightNavy
      case .requested:
        statusLabel.attributedText = "PENDING".attributed.add([.color(.white), .font(.openSans(style: .semiBold(size: 13.0)))])
        footerView.backgroundColor = .heather
      default: break
      }
      sessionsLabel.text = "Sessions left: \(sessionsLeft)"
    }
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    addShadow(appearance: .default)
  }
}

// MARK: - CellProtocol
extension MyAppointmentsCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 286.0, height: 222.0)
  }
}
