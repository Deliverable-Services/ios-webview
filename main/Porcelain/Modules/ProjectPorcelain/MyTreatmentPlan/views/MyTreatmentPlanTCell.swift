//
//  MyTreatmentPlanTCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 03/10/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public enum MyTreatmentPlanBookType {
  case bookNow(rebookData: RebookData?)
  case openAppointment(id: String)
}

public final class MyTreatmentPlanTCell: UITableViewCell {
  private let lineColor = UIColor(hex: 0xdae2eb)
  
  public enum Position: Int {
    case top
    case middle
    case bottom
  }
  
  @IBOutlet private weak var containerView: DesignableView!
  @IBOutlet private weak var treatmentNameLabel: UILabel! {
    didSet {
      treatmentNameLabel.font = .idealSans(style: .book(size: 13.0))
      treatmentNameLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var addonsTitleLabel: UILabel! {
    didSet {
      addonsTitleLabel.font = .openSans(style: .semiBold(size: 12.0))
      addonsTitleLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var addonsLabel: UILabel! {
    didSet {
      addonsLabel.font = .openSans(style: .regular(size: 12.0))
      addonsLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var sessionsLabel: UILabel! {
    didSet {
      sessionsLabel.font = .openSans(style: .semiBold(size: 12.0))
      sessionsLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var bookButton: DesignableButton! {
    didSet {
      bookButton.cornerRadius = 13.0
      bookButton.backgroundColor = .greyblue
      bookButton.setAttributedTitle(
        "BOOK NOW!".attributed.add([.color(.white), .font(.openSans(style: .semiBold(size: 12.0)))]),
        for: .normal)
    }
  }
  @IBOutlet private weak var daysLabel: UILabel! {
    didSet {
      daysLabel.font = .openSans(style: .semiBold(size: 10.0))
      daysLabel.textColor = .bluishGrey
    }
  }
  
  @IBOutlet private weak var rightContainerView: UIView!
  @IBOutlet private weak var rightHorizontalLineView: UIView! {
    didSet {
      rightHorizontalLineView.backgroundColor = lineColor
    }
  }
  @IBOutlet private weak var rightTopLineView: UIView! {
    didSet {
      rightTopLineView.backgroundColor = lineColor
    }
  }
  @IBOutlet private weak var rightBottomLineView: UIView! {
    didSet {
      rightBottomLineView.backgroundColor = lineColor
    }
  }
  @IBOutlet private weak var rightIndicatorImageView: UIImageView!
  @IBOutlet private weak var bottomContainerView: UIView!
 
  @IBOutlet private weak var bottomVerticalLineView: UIView! {
    didSet {
      bottomVerticalLineView.backgroundColor = lineColor
    }
  }
  @IBOutlet private weak var bottomHorizontalLineView: UIView! {
    didSet {
      bottomHorizontalLineView.backgroundColor = lineColor
    }
  }
  @IBOutlet private weak var bottomRightLineView: UIView! {
    didSet {
      bottomRightLineView.backgroundColor = lineColor
    }
  }
  @IBOutlet private weak var bottomIndicatorImageView: UIImageView!
  @IBOutlet private weak var bottomExtraView: UIView!
  
  public var bookDidTapped: ((MyTreatmentPlanBookType) -> Void)?
  
  public var treatmentPlanItem: TreatmentPlanItem? {
    didSet {
      treatmentNameLabel.text = treatmentPlanItem?.treatment?.name?.uppercased()
      addonsLabel.text = treatmentPlanItem?.addons?.compactMap({ $0.name }).joined(separator: ", ").emptyToNil ?? "-"
      sessionsLabel.text = String(format: "Sessions Left: %d", treatmentPlanItem?.sessionsLeft ?? 0)
      if let isBooked = treatmentPlanItem?.booked, isBooked {
        bookButton.backgroundColor = .greenishTealTwo
        bookButton.setAttributedTitle(
          "BOOKED".attributed.add([.color(.white), .font(.openSans(style: .semiBold(size: 12.0)))]),
          for: .normal)
      } else {
        bookButton.backgroundColor = .greyblue
        bookButton.setAttributedTitle(
          "BOOK NOW!".attributed.add([.color(.white), .font(.openSans(style: .semiBold(size: 12.0)))]),
          for: .normal)
      }
      daysLabel.text = treatmentPlanItem?.interval?.appending(" DAYS")
    }
  }
  
  public var position: Position = .middle {
    didSet {
      let lineColor = UIColor(hex: 0xdae2eb)
      rightIndicatorImageView.isHidden = position != .top
      bottomIndicatorImageView.isHidden = position == .bottom
      bottomHorizontalLineView.backgroundColor = position == .bottom ? lineColor: .clear
      rightTopLineView.backgroundColor = position != .top ? lineColor: .clear
      rightHorizontalLineView.backgroundColor = position == .top ? lineColor: .clear
      rightContainerView.isHidden = treatmentPlanItem?.plan?.cycles == 1
      bottomRightLineView.isHidden = treatmentPlanItem?.plan?.cycles == 1
      bottomContainerView.isHidden = position == .bottom && treatmentPlanItem?.plan?.cycles == 1
      bottomExtraView.isHidden = position != .bottom
    }
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    containerView.addShadow(appearance: .default)
  }
  
  @IBAction private func bookTapped(_ sender: Any) {
    if let appointmentID = treatmentPlanItem?.appointmentID {
      bookDidTapped?(.openAppointment(id: appointmentID))
    } else {
      let dispatchGroup = DispatchGroup()
      let center = AppUserDefaults.customer?.preferredCenter ?? Center.getCenters().first
      var treatment: Service?
      var addons: [Service]?
      
      if let centerID = center?.id {
        if let treatmentID = treatmentPlanItem?.treatment?.id {
          treatment = Service.getService(id: treatmentID, type: .treatment, centerID: centerID)
          if treatment == nil {
            dispatchGroup.enter()
            PPAPIService.Center.getTreatments(centerID: centerID).call { (response) in
              switch response {
              case .success(let result):
                CoreDataUtil.performBackgroundTask({ (moc) in
                  Service.parseCenterServicesFromData(result.data, centerID: centerID, type: .treatment, inMOC: moc)
                }, completion: { (_) in
                  treatment = Service.getService(id: treatmentID, type: .treatment, centerID: centerID)
                  dispatchGroup.leave()
                })
              case .failure:
                dispatchGroup.leave()
              }
            }
          }
        }
 
        if let addonIDs = treatmentPlanItem?.addons?.compactMap({ $0.id }), !addonIDs.isEmpty {
          addons = Service.getServices(serviceIDs: addonIDs, type: .addon, centerID: centerID)
          if let treatmentID = treatmentPlanItem?.treatment?.id, addons?.isEmpty ?? true {
            dispatchGroup.enter()
            PPAPIService.Center.getAddons(centerID: centerID, serviceID: treatmentID).call { (response) in
              switch response {
              case .success(let result):
                CoreDataUtil.performBackgroundTask({ (moc) in
                  Service.parseCenterServicesFromData(result.data, centerID: centerID, type: .addon, inMOC: moc)
                }, completion: { (_) in
                  addons = Service.getServices(serviceIDs: addonIDs, type: .addon, centerID: centerID)

                  dispatchGroup.leave()
                })
              case .failure:
                dispatchGroup.leave()
              }
            }
          }
        }
      }
      appDelegate.showLoading()
      dispatchGroup.notify(queue: .main) { [weak self] in
        guard let `self` = self else { return }
        appDelegate.hideLoading()
        self.bookDidTapped?(.bookNow(
          rebookData: RebookData(
            selectedCenter: center,
            selectedTreatment: treatment,
            selectedAddons: addons)))
      }
    }
  }
}

//MARK: - CellProtocol
extension MyTreatmentPlanTCell: CellProtocol {
}
