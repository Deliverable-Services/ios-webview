//
//  PastAppointmentsTCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 30/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct AttributedTitleAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? {
    return 0.5
  }
  var alignment: NSTextAlignment? {
    return nil
  }
  var lineBreakMode: NSLineBreakMode? {
    return nil
  }
  var minimumLineHeight: CGFloat? {
    return 20.0
  }
  var font: UIFont? {
    return .openSans(style: .semiBold(size: 13.0))
  }
  var color: UIColor? {
    return .gunmetal
  }
}

private struct AttributedContentAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? {
    return 0.5
  }
  var alignment: NSTextAlignment? {
    return nil
  }
  var lineBreakMode: NSLineBreakMode? {
    return .byTruncatingTail
  }
  var minimumLineHeight: CGFloat? {
    return 20.0
  }
  var font: UIFont? {
    return .openSans(style: .regular(size: 13.0))
  }
  var color: UIColor? {
    return .bluishGrey
  }
}

private struct AttributedButtonTitleAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? = 1.0
  var alignment: NSTextAlignment?
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat?
  var font: UIFont? = .idealSans(style: .book(size: 13.0))
  var color: UIColor? = .lightNavy
}

public final class PastAppointmentsTCell: UITableViewCell, AppointmentProtocol {
  @IBOutlet private weak var shadowView: DesignableView!
  @IBOutlet private weak var containerView: DesignableView! {
    didSet {
      containerView.cornerRadius = 7.0
    }
  }
  @IBOutlet private weak var dateLabel: UILabel! {
    didSet {
      dateLabel.font = .openSans(style: .semiBold(size: 13.0))
      dateLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var treatmentLabel: UILabel! {
    didSet {
      treatmentLabel.font = .openSans(style: .semiBold(size: 16.0))
      treatmentLabel.textColor = .lightNavy
    }
  }
  @IBOutlet private weak var timeLabel: UILabel! {
    didSet {
      timeLabel.font = .openSans(style: .semiBold(size: 14.0))
      timeLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var addonsLabel: UILabel!
  @IBOutlet private weak var therapistLabel: UILabel!
  @IBOutlet private weak var locationLabel: UILabel!
  @IBOutlet private weak var rebookButton: UIButton! {
    didSet {
      var buttonTitleAppearance = AttributedButtonTitleAppearance()
      buttonTitleAppearance.color = .lightNavy
      rebookButton.setAttributedTitle("REBOOK".attributed.add(.appearance(buttonTitleAppearance)), for: .normal)
      rebookButton.backgroundColor = .white
    }
  }
  @IBOutlet private weak var leaveFeedbackButton: UIButton! {
    didSet {
      var buttonTitleAppearance = AttributedButtonTitleAppearance()
      buttonTitleAppearance.color = .white
      leaveFeedbackButton.setAttributedTitle("RATE SESSION".attributed.add(.appearance(buttonTitleAppearance)), for: .normal)
      leaveFeedbackButton.backgroundColor = .greyblue
    }
  }
  
  public var rebookDidTapped: ((Appointment) -> Void)?
  public var leaveFeedbackDidTapped: ((Appointment) -> Void)?
  
  public var appointment: Appointment? {
    didSet {
      dateLabel.text = startDate?.toString(WithFormat: "MMMM dd, yyyy | EEEE")
      treatmentLabel.text  = treatment?.name
      let titleApperance = AttributedTitleAppearance()
      let contentAppearance = AttributedContentAppearance()
      let timeT = [startDate?.toString(WithFormat: "h:mma"), endDate?.toString(WithFormat: "h:mma")].compactMap({ $0 }).joined(separator: " - ").emptyToNil ?? "-"
      timeLabel.text = timeT.uppercased()
      let addonsT = addons?.map({ $0.name }).compactMap({ $0 }).joined(separator: ", ").emptyToNil ?? "-"
      addonsLabel.attributedText = "Add-ons: ".attributed.add(.appearance(titleApperance)).append(
        attrs: addonsT.attributed.add(.appearance(contentAppearance)))
      therapistLabel.attributedText = "Therapist: ".attributed.add(.appearance(titleApperance)).append(
        attrs: (therapist?.fullName ?? "-").attributed.add(.appearance(contentAppearance)))
      let locationT = [center?.name, center?.address1].compactMap({ $0 }).joined(separator: ", ").emptyToNil ?? "-"
      locationLabel.attributedText = "Location: ".attributed.add(.appearance(titleApperance)).append(
        attrs: locationT.attributed.add(.appearance(contentAppearance)))
    }
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    shadowView.addShadow(appearance: .default)
  }
  
  @IBAction private func rebookTapped(_ sender: Any) {
    guard let appointment = appointment else { return }
    rebookDidTapped?(appointment)
  }
  
  @IBAction private func leaveFeedbackTapped(_ sender: Any) {
    guard let appointment = appointment else { return }
    leaveFeedbackDidTapped?(appointment)
  }
}

// MARK: - CellProtocol
extension PastAppointmentsTCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 231.0)
  }
}

