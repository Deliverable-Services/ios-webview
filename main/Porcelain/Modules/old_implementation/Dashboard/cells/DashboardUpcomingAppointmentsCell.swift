//
//  DashboardUpcomingAppointmentsCell.swift
//  Porcelain
//
//  Created by Justine Rangel on 27/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import CenteredCollectionView
import SwiftyJSON
import KRProgressHUD
import SwiftyAttributes
import R4pidKit

public protocol DashboardUpcomingAppointmentsCellDelegate: class {
  func displayError()
}

public protocol DashboardUpcomingAppointmentsViewModelProtocol: class {
  var upcomingAppointments: [AppointmentStruct] { get }
  var previousAppointments: [TreatmentHistory] { get }
  
  func fetchContent()
  func reloadContent()
  func attachView(_ view: DashboardUpcomingAppointmentsCell)
}

public class DashboardUpcomingAppointmentsCell: UICollectionViewCell {
  @IBOutlet fileprivate weak var upcomingCollectionView: UICollectionView!
  
  fileprivate var viewModel: DashboardUpcomingAppointmentsViewModelProtocol!
  weak var delegate: DashboardUpcomingAppointmentsCellDelegate?
  private var hasNoAppointments: Bool = false
  
  public func configure(viewModel: DashboardUpcomingAppointmentsViewModelProtocol) {
    self.viewModel = viewModel
    self.viewModel.reloadContent()
    self.viewModel.attachView(self)
    self.reloadData()
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    let layout = CenteredCollectionViewFlowLayout()
    layout.itemSize = CGSize(width: rect.width - 32.0, height: rect.height)
    layout.minimumInteritemSpacing = 6.0
    layout.minimumLineSpacing = 6.0
    upcomingCollectionView.collectionViewLayout = layout
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    upcomingCollectionView.collectionViewLayout.invalidateLayout()
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    upcomingCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
    upcomingCollectionView.dataSource = self
    upcomingCollectionView.delegate = self
  }
  
  public func reloadData() {
    hasNoAppointments = (viewModel.previousAppointments.count + viewModel.upcomingAppointments.count == 0)
    upcomingCollectionView.reloadData()
    guard hasNoAppointments == false else { return }
    guard viewModel.upcomingAppointments.count > 0 else {
      DispatchQueue.main.async {
        self.upcomingCollectionView
          .scrollToItem(at: IndexPath(item: self.viewModel.previousAppointments.count - 1, section: 0),
                        at: .centeredHorizontally, animated: true)
      }
      return
    }
    DispatchQueue.main.async {
      self.upcomingCollectionView
        .scrollToItem(at: IndexPath(item: self.viewModel.previousAppointments.count, section: 0),
                      at: .centeredHorizontally, animated: true)
    }
  }
  
  public func displayError() {
    delegate?.displayError()
  }
}

// MARK: - CellProtocol
extension DashboardUpcomingAppointmentsCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 200.0)
  }
}

// MARK: - UICollectionViewDataSource
extension DashboardUpcomingAppointmentsCell: UICollectionViewDataSource {
  public func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int) -> Int {

    return hasNoAppointments ? 1: viewModel.previousAppointments.count + viewModel.upcomingAppointments.count
  }
  
//  public func collectionView(_ collectionView: UICollectionView,
//                             willDisplay cell: UICollectionViewCell,
//                             forItemAt indexPath: IndexPath) {
//    guard let theCell = cell as? UpcomingAppppointmentCell else { return }
//    theCell.style()
//  }

  public func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    if hasNoAppointments {
      let noAppointmentCell = collectionView.dequeueReusableCell(withReuseIdentifier: NoAppointmentCell.identifier, for: indexPath) as! NoAppointmentCell
      return noAppointmentCell
    } else {
      let upcomingAppointmentCell = collectionView.dequeueReusableCell(UpcomingAppppointmentCell.self, atIndexPath: indexPath)
      let row = indexPath.row
      if row >= viewModel.previousAppointments.count {
        let index = row - (viewModel.previousAppointments.count)
        upcomingAppointmentCell
          .configure(
            upcomingAppointment: viewModel.upcomingAppointments[index],
            index: index)
      } else {
        upcomingAppointmentCell
          .configure(treatmentHistory: viewModel.previousAppointments[row])
      }
      return upcomingAppointmentCell
    }
  }
}

// MARK: - UICollectionViewDelegate
extension DashboardUpcomingAppointmentsCell: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView,
                             didSelectItemAt indexPath: IndexPath) {
    guard !hasNoAppointments else { return }
    
    let row = indexPath.row
    if indexPath.row > viewModel.previousAppointments.count - 1 {
      let app = viewModel.upcomingAppointments[row - viewModel.previousAppointments.count]
      PushNotificationHandler.show(
        upcoming: app,
        in: delegate as! UIViewController)
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DashboardUpcomingAppointmentsCell: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.bounds.width - 32.0, height: collectionView.bounds.height)
  }
}

