//
//  BookAppointmentScheduleCell.swift
//  Porcelain
//
//  Created by Justine Rangel on 19/10/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public enum BAScheduleIndicatorType {
  case alert(message: String)
  case activity(isLoading: Bool)
}

public struct BookAppointmentScheduleData {
  init(selectedCalendarReferenceDate: Date?,
       calendarScheduleDate: BACalendarScheduleDate?,
       selectedScheduleTime: BAScheduleTime?,
       selectedScheduleTherapist: BAScheduleTherapist?,
       indicatorType: BAScheduleIndicatorType?) {
    self.selectedCalendarReferenceDate = selectedCalendarReferenceDate
    self.calendarScheduleDate = calendarScheduleDate
    self.selectedScheduleTime = selectedScheduleTime
    self.selectedScheduleTherapist = selectedScheduleTherapist
    self.indicatorType = indicatorType
    
    contents = []
    therapists = []
    var morningContents: [BookAppointmentScheduleItemData] = []
    var afternoonContents: [BookAppointmentScheduleItemData] = []
    var eveningContents: [BookAppointmentScheduleItemData] = []
    if let location = calendarScheduleDate?.locations.first {
      let times = location.therapists.map { $0.timeSlots.map { $0 } }.flatMap { $0 }.unique().sorted { (time1, time2) -> Bool in
        let doubleTime1 = time1.rawTime.replacingOccurrences(of: ":", with: "").toNumber().doubleValue
        let doubleTime2 = time2.rawTime.replacingOccurrences(of: ":", with: "").toNumber().doubleValue
        return doubleTime1 < doubleTime2
      }
      times.forEach { (time) in
        let therapists = location.therapists.filter({ $0.timeSlots.contains(where: { $0 == time } )})
        let scheduleItemData = BookAppointmentScheduleItemData(
          timeSlot: time,
          therapists: therapists,
          isDummy: false)
        if time.amPM == "AM" || time.amPM == "MN" {//Morning 12MN - 11:59AM
          morningContents.append(scheduleItemData)
        } else if time.hour.toNumber().intValue >= 6 &&
          time.hour.toNumber().intValue < 12 &&
          time.amPM == "PM" {//Evening 6PM
          eveningContents.append(scheduleItemData)
        } else {//Afternoon
          afternoonContents.append(scheduleItemData)
        }
      }
    }
    let morningContentCount = morningContents.count
    let afternoonContentCount = afternoonContents.count
    let eveningContentCount = eveningContents.count
    var maxSectionCount = morningContentCount
    if afternoonContentCount > maxSectionCount {
      maxSectionCount = afternoonContentCount
    }
    if eveningContentCount > maxSectionCount {
      maxSectionCount = eveningContentCount
    }

    if maxSectionCount > 0 {
      for indx in 0...(maxSectionCount - 1) {
        if morningContentCount > indx {
          contents.append(morningContents[indx])
        } else{
          contents.append(BookAppointmentScheduleItemData(
            timeSlot: nil,
            therapists: [],
            isDummy: true))
        }
        if afternoonContentCount > indx {
          contents.append(afternoonContents[indx])
        } else{
          contents.append(BookAppointmentScheduleItemData(
            timeSlot: nil,
            therapists: [],
            isDummy: true))
        }
        if eveningContentCount > indx {
          contents.append(eveningContents[indx])
        } else{
          contents.append(BookAppointmentScheduleItemData(
            timeSlot: nil,
            therapists: [],
            isDummy: true))
        }
      }
    }

    if let selectedScheduleTime = selectedScheduleTime,
      let indx = self.contents.index(where: { $0.timeSlot == selectedScheduleTime }) {
      therapists = contents[indx].therapists
    }
  }
  
  var selectedCalendarReferenceDate: Date?
  var calendarScheduleDate: BACalendarScheduleDate?
  var contents: [BookAppointmentScheduleItemData]
  var selectedScheduleTime: BAScheduleTime?
  var selectedScheduleTherapist: BAScheduleTherapist?
  var indicatorType: BAScheduleIndicatorType?
  var therapists: [BAScheduleTherapist]
}

