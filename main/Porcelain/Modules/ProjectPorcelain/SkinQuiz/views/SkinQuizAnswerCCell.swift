//
//  SkinQuizAnswerCCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 11/26/19.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class SkinQuizAnswerCCell: UICollectionViewCell {
  @IBOutlet private weak var contentStack: UIStackView!
  @IBOutlet private weak var specialImageView: UIImageView!
  @IBOutlet private weak var selectionView: DesignableView! {
    didSet {
      selectionView.cornerRadius = 40.0
      selectionView.borderColor = .greyblue
    }
  }
  @IBOutlet private weak var imageView: LoadingImageView! {
    didSet {
      imageView.cornerRadius = 36.0
    }
  }
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .idealSans(style: .book(size: 14.0))
      titleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var descriptionLabel: UILabel! {
    didSet {
      descriptionLabel.font = .openSans(style: .regular(size: 12.0))
      descriptionLabel.textColor = .bluishGrey
    }
  }
  
  public var data: SkinQuizAnwerData? {
    didSet {
      imageView.url = data?.image
      titleLabel.text = data?.title
      descriptionLabel.text = data?.description
      updateSelection()
    }
  }
  
  public var displayStyle: SkinQuizQuestionDisplayStyle = .singleColumn {
    didSet {
      switch displayStyle {
      case .singleColumn:
        specialImageView.isHidden = true
        selectionView.isHidden = false
        contentStack.spacing = 8.0
        contentStack.axis = .horizontal
        titleLabel.textAlignment = .left
        descriptionLabel.textAlignment = .left
      case .doubleColumn:
        specialImageView.isHidden = true
        selectionView.isHidden = false
        contentStack.spacing = 4.0
        contentStack.axis = .vertical
        titleLabel.textAlignment = .center
        descriptionLabel.textAlignment = .center
      case .singleRadioColumn:
        specialImageView.isHidden = false
        selectionView.isHidden = true
        contentStack.spacing = 8.0
        contentStack.axis = .horizontal
        titleLabel.textAlignment = .left
        descriptionLabel.textAlignment = .left
      case .singleCheckboxColumn:
        specialImageView.isHidden = false
        selectionView.isHidden = true
        contentStack.spacing = 8.0
        contentStack.axis = .horizontal
        titleLabel.textAlignment = .left
        descriptionLabel.textAlignment = .left
      }
    }
  }
  
  public var isEnabled: Bool = false {
    didSet {
      switch displayStyle {
      case .singleColumn, .doubleColumn:
        selectionView.borderWidth = isSelected ? 2.0: 0.0
        imageView.alpha = (isEnabled || isSelected) ? 1.0: 0.4
      case .singleRadioColumn: break
      case .singleCheckboxColumn: break
      }
    }
  }
  
  public override var isSelected: Bool {
    didSet {
      updateSelection()
    }
  }
  
  private func updateSelection() {
    switch displayStyle {
    case .singleColumn, .doubleColumn:
      selectionView.borderWidth = isSelected ? 2.0: 0.0
      imageView.alpha = (isEnabled || isSelected) ? 1.0: 0.4
    case .singleRadioColumn:
      specialImageView.image = isSelected ? UIImage.icRadioSelected: UIImage.icRadioUnselected
    case .singleCheckboxColumn:
      specialImageView.image = isSelected ? UIImage.icCheckBoxSelected: UIImage.icCheckBoxUnSelected
    }
  }
}

// MARK: - CellProtocol
extension SkinQuizAnswerCCell: CellProtocol {
}