public class NoAppointmentCell: UICollectionViewCell, Designable {
  public var cornerRadius: CGFloat = 7.0
  public var borderWidth: CGFloat = 0.0
  public var borderColor: UIColor = UIColor.Porcelain.lightGrey
  
  public var shadowLayer: CAShapeLayer!
  static var identifier = String(describing:NoAppointmentCell.self)
  
  @IBOutlet weak var titleLabel: UILabel!
  
  override public func awakeFromNib() {
    super.awakeFromNib()
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    titleLabel.textColor = UIColor.Porcelain.lightMetallicBlue
    updateLayer()
//    addShadow(color: UIColor.Porcelain.warmGrey, fillColor: UIColor.white.withAlphaComponent(0.8), cornerRadius: 7.0)
  }
}

public class UpcomingAppppointmentCell: UICollectionViewCell, Shadowable {
  public var shadowLayer: CAShapeLayer!
  @IBOutlet weak var headerLabel: DesignableLabel!
  @IBOutlet weak var dayLabel: DesignableLabel!
  @IBOutlet weak var dayMonthLabel: DesignableLabel!
  @IBOutlet weak var dayContainer: DesignableView!
  @IBOutlet weak var treatmentLabel: DesignableLabel!
  @IBOutlet weak var treatmentAddonLabel: DesignableLabel!
  @IBOutlet weak var treatmentTimeLabel: DesignableLabel!
  @IBOutlet weak var locationNameLabel: DesignableLabel!
  @IBOutlet weak var locationAddressLabel: DesignableLabel!
  @IBOutlet weak var containerView: DesignableView!
  private var appointment: AppointmentStruct?
  private var treatment: TreatmentHistory?
  private var gradientLayer: CAGradientLayer?
  
  func style() {
    DispatchQueue.main.async {
      self.containerView.roundCorners(radius: 7)
      self.gradientLayer?.removeFromSuperlayer()
      if self.appointment != nil &&
        self.appointment!.type != AppointmentType.requested.rawValue {
        if self.appointment?.type == AppointmentType.confirmed.rawValue {
          self.gradientLayer = self.containerView
            .addGradientBackground(
              colors: UIColor.Porcelain.gradientMetallicBlue,
              name: "gradientLayer")
        } else {
          self.gradientLayer = self.containerView
            .addGradientBackground(
              colors: UIColor.Porcelain.gradientBlueGray,
              name: "gradientLayer")
        }
      } else if self.treatment != nil {
        self.gradientLayer = self.containerView
          .addGradientBackground(
            colors: UIColor.Porcelain.gradientGray,
            name: "gradientLayer")
      }
    }
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    style()
  }
  
