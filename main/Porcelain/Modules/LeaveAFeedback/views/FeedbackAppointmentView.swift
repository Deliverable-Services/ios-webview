//
//  FeedbackAppointmentView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 02/08/2019.
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
    return nil
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

public final class FeedbackAppointmentView: DesignableView, AppointmentProtocol {
  @IBOutlet private weak var view: UIView!
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
  @IBOutlet private weak var notesStack: UIStackView!
  @IBOutlet private weak var notesTitleLabel: UILabel! {
    didSet {
      notesTitleLabel.font = .openSans(style: .semiBold(size: 13.0))
      notesTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var notesLabel: UILabel!
  
  public var appointment: Appointment? {
    didSet {
      updateUI()
    }
  }
  
  public convenience init(appointment: Appointment) {
    self.init(frame: .zero)
    
    self.appointment = appointment
    updateUI()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    commonInit()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    commonInit()
  }
  
  private func commonInit() {
    loadNib(FeedbackAppointmentView.self)
    addSubview(view)
    view.addContainerBoundsResizingMask()
    cornerRadius = 7.0
    borderWidth = 1.0
    borderColor = .whiteThree
    backgroundColor = .white
  }
  
  private func updateUI() {
    let titleAppearance = AttributedTitleAppearance()
    let contentApperance = AttributedContentAppearance()
    dateLabel.text = startDate?.toString(WithFormat: "MMMM dd, yyyy | EEEE")
    treatmentLabel.text  = treatment?.name
    let timeT = [startDate?.toString(WithFormat: "h:mma"), endDate?.toString(WithFormat: "h:mma")].compactMap({ $0 }).joined(separator: " - ").emptyToNil ?? "-"
    timeLabel.text = timeT.uppercased()
    let addonsT = addons?.map({ $0.name }).compactMap({ $0 }).joined(separator: ", ").emptyToNil ?? "-"
    addonsLabel.attributedText = "Add-ons: ".attributed.add(.appearance(titleAppearance)).append(
      attrs: addonsT.attributed.add(.appearance(contentApperance)))
    therapistLabel.attributedText = "Therapist: ".attributed.add(.appearance(titleAppearance)).append(
      attrs: (therapist?.fullName ?? "-").attributed.add(.appearance(contentApperance)))
    let locationT = [center?.name, center?.address1].compactMap({ $0 }).joined(separator: ", ").emptyToNil ?? "-"
    locationLabel.attributedText = "Location: ".attributed.add(.appearance(titleAppearance)).append(
      attrs: locationT.attributed.add(.appearance(contentApperance)))
    if let notes = appointmentNote?.note, !notes.isEmpty {
      notesStack.isHidden = false
      notesLabel.attributedText = notes.attributed.add(.appearance(contentApperance))
    } else {
      notesStack.isHidden = true
    }
  }
}
