//
//  BAACalendarView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 25/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public enum WeekDays: Int {
  case sun = 0, mon, tues, weds, thur, fri, sat
  
  public var code: String {
    switch self {
    case .sun:
      return "SU"
    case .mon:
      return "MO"
    case .tues:
      return "TU"
    case .weds:
      return "WE"
    case .thur:
      return "TH"
    case .fri:
      return "FR"
    case .sat:
      return "SA"
    }
  }
  
  public static var count: Int {
    return 7
  }
}

private enum BAACalendarSection: Int {
  case header = 0
  case day
  
  static var count: Int {
    return 2
  }
}

public struct BAACalendarData {
  public var calendarReferenceDate: Date
  public var selectedCalendarReferenceDate: Date?
}

public struct SlotDatesData {
  var centerID: String
  var treatmentID: String
  var addonIDs: [String]?
  var therapistIDs: [String]?
}

public final class BAACalendarView: DesignableView {
  @IBOutlet private weak var view: UIView!
  @IBOutlet private weak var prevButton: UIButton! {
    didSet {
      prevButton.setImage(UIImage.icChevronLeft.maskWithColor(.gunmetal), for: .normal)
    }
  }
  @IBOutlet private weak var monthLabel: UILabel! {
    didSet {
      monthLabel.font = .openSans(style: .semiBold(size: 16.0))
      monthLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var nextButton: UIButton! {
    didSet {
      nextButton.setImage(UIImage.icChevronRight.maskWithColor(.gunmetal), for: .normal)
    }
  }
  @IBOutlet private weak var collectionView: ResizingContentCollectionView! {
    didSet {
      collectionView.registerWithNib(BAACalendarCCell.self)
      collectionView.dataSource = self
      collectionView.delegate = self
    }
  }
  
  private var availableSlotDatesRequest: URLSessionDataTask?
  private var availableSlotDates: [String] = [] {
    didSet {
      updateUI()
    }
  }
  private var slotDatesData: SlotDatesData?
  
  private var dates: [Date] = []
  private var validDates: [Date] = []
  public var selectedDate: Date?
  
  public var didSelectDate: DateCompletion?
  
  private var offSetMonth: Int = 0
  
  public func evaluateSlotDates(data: SlotDatesData) {
    self.slotDatesData = data
    availableSlotDatesRequest?.cancel()
    availableSlotDates = []
    let currentDate = Date().dateByAdding(months: offSetMonth)
    availableSlotDatesRequest = PPAPIService.Center.getAvailableSlotDates(
      centerID: data.centerID,
      treatmentID: data.treatmentID,
      addOnIDs: data.addonIDs,
      therapistIDs: data.therapistIDs,
      startDate: currentDate.startOfMonth(), endDate: currentDate.endOfMonth()).call { [weak self] (response) in
        guard let `self` = self else { return }
        switch response {
        case .success(let result):
          self.availableSlotDates = result.data.arrayValue.compactMap({ $0.string })
        case .failure:
          self.availableSlotDates = []
        }
    }
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    commonInit()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    commonInit()
  }
  
  private func commonInit() {
    loadNib(BAACalendarView.self)
    addSubview(view)
    view.addContainerBoundsResizingMask()
    cornerRadius = 7.0
    borderWidth = 1.0
    borderColor = .whiteThree
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    updateUI()
  }
  
  private func updateUI() {
    let currentDate = Date().dateByAdding(months: offSetMonth)
    monthLabel.text = currentDate.toString(WithFormat: "MMMM yyyy").uppercased()
    dates = []
    validDates = []
    let firstDayOfTheMonth = currentDate.startOfMonth()
    let firstWeekDayInt = Calendar.current.component(.weekday, from: firstDayOfTheMonth)
    let firstWeekDayDiff = 1 - firstWeekDayInt
    var startDateEnumerator = firstDayOfTheMonth.dateByAdding(days: firstWeekDayDiff)
    let lastDayOfTheMonth = currentDate.endOfMonth()
    let lastWeekDayInt = Calendar.current.component(.weekday, from: lastDayOfTheMonth)
    let lastWeekDayDiff = 7 - lastWeekDayInt
    let endDateEnumerator = lastDayOfTheMonth.dateByAdding(days: lastWeekDayDiff)
    while startDateEnumerator <= endDateEnumerator {
      dates.append(startDateEnumerator)
      if startDateEnumerator > Date().dateByAdding(days: -1) &&
        startDateEnumerator >= firstDayOfTheMonth &&
        startDateEnumerator <= lastDayOfTheMonth {
        validDates.append(startDateEnumerator)
      }
      startDateEnumerator = startDateEnumerator.dateByAdding(days: 1)
    }
    collectionView.reloadData()
    updateDateSelection()
  }
  
  public func updateDateSelection() {
    let dateFormat = "MM-dd-yyyy"
    guard let selectedDate = selectedDate, validDates.contains(selectedDate) else { return }
    let selectedDateString = selectedDate.toString(WithFormat: dateFormat)
    guard let indx = dates.firstIndex(where: { $0.toString(WithFormat: dateFormat) == selectedDateString }) else { return }
    collectionView.selectItem(at: IndexPath(row: indx, section: BAACalendarSection.day.rawValue), animated: false, scrollPosition: .centeredHorizontally)
  }
  
  public func resetSelectedDate() {
    selectedDate = nil
    updateUI()
  }
  
  public func reset() {
    selectedDate = nil
    offSetMonth = 0
    availableSlotDates = []
    updateUI()
  }
  
  @IBAction private func prevTapped(_ sender: Any) {
    offSetMonth -= 1
    if let slotDatesData = slotDatesData {
      evaluateSlotDates(data: slotDatesData)
    } else {
      updateUI()
    }
    UIView.transition(with: collectionView, duration: 0.3, options: [.transitionCurlDown], animations: {
    }, completion: {(_) in
    })
  }
  
  @IBAction private func nextTapped(_ sender: Any) {
    offSetMonth += 1
    if let slotDatesData = slotDatesData {
      evaluateSlotDates(data: slotDatesData)
    } else {
      updateUI()
    }
    UIView.transition(with: collectionView, duration: 0.3, options: [.transitionCurlUp], animations: {
    }, completion: {(_) in
    })
  }
}

// MARK: - UICollectionViewDataSource
extension BAACalendarView: UICollectionViewDataSource {
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    return BAACalendarSection.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch BAACalendarSection(rawValue: section)! {
    case .header:
      return WeekDays.count
    case .day:
      return dates.count
    }
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let baaCalendarCCell = collectionView.dequeueReusableCell(BAACalendarCCell.self, atIndexPath: indexPath)
    switch BAACalendarSection(rawValue: indexPath.section)! {
    case .header:
      baaCalendarCCell.type = .headerCode(value: WeekDays(rawValue: indexPath.row)!.code)
    case .day:
      let date = dates[indexPath.row]
      baaCalendarCCell.type = .dayCode(data: .init(
        date: date,
        isRedOnly: !validDates.contains(date),
        hasAvailableSlots: availableSlotDates.contains(date.toString(WithFormat: .ymdDateFormat))))
    }
    return baaCalendarCCell
  }
}

// MARK: - UICollectionViewDelegate
extension BAACalendarView: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    switch BAACalendarSection(rawValue: indexPath.section)! {
    case .header: break
    case .day:
      let date = dates[indexPath.row]
      guard validDates.contains(date) else { return }
      self.selectedDate = date
      self.didSelectDate?(date)
    }
  }
  
  public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    switch BAACalendarSection(rawValue: indexPath.section)! {
    case .header:
      return false
    case .day:
      let flag = validDates.contains(dates[indexPath.row])
      if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first, !flag {
        DispatchQueue.main.async {
          collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .centeredHorizontally)
        }
      }
      return flag
    }
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    switch BAACalendarSection(rawValue: section)! {
    case .header:
      return CGSize(width: collectionView.bounds.width, height: 5.0)
    case .day:
      return .zero
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension BAACalendarView: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let ratio: CGFloat = 260.0/343.0
    let width = collectionView.bounds.width/7.1
    return CGSize(width: width, height: width * ratio)
  }
}

