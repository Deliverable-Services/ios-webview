//
//  AvailableScheduleLocationCell.swift
//  Porcelain
//
//  Created by Justine Rangel on 30/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import R4pidKit

public class SavedSelectedSched {
  public static var dateString: String?
  public static var therapistID: String?
  public static var timeString: String?
}

public struct ScheduleTimeSlot {
  init(json: JSON) {
    let timeString = json[PorcelainAPIConstant.Key.time].string ?? ""
    self.timeString = timeString
    let time = timeString.components(separatedBy: ":")
    let hourInt = time.first?.toNumber().intValue ?? 0
    let minutesInt = time.last?.toNumber().intValue ?? 0
    if hourInt == 12 {
      hour = time.first ?? "00"
      if minutesInt == 0 {
        amPM = "NN"
      } else {
        amPM = "PM"
      }
    } else if hourInt > 12 {
      let difference = hourInt - 12
      hour = concatenate(difference < 10 ? "0": "", difference)
      amPM = "PM"
    } else if hourInt == 0 && minutesInt == 0 {
      hour = time.first ?? "00"
      amPM = "MN"
    } else  {
      hour = time.first ?? "00"
      amPM = "AM"
    }
    minutes = time.last ?? "00"
  }
  
  var timeString: String
  var amPM: String
  var hour: String
  var minutes: String
}

public struct AvailableScheduleTherapist {
  init(json: JSON) {
    id = json[PorcelainAPIConstant.Key.id].string ?? ""
    name = json[PorcelainAPIConstant.Key.name].string ?? ""
    scheduleTimeSlots = json[PorcelainAPIConstant.Key.slots].arrayValue.map({ (slotJSON) -> ScheduleTimeSlot in
      return ScheduleTimeSlot(json: slotJSON)
    })
  }
  
  var id: String
  var name: String
  var scheduleTimeSlots: [ScheduleTimeSlot]
}

public protocol AvailableScheduleLocationViewModelProtocol {
  var id: String { get }
  var title: String { get }
  var dateString: String { get }
  var address: String { get }
  var therapists: [AvailableScheduleTherapist] { get }
}

public struct AvailableScheduleLocationViewModel: AvailableScheduleLocationViewModelProtocol {
  init(json: JSON, dateString: String) {
    id = json[PorcelainAPIConstant.Key.id].string ?? ""
    title = json[PorcelainAPIConstant.Key.name].string ?? ""
    self.dateString = dateString
    address = json[PorcelainAPIConstant.Key.address].string ?? ""
    therapists = json[PorcelainAPIConstant.Key.therapists].arrayValue.map({ (therapistJSON) -> AvailableScheduleTherapist in
      return AvailableScheduleTherapist(json: therapistJSON)
    })
    therapists = therapists.filter({ return $0.scheduleTimeSlots.count > 0 })
  }
  
  public var id: String
  
  public var title: String
  
  public var dateString: String
  
  public var address: String
  
  public var therapists: [AvailableScheduleTherapist]
}

public struct SelectedAvailableSchedule  {
  var dateString: String
  var locationID: String
  var therapistID: String
  var timeString: String
}

public class AvailableScheduleLocationCell: UITableViewCell {
  @IBOutlet private weak var locationTitleLabel: DesignableLabel!
  @IBOutlet private weak var therapistScheduleCollectionView: UICollectionView!
  @IBOutlet private weak var therapistScheduleCollectionViewHeightConstraint: NSLayoutConstraint!
  
  public var didSelectSchedule: ((SelectedAvailableSchedule) -> ())?
  
  private var viewModel: AvailableScheduleLocationViewModelProtocol!
  
  public func configure(viewModel: AvailableScheduleLocationViewModelProtocol) {
    self.viewModel = viewModel
    locationTitleLabel.attributedText = NSAttributedString(content: viewModel.title,
                                                           font: UIFont.Porcelain.idealSans(24.0, weight: .book),
                                                           foregroundColor: UIColor.Porcelain.greyishBrown,
                                                           paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 24.0, characterSpacing: 1.5))
    therapistScheduleCollectionView.reloadData()
    recalculateCollectionViewHeight()
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    therapistScheduleCollectionView.dataSource = self
    therapistScheduleCollectionView.delegate = self
  }
  
  private func recalculateCollectionViewHeight() {
    let height = therapistScheduleCollectionView.collectionViewLayout.collectionViewContentSize.height
    therapistScheduleCollectionViewHeightConstraint.constant = height
    layoutIfNeeded()
  }
}

