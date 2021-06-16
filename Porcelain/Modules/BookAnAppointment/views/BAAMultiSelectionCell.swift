//
//  BAAMultiSelectionCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 22/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class BAAMultiSelectionCell: UICollectionViewCell {
  @IBOutlet private weak var containerView: DesignableView! {
    didSet {
      containerView.cornerRadius = BAAMultiSelectionCell.defaultSize.height/2.0
      containerView.backgroundColor = .lightNavy
    }
  }
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .regular(size: 14.0))
      titleLabel.textColor = .white
    }
  }
  @IBOutlet private weak var deleteButton: UIButton! {
    didSet {
      deleteButton.setAttributedTitle(
        MaterialDesignIcon.close.attributed.add([
          .color(.white),
          .font(.materialDesign(size: 14.0))]),
        for: .normal)
    }
  }
  
  public var data: BAAMultiSelectionData? {
    didSet {
      titleLabel.text = data?.title
    }
  }
  
  public var deleteDidTapped: ((BAAMultiSelectionData) -> Void)?
  
  public override func preferredLayoutAttributesFitting(
    _ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    var frame = layoutAttributes.frame
    frame.size.height = 28.0
    frame.size.width = 14.0 + titleLabel.getContentWidth(maxHeight: 28.0) + 28.0 + 4.0
    layoutAttributes.frame = frame
    return layoutAttributes
  }
  
  @IBAction private func deleteTapped(_  sender: Any) {
    guard let data = data else { return }
    deleteDidTapped?(data)
  }
}

// MARK: - CellProtocol
extension BAAMultiSelectionCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 28.0)
  }
}