  func configure(treatmentHistory: TreatmentHistory) {
    guard treatmentHistory.id != nil else { return }
    self.appointment = nil
    self.treatment = treatmentHistory

    dayContainer.backgroundColor = UIColor.white.withAlphaComponent(0.1)
    headerLabel.attributedText = "PAST".localized()
      .withFont(UIFont.Porcelain.openSans(14, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.whiteTwo)
      .withKern(0.5)
    treatmentLabel.attributedText = (treatmentHistory.name?.uppercased() ?? "")
      .withFont(UIFont.Porcelain.openSans(16, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.whiteTwo)
      .withKern(0.5)
    treatmentAddonLabel.attributedText = getAddOns(treatment: treatment!)
      .withFont(UIFont.Porcelain.openSans(14))
      .withTextColor(UIColor.Porcelain.whiteTwo)
      .withKern(0.5)
    treatmentTimeLabel.attributedText =
      "\((treatmentHistory.startDate! as Date).toString(WithFormat: "hh:mmaa")) - \((treatmentHistory.endDate! as Date).toString(WithFormat: "hh:mmaa"))"
      .withFont(UIFont.Porcelain.openSans(14))
      .withTextColor(UIColor.Porcelain.whiteTwo)
      .withKern(0.5)
    
    let locationStr = treatmentHistory.location
    let lBound = treatmentHistory.location?.range(of: ",")?.lowerBound
    
    locationNameLabel.attributedText = "\(String(locationStr![..<lBound!])) "
      .withFont(UIFont.Porcelain.openSans(14, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.whiteTwo)
      .withKern(0.5)
    + MaterialDesignIcon.pin.rawValue
      .withFont(UIFont.Porcelain.materialDesign(14))
      .withTextColor(UIColor.white)
      .withKern(0.4)
    
    let nextIndex = locationStr?.index(after: lBound!)
    locationAddressLabel.attributedText = String(locationStr![nextIndex!...]
      .trimmingCharacters(in: [" "]))
      .withFont(UIFont.Porcelain.openSans(14))
      .withTextColor(UIColor.Porcelain.whiteTwo)
      .withKern(0.5)
    locationAddressLabel.numberOfLines = 2
    locationAddressLabel.lineBreakMode = .byTruncatingTail
    
    dayLabel.attributedText = (treatmentHistory.startDate! as Date)
      .toString(WithFormat: DateCalendarView.weekdayFormat).uppercased()
      .withFont(UIFont.Porcelain.openSans(24, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.whiteTwo)
      .withKern(0.5)
    
    dayMonthLabel.attributedText = (treatmentHistory.endDate! as Date)
      .toString(WithFormat: DateCalendarView.dateFormat).uppercased()
      .withFont(UIFont.Porcelain.openSans(13, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.whiteTwo)
      .withKern(0.5)
    style()
  }

  private func getAddOns(app: AppointmentStruct) -> String {
    var addOnStr = "Add-ons: "
    if app.addOns.count == 0 { return addOnStr + "None".localized() }
    let addOns = app.addOns.joined(separator: ", ")
    addOnStr += addOns
    return addOnStr
  }
  
  func configure(upcomingAppointment: AppointmentStruct, index: Int) {
    guard upcomingAppointment.id != "" else { return }
    self.treatment = nil
    self.appointment = upcomingAppointment

    dayContainer.backgroundColor = UIColor.white.withAlphaComponent(0.1)
    headerLabel.attributedText = (index == 0 ? "UP NEXT".localized() : "UPCOMING".localized())
      .withFont(UIFont.Porcelain.openSans(14, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.whiteTwo)
      .withKern(0.5)
    treatmentLabel.attributedText = upcomingAppointment.name.uppercased()
      .withFont(UIFont.Porcelain.openSans(16, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.whiteTwo)
      .withKern(0.5)
    treatmentAddonLabel.attributedText = getAddOns(app: upcomingAppointment)
      .withFont(UIFont.Porcelain.openSans(14))
      .withTextColor(UIColor.Porcelain.whiteTwo)
      .withKern(0.5)
    treatmentTimeLabel.attributedText = duration(app: upcomingAppointment)
      .withFont(UIFont.Porcelain.openSans(14))
      .withTextColor(UIColor.Porcelain.whiteTwo)
      .withKern(0.5)
    locationNameLabel.attributedText = "\(upcomingAppointment.branch()!.name) "
      .withFont(UIFont.Porcelain.openSans(14, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.whiteTwo)
      .withKern(0.5)
    + MaterialDesignIcon.pin.rawValue
      .withFont(UIFont.Porcelain.materialDesign(14))
      .withTextColor(UIColor.white)
      .withKern(0.4)
    locationAddressLabel.attributedText = "\(upcomingAppointment.branch()!.address)"
      .withFont(UIFont.Porcelain.openSans(14))
      .withTextColor(UIColor.Porcelain.whiteTwo)
      .withKern(0.5)
    locationAddressLabel.numberOfLines = 2
    locationAddressLabel.lineBreakMode = .byTruncatingTail
    
    dayLabel.attributedText = (upcomingAppointment.timeStart ?? Date())
      .toString(WithFormat: DateCalendarView.weekdayFormat).uppercased()
      .withFont(UIFont.Porcelain.openSans(24, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.whiteTwo)
      .withKern(0.5)
    
    dayMonthLabel.attributedText = (upcomingAppointment.timeStart ?? Date())
      .toString(WithFormat: DateCalendarView.dateFormat).uppercased()
      .withFont(UIFont.Porcelain.openSans(13, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.whiteTwo)
      .withKern(0.5)

    style()
  }
  
  private func duration(app: AppointmentStruct) -> String {
    guard let tStart = app.timeStart,
      let tEnd = app.timeEnd else { return "N/A" }
    return "\(tStart.toString(WithFormat: "hh:mmaa")) - \(tEnd.toString(WithFormat: "hh:mmaa"))"
  }

  private func getAddOns(treatment: TreatmentHistory) -> String {
    var addOnStr = "Add-ons: "
    if treatment.addOns.count == 0 { return addOnStr + "None".localized() }
    addOnStr += treatment.addOns.joined(separator: ", ")
    return addOnStr
  }
}

extension UpcomingAppppointmentCell: CellProtocol {
  public static var defaultSize: CGSize {
    return .zero
  }
}
