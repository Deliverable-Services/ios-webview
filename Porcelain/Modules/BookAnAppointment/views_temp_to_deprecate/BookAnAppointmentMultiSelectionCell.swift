//
//  BookAnAppointmentMultiSelectionCell.swift
//  Porcelain
//
//  Created by Justine Rangel on 30/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import AlignedCollectionViewFlowLayout
import R4pidKit

public class BookAnAppointmentMultiSelectionCell: UITableViewCell {
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var calloutButton: DesignableButton!
  @IBOutlet private weak var calloutImageView: UIImageView!
  @IBOutlet private weak var subInfoContainerView: UIView!
  @IBOutlet private weak var subInfoLabel: DesignableLabel!
  @IBOutlet private weak var selectedObjectsCollectionView: UICollectionView!
  @IBOutlet private weak var selectedObjectCollectionViewHeightConstraint: NSLayoutConstraint!
  
  fileprivate var viewModel: BookAnAppointmentCellModelProtocol!
  
  public func configure(viewModel: BookAnAppointmentCellModelProtocol) {
    self.viewModel = viewModel
    titleLabel.attributedText = NSAttributedString(content: viewModel.title,
                                                   font: UIFont.Porcelain.idealSans(16.0, weight: .book),
                                                   foregroundColor: UIColor.Porcelain.greyishBrown,
                                                   paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 16.0, characterSpacing: 1.0))
    if let buttonTitle = viewModel.content {
      calloutButton.setAttributedTitle(NSAttributedString(content: buttonTitle,
                                                          font: UIFont.Porcelain.openSans(14.0, weight: .regular),
                                                          foregroundColor: UIColor.Porcelain.greyishBrown,
                                                          paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 14.0, characterSpacing: 0.5)), for: .normal)
    } else {
      calloutButton.setAttributedTitle(NSAttributedString(content: viewModel.placeholder,
                                                          font: UIFont.Porcelain.openSans(14.0, weight: .regular),
                                                          foregroundColor: UIColor.Porcelain.warmGrey,
                                                          paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 14.0, characterSpacing: 0.5)), for: .normal)
    }
    if let subcontent = viewModel.subcontent {
      subInfoContainerView.isHidden = false
      subInfoLabel.attributedText = NSAttributedString(content: subcontent,
                                                       font: UIFont.Porcelain.idealSans(14.0, weight: .book),
                                                       foregroundColor: UIColor.Porcelain.greyishBrown,
                                                       paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 14.0, characterSpacing: 0.5))
    } else {
      subInfoContainerView.isHidden = true
    }
    switch viewModel.calloutType {
    case .action:
      calloutImageView.image = #imageLiteral(resourceName: "arrowRight").withRenderingMode(.alwaysTemplate)
    case .add:
      calloutImageView.image = #imageLiteral(resourceName: "plus-icon").withRenderingMode(.alwaysTemplate)
    case .calendar:
      calloutImageView.image = #imageLiteral(resourceName: "calendar-add").withRenderingMode(.alwaysTemplate)
    case .actionDown:
      calloutImageView.image = #imageLiteral(resourceName: "arrowDown").withRenderingMode(.alwaysTemplate)
    case .none:
      calloutImageView.image = nil
    }
    
    if !viewModel.multiSelectedObjects.isEmpty {
      calloutButton.isHidden = true
      selectedObjectsCollectionView.isHidden = false
      reloadData()
      recalculateCollectionViewHeight()
    } else {
      calloutButton.isHidden = false
      selectedObjectsCollectionView.isHidden = true
    }
  }
  
  private func reloadData() {
    selectedObjectsCollectionView.reloadData()
    selectedObjectsCollectionView.collectionViewLayout.invalidateLayout()
  }
  
  private func recalculateCollectionViewHeight() {
    layoutIfNeeded()
    let height = selectedObjectsCollectionView.collectionViewLayout.collectionViewContentSize.height
    selectedObjectCollectionViewHeightConstraint.constant = height
  }
  
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    if let alignedCollectionViewFlowLayout = selectedObjectsCollectionView.collectionViewLayout as? AlignedCollectionViewFlowLayout {
      alignedCollectionViewFlowLayout.horizontalAlignment = .left
      alignedCollectionViewFlowLayout.verticalAlignment = .center
    }
    selectedObjectsCollectionView.setAutomaticDimension()
    selectedObjectsCollectionView.registerWithNib(RemovableContentCell.self)
    selectedObjectsCollectionView.dataSource = self
    selectedObjectsCollectionView.delegate = self
    calloutImageView.tintColor = UIColor.Porcelain.greyishBrown
  }
  
  @IBAction private func calloutTapped(_ sender: Any) {
    viewModel.actionTapped()
  }
}

// MARK: - CellProtocol
extension BookAnAppointmentMultiSelectionCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 99.0)
  }
}

// MARK: - UICollectionViewDataSource
extension BookAnAppointmentMultiSelectionCell: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.multiSelectedObjects.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let removableCell = collectionView.dequeueReusableCell(RemovableContentCell.self, atIndexPath: indexPath)
    removableCell.title = viewModel.multiSelectedObjects[indexPath.row].title
    removableCell.deleteDidTapped = { [weak self] in
      guard let `self` = self else { return }
      self.viewModel.multiSelectedObjects.remove(at: indexPath.row)
      let newTherapistsIDs = self.viewModel.multiSelectedObjects.map({ $0.id }).joined(separator: ",")
      self.viewModel.saveInfo = newTherapistsIDs.isEmpty ? nil: newTherapistsIDs
      self.viewModel.triggerReload()
    }
    return removableCell
  }
}

// MARK: - UICollectionViewDataSource
extension BookAnAppointmentMultiSelectionCell: UICollectionViewDelegate {
  
}
