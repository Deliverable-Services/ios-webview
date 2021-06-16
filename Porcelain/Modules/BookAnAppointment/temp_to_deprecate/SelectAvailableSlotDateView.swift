//
//  SelectAvailableSlotDateView.swift
//  Porcelain
//
//  Created by Justine Rangel on 23/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public protocol SelectAvailableSlotDateViewModelProtocol {
  var selectedDateSlot: AvailableDateSlot? { get set }
  var availableDateSlots: [AvailableDateSlot] { get }
  func updateAvailableTimeSlots()
}


public class SelectAvailableSlotDateView: UIView, Shadowable {
  public var shadowLayer: CAShapeLayer!
  
  @IBOutlet weak var previousMonthButton: UIButton!
  @IBOutlet weak var monthButton: UIButton!
  @IBOutlet weak var nextMonthButton: UIButton!
  @IBOutlet weak var dateCollectionView: UICollectionView!
  
  fileprivate var selectedDateIndexPath: IndexPath?
  
  fileprivate var viewModel: SelectAvailableSlotDateViewModelProtocol!
  
  public func configure(viewModel: SelectAvailableSlotDateViewModelProtocol) {
    self.viewModel = viewModel
    
    updateUI()
    if let selectedDateSlot = viewModel.selectedDateSlot,
      let selectedRow = viewModel.availableDateSlots.enumerated().filter({ $0.element == selectedDateSlot }).map({ $0.offset }).first {
      DispatchQueue.main.async {
        self.dateCollectionView.selectItem(at: IndexPath(row: selectedRow, section: 0), animated: false, scrollPosition: .centeredHorizontally)
      }
    }
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    addShadow()
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    dateCollectionView.backgroundColor = .clear
    dateCollectionView.dataSource = self
    dateCollectionView.delegate = self
  }
  
  deinit {
    debugPrint("deinit SelectAvailableSlotDateView")
  }
  
  @IBAction private func prevMonthTapped(_ sender: Any) {
    let newDateSlot = viewModel.selectedDateSlot!.dateSlot.dateByAdding(months: -1)
    viewModel.selectedDateSlot!.dateSlot = newDateSlot
    viewModel.updateAvailableTimeSlots()
    updateUI()
  }
  
  @IBAction private func nextMonthTapped(_ sender: Any) {
    let newDateSlot = viewModel.selectedDateSlot!.dateSlot.dateByAdding(months: 1)
    viewModel.selectedDateSlot!.dateSlot = newDateSlot
    viewModel.updateAvailableTimeSlots()
    updateUI()
  }
  
  private func updateUI() {
    let month = viewModel.selectedDateSlot!.dateSlot.toString(WithFormat: "MMMM yyyy").uppercased()
    monthButton.setAttributedTitle(NSAttributedString(content: month,
                                                      font: UIFont.Porcelain.idealSans(15.0, weight: .book),
                                                      foregroundColor: UIColor.Porcelain.whiteTwo,
                                                      paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 15.0, characterSpacing: 0.5)), for: .normal)
    dateCollectionView.reloadData()
  }
}

// MARK: - UICollectionViewDataSource
extension SelectAvailableSlotDateView: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.availableDateSlots.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let selectAvailableSlotDateCell = collectionView.dequeueReusableCell(SelectAvailableSlotDateCell.self, atIndexPath: indexPath)
    selectAvailableSlotDateCell.availableDateSlot = viewModel.availableDateSlots[indexPath.row]
    return selectAvailableSlotDateCell
  }
}

// MARK: - UICollectionViewDelegate
extension SelectAvailableSlotDateView: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    selectedDateIndexPath = indexPath
    let selectedDateSlot = viewModel.availableDateSlots[indexPath.row]
    viewModel.selectedDateSlot = selectedDateSlot
  }
  
  public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    let isAvailable = viewModel.availableDateSlots[indexPath.row].isAvailable
    if let selectedIndexPath = selectedDateIndexPath, !isAvailable {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .top)
      }
    }
    return isAvailable
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SelectAvailableSlotDateView: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return SelectAvailableSlotDateCell.defaultSize
  }
}

public class SelectAvailableSlotDateCell: UICollectionViewCell {
  public var shadowLayer: CAShapeLayer!
  
  @IBOutlet weak var dayLabel: UILabel!
  @IBOutlet weak var numericDayLabel: UILabel!
  
  
  public var availableDateSlot: AvailableDateSlot? {
    didSet {
      dayLabel.text = availableDateSlot?.dateSlot.toString(WithFormat: "E").uppercased()
      numericDayLabel.text = availableDateSlot?.dateSlot.toString(WithFormat: "dd")
      if let isAvailable = availableDateSlot?.isAvailable, !isAvailable {
        dayLabel.textColor = UIColor(hex: 0x909090)
        numericDayLabel.textColor = UIColor(hex: 0x909090)
        backgroundColor = .clear
      } else {
        backgroundColor = .white
        updateSelectionIsSelected(isSelected)
      }
    }
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    dayLabel.font = UIFont.Porcelain.idealSans(12.0, weight: .book)
    numericDayLabel.font = UIFont.Porcelain.idealSans(15.0, weight: .book)
  }
  
  deinit {
    debugPrint("deinit SelectAvailableSlotDateCell")
  }
  
  public override var isSelected: Bool {
    didSet {
      updateSelectionIsSelected(isSelected)
    }
  }
  
  private func updateSelectionIsSelected(_ isSelected: Bool) {
    guard let isAvailable = availableDateSlot?.isAvailable, isAvailable else { return }
    dayLabel.textColor = isSelected ? .white: UIColor.Porcelain.greyishBrown
    numericDayLabel.textColor = isSelected ? .white: UIColor.Porcelain.greyishBrown
    backgroundColor = isSelected ? UIColor.Porcelain.blueGrey: .white
  }
}

extension SelectAvailableSlotDateCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 48.0, height: 48.0)
  }
}
