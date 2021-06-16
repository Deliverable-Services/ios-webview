//
//  BookAppointmentCalendarCell.swift
//  Porcelain
//
//  Created by Justine Rangel on 18/10/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
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
}

public struct BookAppointmentCalendarData {
  var calendarReferenceDate: Date
  var selectedCalendarReferenceDate: Date?
}

public final class BookAppointmentCalendarCell: UITableViewCell {
  @IBOutlet private weak var containerView: DesignableView!
  @IBOutlet private weak var prevButton: UIButton!
  @IBOutlet private weak var monthLabel: UILabel!
  @IBOutlet private weak var nextButton: UIButton!
  @IBOutlet private weak var daysCollectionView: UICollectionView!
  @IBOutlet private weak var calendarHeightConstraint: NSLayoutConstraint!
  
  public var prevDidTapped: VoidCompletion?
  public var nextDidTapped: VoidCompletion?
  public var didSelectDate: ((Date?) -> ())?
  
  public var calendarImage: UIImage? {
    return UIImage.makeFromView(containerView)
  }
  
  public var dates: [Date] = []
  public var selectableDates: [Date] = []

  public var data: BookAppointmentCalendarData? {
    didSet {
      guard let data = data else { return }
      let month = data.calendarReferenceDate.toString(WithFormat: "MMMM YYYY").uppercased()
      monthLabel.attributedText = NSAttributedString(
        content: month,
        font: UIFont.Porcelain.openSans(16.0, weight: .semiBold),
        foregroundColor: UIColor.Porcelain.greyishBrown,
        paragraphStyle: ParagraphStyle.makeCustomStyle(
          lineHeight: 16.0,
          characterSpacing: 0.5,
          alignment: .center))
      dates = []
      selectableDates = []
      let firstDayOfTheMonth = data.calendarReferenceDate.startOfMonth()
      let firstWeekDayInt = Calendar.current.component(.weekday, from: firstDayOfTheMonth)
      let firstWeekDayDiff = 1 - firstWeekDayInt
      var startDateEnumerator = firstDayOfTheMonth.dateByAdding(days: firstWeekDayDiff)
      let lastDayOfTheMonth = data.calendarReferenceDate.endOfMonth()
      let lastWeekDayInt = Calendar.current.component(.weekday, from: lastDayOfTheMonth)
      let lastWeekDayDiff = 7 - lastWeekDayInt
      let endDateEnumerator = lastDayOfTheMonth.dateByAdding(days: lastWeekDayDiff)
      while startDateEnumerator <= endDateEnumerator {
        dates.append(startDateEnumerator)
        if startDateEnumerator > Date().dateByAdding(days: -1) &&
          startDateEnumerator >= firstDayOfTheMonth &&
          startDateEnumerator <= lastDayOfTheMonth {
          selectableDates.append(startDateEnumerator)
        }
        startDateEnumerator = startDateEnumerator.dateByAdding(days: 1)
      }

      daysCollectionView.reloadData()
      updateSelectionIfNeeded()
      updateCalendarConstraints()
    }
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    prevButton.setAttributedTitle(NSAttributedString(
      content: MaterialDesignIcon.chevronLeft.rawValue,
      font: UIFont.Porcelain.materialDesign(22.0),
      foregroundColor: UIColor.Porcelain.greyishBrown), for: .normal)
    nextButton.setAttributedTitle(NSAttributedString(
      content: MaterialDesignIcon.chevronRight.rawValue,
      font: UIFont.Porcelain.materialDesign(22.0),
      foregroundColor: UIColor.Porcelain.greyishBrown), for: .normal)
    daysCollectionView.registerWithNib(BookAppointmentCalendarItemCell.self)
    daysCollectionView.dataSource = self
    daysCollectionView.delegate = self
  }
  
  private func updateSelectionIfNeeded() {
    if let selectedDate = data?.selectedCalendarReferenceDate {
      if let selectedRow = dates.index(where: { $0 == selectedDate }) {
        DispatchQueue.main.async {
          self.daysCollectionView.selectItem(
            at: IndexPath(row: selectedRow, section: 1),
            animated: false,
            scrollPosition: .centeredHorizontally)
        }
      }
    } else {
      if let selectedIndex = self.daysCollectionView.indexPathsForSelectedItems?.first {
        DispatchQueue.main.async {
          self.daysCollectionView.deselectItem(
            at: selectedIndex,
            animated: false)
        }
      }
    }
  }
  
