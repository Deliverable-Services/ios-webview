//
//  MyAppointmentTableFooter.swift
//  Porcelain
//
//  Created by Jean on 6/29/18.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit

enum AppointmentProcessType {
  case cancel, confirm
}

class MyAppointmentTableFooter: UIView {
  @IBOutlet private var separator: UIView!
  @IBOutlet private var noteLbl: UILabel!
  @IBOutlet private var confirmBtn: UIButton!
  @IBOutlet private var cancelBtn: UIButton!
  
  private var didTapCancelBlock: ((_ appointment: AppointmentStruct, _ processType: AppointmentProcessType?) -> ())?
  private var didTapConfirmBlock: ((_ appointment: AppointmentStruct, _ processType: AppointmentProcessType?) -> ())?
  private var appointment: AppointmentStruct?
//  private var processType: AppointmentProcessType?
  private var isSoon: Bool = false
  
  func configure(
    appointment: AppointmentStruct,
    isSoon: Bool,
    tapBlock: ((_ appointment: AppointmentStruct, _ processType: AppointmentProcessType?) -> ())?) {
    self.appointment = appointment
    self.didTapCancelBlock = tapBlock
    self.isSoon = isSoon

    confirmBtn.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
    cancelBtn.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
    noteLbl.numberOfLines = 0
    style(type: AppointmentType(rawValue: appointment.type)!)
  }
  
  @objc func didTapCancel() {
    guard let app = appointment else { return }
    didTapCancelBlock?(app, .cancel)
  }

  @objc func didTapConfirm() {
    guard let app = appointment else { return }
    didTapCancelBlock?(app, .confirm)
  }

  private func setupCancel() {
    cancelBtn.setAttributedTitle(
      "CANCEL APPOINTMENT".localized()
        .withFont(UIFont.Porcelain.idealSans(14))
        .withTextColor(UIColor.Porcelain.metallicBlue), for: .normal)
    cancelBtn.backgroundColor = UIColor.clear
    cancelBtn.layer.borderColor = UIColor.Porcelain.metallicBlue.cgColor
    cancelBtn.layer.borderWidth = 1.0
    cancelBtn.isHidden = false
//    processType = .cancel
  }

  private func setupConfirm() {
    confirmBtn.isHidden = false
    confirmBtn.setAttributedTitle(
      "CONFIRM APPOINTMENT".localized()
        .withFont(UIFont.Porcelain.idealSans(14))
        .withTextColor(UIColor.Porcelain.whiteTwo), for: .normal)
    confirmBtn.backgroundColor = UIColor.Porcelain.metallicBlue
//    processType = .confirm
  }

  private func setupCancelationNote() {
    noteLbl.isHidden = false
    noteLbl.attributedText = "Should you wish to cancel your appointment, you may do so 72 hours before the actual schedule.".localized()
      .withFont(UIFont.Porcelain.openSans(12))
      .withTextColor(UIColor.Porcelain.warmGrey)
      .withKern(0.5)
  }

  private func style(type: AppointmentType) {
    switch (type, isSoon) {
    case (.requested, true):
      separator.isHidden = true
      noteLbl.isHidden = true
      confirmBtn.isHidden = true
      cancelBtn.isHidden = true
    case (.requested, false):
      setupCancel()
      confirmBtn.isHidden = true
      separator.isHidden = true
      noteLbl.isHidden = true
    case (.reserved, true):
      setupConfirm()
      cancelBtn.isHidden = true
      separator.isHidden = true
      noteLbl.isHidden = true
    case (.reserved, false):
      setupCancel()
      setupConfirm()
      separator.isHidden = false
      setupCancelationNote()
    case (.confirmed, _):
      separator.isHidden = true
      noteLbl.isHidden = true
      confirmBtn.isHidden = true
      cancelBtn.isHidden = true
    }
  }
}