public final class BookAppointmentScheduleCell: UITableViewCell {
  @IBOutlet private weak var contentStack: UIStackView!
  @IBOutlet private weak var scheduleContainerView: DesignableView!
  @IBOutlet private weak var headerTitleLabel: UILabel!
  @IBOutlet private weak var morningLabel: UILabel!
  @IBOutlet private weak var afternoonLabel: UILabel!
  @IBOutlet private weak var eveningLabel: UILabel!
  @IBOutlet private weak var timeCollectionView: UICollectionView!
  @IBOutlet private weak var timeCollectionHeightConstraint: NSLayoutConstraint!
  @IBOutlet private weak var therapistsContainerView: DesignableView!
  @IBOutlet private weak var selectTherapistContainerView: UIView!
  @IBOutlet private weak var selectTherapistTitle: UILabel!
  @IBOutlet private weak var therapistTableView: ListingTableView!
  @IBOutlet private weak var therapistTableHeightConstraint: NSLayoutConstraint!
  @IBOutlet private weak var messageContainerView: UIView!
  @IBOutlet private weak var messageLabel: UILabel!
  @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
  
  public var didSelectScheduleTime: ((BAScheduleTime) -> ())?
  public var didSelectScheduleTherapist: ((BAScheduleTherapist, Bool) -> ())? //therapist, reload
  
  public var scheduleImage: UIImage? {
    scheduleContainerView.cornerRadius = 7.0
    let image = UIImage.makeFromView(scheduleContainerView)
    scheduleContainerView.cornerRadius = 0.0
    return image
  }
  
  public var therapistsImage: UIImage? {
    therapistsContainerView.cornerRadius = 7.0
    let image = UIImage.makeFromView(therapistsContainerView)
    therapistsContainerView.cornerRadius = 0.0
    return image
  }
  
  public var data: BookAppointmentScheduleData? {
    didSet {
      if let indicatorType = data?.indicatorType {
        contentStack.isHidden = true
        messageContainerView.isHidden = false
        switch indicatorType {
        case .alert(let message):
          activityIndicatorView.stopAnimating()
          messageLabel.isHidden = false
          messageLabel.attributedText = NSAttributedString(
            content: message,
            font: UIFont.Porcelain.openSans(14.0, weight: .semiBold),
            foregroundColor: UIColor.Porcelain.warmGrey,
            paragraphStyle: ParagraphStyle.makeCustomStyle(
              lineHeight: 20.0,
              characterSpacing: 0.5,
              alignment: .center).wordWrapped())
        case .activity(let isLoading):
          messageLabel.isHidden = true
          if isLoading {
            activityIndicatorView.startAnimating()
          } else {
            activityIndicatorView.stopAnimating()
          }
        }
      } else {
        contentStack.isHidden = false
        var headerContents: [String] = ["AVAILABLE SLOTS "]
        if let datescription = data?.selectedCalendarReferenceDate?.toString(
          WithFormat: "MMMM d, YYYY") {
          headerContents.append(concatenate("FOR ", datescription.uppercased()))
        }
        headerTitleLabel.attributedText = NSAttributedString(
          content: headerContents.joined(),
          font: UIFont.Porcelain.openSans(14.0, weight: .semiBold),
          foregroundColor: UIColor.Porcelain.greyishBrown,
          paragraphStyle: ParagraphStyle.makeCustomStyle(
            lineHeight: 14.0,
            characterSpacing: 0.5))
        messageContainerView.isHidden = true
        timeCollectionView.reloadData()
        therapistTableView.reloadData()
        updateSelectionIfNeeded()
        updateHeightConstraintIfNeeded()
      }
    }
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    morningLabel.attributedText = NSAttributedString(
      content: "MORNING".localized(),
      font: UIFont.Porcelain.openSans(14.0, weight: .semiBold),
      foregroundColor: UIColor.Porcelain.greyishBrown,
      paragraphStyle: ParagraphStyle.makeCustomStyle(
        lineHeight: 14.0,
        characterSpacing: 0.5,
        alignment: .center))
    afternoonLabel.attributedText = NSAttributedString(
      content: "AFTERNOON".localized(),
      font: UIFont.Porcelain.openSans(14.0, weight: .semiBold),
      foregroundColor: UIColor.Porcelain.greyishBrown,
      paragraphStyle: ParagraphStyle.makeCustomStyle(
        lineHeight: 14.0,
        characterSpacing: 0.5,
        alignment: .center))
    eveningLabel.attributedText = NSAttributedString(
      content: "EVENING".localized(),
      font: UIFont.Porcelain.openSans(14.0, weight: .semiBold),
      foregroundColor: UIColor.Porcelain.greyishBrown,
      paragraphStyle: ParagraphStyle.makeCustomStyle(
        lineHeight: 14.0,
        characterSpacing: 0.5,
        alignment: .center))
    selectTherapistTitle.attributedText = NSAttributedString(
      content: "SELECT THERAPIST",
      font: UIFont.Porcelain.openSans(12.0, weight: .semiBold),
      foregroundColor: UIColor.Porcelain.greyishBrown,
      paragraphStyle: ParagraphStyle.makeCustomStyle(
        lineHeight: 12.0,
        characterSpacing: 0.0,
        alignment: .center))
    timeCollectionView.registerWithNib(BookAppointmentScheduleItemCell.self)
    timeCollectionView.dataSource = self
    timeCollectionView.delegate = self
    timeCollectionView.reloadData()
    therapistTableView.isSelectable = true
    therapistTableView.registerWithNib(BAScheduleTherapistsItemCell.self)
    therapistTableView.alwaysBounceVertical = false
    therapistTableView.rowHeight = BAScheduleTherapistsItemCell.defaultSize.height
    therapistTableView.rowCount = { [weak self] in
      guard let `self` = self, let data = self.data else { return 0 }
      return data.therapists.count
    }
    therapistTableView.cellForIndexPath = { [weak self] indexPath in
      guard let `self` = self, let data = self.data else { return UITableViewCell() }
      let cell = self.therapistTableView.dequeueReusableCell(BAScheduleTherapistsItemCell.self, atIndexPath: indexPath)
      cell.data = BAScheduleTherapistsItemData(
        scheduleTherapist: data.therapists[indexPath.row],
        isSelected: false)
      return cell
    }
    therapistTableView.didSelectIndexPath = { [weak self] indexPath  in
      guard let `self` = self, let data = self.data else { return }
      self.didSelectScheduleTherapist?(data.therapists[indexPath.row], true)
    }
    therapistTableView.didReloadWithHeight = { [weak self] height in
      guard let `self` = self else { return }
      self.therapistTableHeightConstraint.constant = height
    }
    updateHeightConstraintIfNeeded()
  }
  