// MARK: - CellProtocol
extension AvailableScheduleLocationCell: CellProtocol {
  public static var defaultSize: CGSize {
    return .zero
  }
}

// MARK: - UICollectionViewDataSource
extension AvailableScheduleLocationCell: UICollectionViewDataSource {
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    return viewModel.therapists.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.therapists[section].scheduleTimeSlots.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let availableScheduleTimeSlotCell = collectionView.dequeueReusableCell(AvailableScheduleTimeSlotCell.self, atIndexPath: indexPath)
    let therapist = viewModel.therapists[indexPath.section]
    let timeSlot = therapist.scheduleTimeSlots[indexPath.row]
    availableScheduleTimeSlotCell.timeSlot = timeSlot
    if SavedSelectedSched.dateString == viewModel.dateString && SavedSelectedSched.timeString == timeSlot.timeString && SavedSelectedSched.therapistID == therapist.id {
      DispatchQueue.main.async { collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .right) }//TODO fix this
    }
    return availableScheduleTimeSlotCell
  }
}

// MARK: - UICollectionViewDelegate
extension AvailableScheduleLocationCell: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let therapist = viewModel.therapists[indexPath.section]
    let timeString = therapist.scheduleTimeSlots[indexPath.row].timeString
    SavedSelectedSched.dateString = viewModel.dateString
    SavedSelectedSched.therapistID = therapist.id
    SavedSelectedSched.timeString = timeString
    let selectedAvailableSchedule = SelectedAvailableSchedule(dateString: viewModel.dateString, locationID: viewModel.id, therapistID: therapist.id, timeString: timeString)
    didSelectSchedule?(selectedAvailableSchedule)
  }
  
  public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if kind == UICollectionElementKindSectionHeader {
      let header = collectionView.dequeueReusableSupplementaryHeaderView(ScheduleTimeHeader.self, atIndexPath: indexPath)
      header.title = viewModel.therapists[indexPath.section].name
      return header
    } else {
      let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "genericFooter", for: indexPath)
      return footer
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AvailableScheduleLocationCell: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return AvailableScheduleTimeSlotCell.defaultSize
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: collectionView.bounds.width, height: ScheduleTimeHeader.defaultSize.height)
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    return CGSize(width: collectionView.bounds.width, height: 16.0)
  }
}

public class ScheduleTimeHeader: UICollectionReusableView {
  @IBOutlet private weak var titleLabel: DesignableLabel!
  
  public var title: String? {
    didSet {
      guard let title = title else { return }
      titleLabel.attributedText = NSAttributedString(content: title,
                                                     font: UIFont.Porcelain.idealSans(16.0, weight: .book),
                                                     foregroundColor: UIColor.Porcelain.metallicBlue,
                                                     paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 16.0, characterSpacing: 1.0))
    }
  }
}

extension ScheduleTimeHeader: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 36)
  }
}

public class AvailableScheduleTimeSlotCell: UICollectionViewCell {
  @IBOutlet private weak var titleLabel: DesignableLabel!
  
  public var timeSlot: ScheduleTimeSlot? {
    didSet {
      updateSelectionIsSelected()
    }
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    titleLabel.cornerRadius = titleLabel.bounds.height/2
    titleLabel.updateLayer()
  }
  
  deinit {
  }
  
  public override var isHighlighted: Bool {
    didSet {
      updateSelectionIsSelected(isHighlighted)
    }
  }
  
  public override var isSelected: Bool {
    didSet {
      updateSelectionIsSelected(isSelected)
    }
  }
  
  private func updateSelectionIsSelected(_ isSelected: Bool = false) {
    guard let timeSlot = timeSlot else { return }
    let postfix = timeSlot.amPM
    titleLabel.attributedText = NSAttributedString(content: concatenate(timeSlot.hour, ":", timeSlot.minutes, " ", postfix),
                                                   font: UIFont.Porcelain.openSans(14.0, weight: isSelected ? .semiBold: .regular),
                                                   foregroundColor: isSelected ? UIColor.Porcelain.whiteTwo: UIColor.Porcelain.greyishBrown,
                                                   paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 14.0, characterSpacing: 0.5, alignment: .center))
    titleLabel.backgroundColor = isSelected ? UIColor.Porcelain.blueGrey: .clear
  }
}

// MARK: - CellProtocol
extension AvailableScheduleTimeSlotCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 93.0, height: 32.0)
  }
}