public struct BAACalendarItemData {
  var date: Date?
  var isRedOnly: Bool
  var hasAvailableSlots: Bool
}

public final class BAACalendarCCell: UICollectionViewCell {
  public enum `Type` {
    case headerCode(value: String)
    case dayCode(data: BAACalendarItemData)
  }
  
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var selectionIndicatorView: DesignableView!
  @IBOutlet private weak var availableIndicatorLabel: UILabel! {
    didSet {
      availableIndicatorLabel.textColor = .greyblue
    }
  }
  
  private var isSelectionActive: Bool = false {
    didSet {
      if isSelectionActive {
        selectionIndicatorView.cornerRadius = selectionIndicatorView.bounds.width/2.0
        selectionIndicatorView.backgroundColor = .lightNavy
      } else {
        selectionIndicatorView.cornerRadius = selectionIndicatorView.bounds.width/2.0
        selectionIndicatorView.backgroundColor = .clear
      }
    }
  }
  
  public var type: Type = .headerCode(value: "") {
    didSet {
      updateSelection(isSelected)
    }
  }
  
  public override var isHighlighted: Bool {
    didSet {
      alpha = isHighlighted ? 0.8: 1.0
    }
  }
  
  public override var isSelected: Bool {
    didSet {
      updateSelection(isSelected)
    }
  }
  
  private func updateSelection(_ isSelected: Bool = false) {
    switch type {
    case .headerCode(let value):
      titleLabel.attributedText = value.attributed.add([
        .color(.gunmetal),
        .font(.openSans(style: .semiBold(size: 14.0)))])
      titleLabel.alpha = 1.0
      availableIndicatorLabel.isHidden = true
      isSelectionActive = false
    case .dayCode(let data):
      guard let day = data.date?.toString(WithFormat: "d") else { return }
      titleLabel.attributedText = day.attributed.add([
        .color(data.isRedOnly ? .bluishGrey: (isSelected ? .white: .gunmetal)),
        .font(.openSans(style: .semiBold(size: 14.0)))])
      titleLabel.alpha = data.isRedOnly ? 0.5: 1.0
      if isSelected || data.isRedOnly {
        availableIndicatorLabel.isHidden = true
      } else {
        availableIndicatorLabel.isHidden = !data.hasAvailableSlots
      }
      isSelectionActive = isSelected
    }
  }
}

// MARK: - CellProtocol
extension BAACalendarCCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 40.0)
  }
}