  private func updateSelectionIfNeeded() {
    guard let data = data else { return }
    if let selectedTime = data.selectedScheduleTime {
      if let selectedRow = data.contents.index(where: { $0.timeSlot == selectedTime }) {
        DispatchQueue.main.async {
          self.timeCollectionView.selectItem(
            at: IndexPath(row: selectedRow, section: 0),
            animated: false,
            scrollPosition: .centeredHorizontally)
        }
      }
    }
    if data.therapists.count == 1 && data.selectedScheduleTherapist == nil {
      //select if only one therapist and no selected
      DispatchQueue.main.async {
        self.therapistTableView.selectRow(
          at: IndexPath(row: 0, section: 0),
          animated: false,
          scrollPosition: .none)
      }
      didSelectScheduleTherapist?(data.therapists.first!, false)
    } else {
      if let selectedTherapist = data.selectedScheduleTherapist {
        if let selectedRow = data.therapists.index(where: { $0 == selectedTherapist }) {
          DispatchQueue.main.async {
            self.therapistTableView.selectRow(
              at: IndexPath(row: selectedRow, section: 0),
              animated: false,
              scrollPosition: .none)
          }
        }
      }
    }
    selectTherapistContainerView.isHidden = data.selectedScheduleTime == nil
  }
  
  private func updateHeightConstraintIfNeeded() {
    layoutIfNeeded()
    let newHeight = timeCollectionView.contentSize.height
    if timeCollectionHeightConstraint.constant != newHeight {
      timeCollectionHeightConstraint.constant = newHeight
    }
  }
}

// MARK: - CellProtocol
extension BookAppointmentScheduleCell: CellProtocol {
  public static var defaultSize: CGSize {
    return .zero
  }
}

// MARK: - UICollectionViewDataSource
extension BookAppointmentScheduleCell: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return data?.contents.count ?? 0
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let bookAppointmentScheduleItemCell = collectionView.dequeueReusableCell(BookAppointmentScheduleItemCell.self, atIndexPath: indexPath)
    bookAppointmentScheduleItemCell.data = data!.contents[indexPath.row]
    return bookAppointmentScheduleItemCell
  }
}