  private func updateCalendarConstraints() {
    calendarHeightConstraint.constant = (BookAppointmentCalendarItemCell.defaultSize.height * (CGFloat(ceil(Double(dates.count)/7)) + 1)) + 20.0
  }
  
  @IBAction func prevTapped(_ sender: Any) {
    prevDidTapped?()
  }
  
  @IBAction func nextTapped(_ sender: Any) {
    nextDidTapped?()
  }
}

// MARK: - CellProtocol
extension BookAppointmentCalendarCell: CellProtocol {
  public static var defaultSize: CGSize {
    return .zero
  }
}

// MARK: - UICollectionViewDataSource
extension BookAppointmentCalendarCell: UICollectionViewDataSource {
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 2
  }

  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if section == 0 {
      return 7 //Week days
    } else {
      return dates.count
    }
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let bookAppointmentCalendarItemCell = collectionView.dequeueReusableCell(BookAppointmentCalendarItemCell.self, atIndexPath: indexPath)
    if indexPath.section == 0 {
      bookAppointmentCalendarItemCell.data = BookAppointmentCalendarItemData(
        content: WeekDays(rawValue: indexPath.row)!.code,
        isWeekDays: true,
        isSelectable: false,
        date: nil)
    } else {
      
      let date = dates[indexPath.row]
      bookAppointmentCalendarItemCell.data = BookAppointmentCalendarItemData(
        content: date.toString(WithFormat: "d"),
        isWeekDays: false,
        isSelectable: selectableDates.contains(date),
        date: date)
    }
    return bookAppointmentCalendarItemCell
  }
}

// MARK: - UICollectionViewDelegate
extension BookAppointmentCalendarCell: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let bookAppointmentCalendarItemCell = collectionView.cellForItem(at: indexPath) as? BookAppointmentCalendarItemCell else { return }
    guard let data = bookAppointmentCalendarItemCell.data else { return }
    guard let date = data.date, data.isSelectable else {
      updateSelectionIfNeeded()
      return
    }
    didSelectDate?(date)
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension BookAppointmentCalendarCell: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.bounds.width/7.1, height: BookAppointmentCalendarItemCell.defaultSize.height)
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    if section == 0 {
      return .zero
    } else {
      return CGSize(width: collectionView.bounds.width, height: 10.0)
    }
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    if section == 0 {
      return CGSize(width: collectionView.bounds.width, height: 10.0)
    } else {
      return .zero
    }
  }
}

public struct BookAppointmentCalendarItemData {
  var content: String
  var isWeekDays: Bool
  var isSelectable: Bool
  var date: Date?
}

public final class BookAppointmentCalendarItemCell: UICollectionViewCell {
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var selectionIndicatorView: DesignableView!
  
  public var data: BookAppointmentCalendarItemData? {
    didSet {
      guard let data = data else { return }
      if data.isWeekDays {
        titleLabel.attributedText = NSAttributedString(
          content: data.content,
          font: UIFont.Porcelain.openSans(14.0, weight: .semiBold),
          foregroundColor: UIColor.Porcelain.greyishBrown,
          paragraphStyle: ParagraphStyle.makeCustomStyle(
            lineHeight: 14.0,
            characterSpacing: 0.5,
            alignment: .center))
        selectionIndicatorView.backgroundColor = .clear
      } else {
        updateSelection()
      }
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
    guard let data = data, !data.isWeekDays else { return }
    selectionIndicatorView.backgroundColor = isSelected ? UIColor.Porcelain.metallicBlue: .clear
    titleLabel.attributedText = NSAttributedString(
      content: data.content,
      font: UIFont.Porcelain.openSans(14.0, weight: .semiBold),
      foregroundColor: isSelected ? .white: (data.isSelectable ? UIColor.Porcelain.warmGrey: UIColor.Porcelain.lightGrey),
      paragraphStyle: ParagraphStyle.makeCustomStyle(
        lineHeight: 14.0,
        characterSpacing: 0.5,
        alignment: .center))
  }
}

// MARK: - CellProtocol
extension BookAppointmentCalendarItemCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 40.0)
  }
}