// MARK: - UICollectionViewDelegate
extension BookAppointmentScheduleCell: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let bookAppointmentScheduleItemCell = collectionView.cellForItem(at: indexPath) as? BookAppointmentScheduleItemCell else { return }
    guard let data = bookAppointmentScheduleItemCell.data else { return }
    guard let timeSlot = data.timeSlot else { return }
    guard !data.isDummy else {
      updateSelectionIfNeeded()
      return
    }
    didSelectScheduleTime?(timeSlot)
    print("THERAPISTS START")
    self.data?.therapists = data.therapists
    data.therapists.forEach { (therapist) in
      print(therapist.name)
    }
    print("THERAPISTS END")
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension BookAppointmentScheduleCell: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let betweenSpacing: CGFloat = 32.0
    let sideSpacing: CGFloat = 16.0
    let width = (collectionView.bounds.width - ((2 * betweenSpacing) + (2 * sideSpacing)))/3
    return CGSize(width: width, height: BookAppointmentScheduleItemCell.defaultSize.height)
  }
}

public struct BookAppointmentScheduleItemData {
  var timeSlot: BAScheduleTime?
  var therapists: [BAScheduleTherapist]
  var isDummy: Bool
}

public final class BookAppointmentScheduleItemCell: UICollectionViewCell {
  @IBOutlet private weak var selectionView: DesignableView!
  @IBOutlet private weak var titleLabel: UILabel!
  
  public var data: BookAppointmentScheduleItemData? {
    didSet {
      updateSelection()
    }
  }
  
  public override var isHighlighted: Bool {
    didSet {
      updateSelection(isHighlighted)
    }
  }
  
  public override var isSelected: Bool {
    didSet {
      updateSelection(isSelected)
    }
  }
  
  private func updateSelection(_ isSelected: Bool = false) {
    guard let data = data else { return }
    if data.isDummy {
      selectionView.isHidden = true
      titleLabel.isHidden = true
    } else if let timeSlot = data.timeSlot  {
      selectionView.isHidden = false
      titleLabel.isHidden = false
      titleLabel.attributedText = NSAttributedString(
        content: concatenate(timeSlot.hour, ":", timeSlot.minutes, " ", timeSlot.amPM),
        font: UIFont.Porcelain.openSans(14.0, weight: isSelected ? .semiBold: .regular),
        foregroundColor: isSelected ? UIColor.Porcelain.whiteTwo: UIColor.Porcelain.warmGrey,
        paragraphStyle: ParagraphStyle.makeCustomStyle(
          lineHeight: 14.0,
          characterSpacing: 0.5,
          alignment: .center))
      selectionView.backgroundColor = isSelected ? UIColor.Porcelain.metallicBlue: .clear
    }
  }
}

// MARK: - CellProtocol
extension BookAppointmentScheduleItemCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 34.0)
  }
}

public struct BAScheduleTherapistsItemData {
  var scheduleTherapist: BAScheduleTherapist
  var isSelected: Bool
  
  var title: String {
    return scheduleTherapist.name
  }
}

public final class BAScheduleTherapistsItemCell: UITableViewCell {
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var selectionIndicatorLabel: UILabel!
  
  public var data: BAScheduleTherapistsItemData? {
    didSet {
      updateUI()
    }
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    selectionIndicatorLabel.attributedText = NSAttributedString(
      content: MaterialDesignIcon.check.rawValue,
      font: UIFont.Porcelain.materialDesign(18.0),
      foregroundColor: UIColor.Porcelain.metallicBlue)
  }
  
  public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    super.setHighlighted(animated, animated: animated)
    
    updateUI(isSelected: highlighted)
  }
  
  public override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    updateUI(isSelected: selected)
  }
  
  private func updateUI(isSelected: Bool = false) {
    guard let data = data else { return }
    titleLabel.attributedText = NSAttributedString(
      content: data.title,
      font: UIFont.Porcelain.idealSans(14.0, weight: .book),
      foregroundColor: isSelected ? UIColor.Porcelain.metallicBlue: UIColor.Porcelain.warmGrey,
      paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 14.0, characterSpacing: 0.5))
    selectionIndicatorLabel.isHidden = !isSelected
  }
}

// MARK: - CellProtocol
extension BAScheduleTherapistsItemCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 48.0)
  }
}
