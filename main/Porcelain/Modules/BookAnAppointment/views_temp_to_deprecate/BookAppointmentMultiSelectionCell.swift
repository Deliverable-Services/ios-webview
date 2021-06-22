//
//  BookAppointmentMultiSelectionCell.swift
//  Porcelain
//
//  Created by Justine Rangel on 16/10/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import AlignedCollectionViewFlowLayout
import R4pidKit

public struct BookAppointmentMultiSelectionData {
  var title: String
  var content: String?
  var contents: [String]
  var placeholder: String
  var icon: UIImage?
}

public final class BookAppointmentMultiSelectionCell: UITableViewCell {
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var multiSelectionCollectionView: UICollectionView!
  @IBOutlet private weak var multiSelectionHeightConstraints: NSLayoutConstraint!
  @IBOutlet private weak var textField: UITextField!
  @IBOutlet private weak var iconImageView: UIImageView!
  @IBOutlet private weak var separatorView: UIView!
  
  public var didBeginEditing: VoidCompletion?
  public var didDeleteAtIndex: IntCompletion?
  
  public var data: BookAppointmentMultiSelectionData? {
    didSet {
      guard let data = data else { return }
      titleLabel.attributedText = NSAttributedString(
        content: data.title,
        font: UIFont.Porcelain.openSans(12.0, weight: .semiBold),
        foregroundColor: UIColor.Porcelain.greyishBrown,
        paragraphStyle: ParagraphStyle.makeCustomStyle(
          lineHeight: 18.0,
          characterSpacing: 0.4))
      iconImageView.image = data.icon
      textField.text = ""
      textField.attributedPlaceholder = NSAttributedString(
        content: data.content ?? data.placeholder,
        font: UIFont.Porcelain.openSans(14.0, weight: .regular),
        foregroundColor: UIColor.Porcelain.warmGrey,
        paragraphStyle: ParagraphStyle.makeCustomStyle(
          lineHeight: 14.0,
          characterSpacing: 0.5))
      if !data.contents.isEmpty {
        separatorView.isHidden = true
        titleLabel.isHidden = false
        textField.isHidden = true
        multiSelectionCollectionView.isHidden = false
        reloadData()
        recalculateCollectionViewHeight()
      } else {
        separatorView.isHidden = false
        if data.content != nil {
          titleLabel.isHidden = false
        } else {
          titleLabel.isHidden = true
        }
        textField.isHidden = false
        multiSelectionCollectionView.isHidden = true
        layoutIfNeeded()
      }
    }
  }
  
  private func reloadData() {
    multiSelectionCollectionView.reloadData()
    multiSelectionCollectionView.collectionViewLayout.invalidateLayout()
  }
  
  private func recalculateCollectionViewHeight() {
    layoutIfNeeded()
    let height = multiSelectionCollectionView.collectionViewLayout.collectionViewContentSize.height
    multiSelectionHeightConstraints.constant = height
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    iconImageView.tintColor = UIColor.Porcelain.greyishBrown
    if let alignedCollectionViewFlowLayout = multiSelectionCollectionView.collectionViewLayout as? AlignedCollectionViewFlowLayout {
      alignedCollectionViewFlowLayout.horizontalAlignment = .left
      alignedCollectionViewFlowLayout.verticalAlignment = .center
    }
    multiSelectionCollectionView.setAutomaticDimension()
    if let flowLayout = multiSelectionCollectionView.collectionViewLayout as? UICollectionViewFlowLayout,
      flowLayout.estimatedItemSize != RemovableContentCell.defaultSize {
      flowLayout.estimatedItemSize = RemovableContentCell.defaultSize
    }
    multiSelectionCollectionView.registerWithNib(RemovableContentCell.self)
    multiSelectionCollectionView.dataSource = self
    multiSelectionCollectionView.delegate = self
    let attributes = NSAttributedString.stringAttributesForFont(
      UIFont.Porcelain.openSans(14.0, weight: .regular),
      foregroundColor: UIColor.Porcelain.warmGrey,
      paragraphStyle: ParagraphStyle.makeCustomStyle(
        lineHeight: 14.0,
        characterSpacing: 0.5))
    textField.defaultTextAttributes = attributes
    textField.typingAttributes = attributes
    textField.delegate = self
  }
}

// MARK: - CellProtocol
extension BookAppointmentMultiSelectionCell: CellProtocol {
  public static var defaultSize: CGSize {
    return .zero
  }
}

// MARK: - UITextFieldDelegate
extension BookAppointmentMultiSelectionCell: UITextFieldDelegate {
  public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    didBeginEditing?()
    return false
  }
}

// MARK: - UICollectionViewDataSource
extension BookAppointmentMultiSelectionCell: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return data?.contents.count ?? 0
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let removableCell = collectionView.dequeueReusableCell(RemovableContentCell.self, atIndexPath: indexPath)
    removableCell.title = data?.contents[indexPath.row] ?? ""
    removableCell.deleteDidTapped = { [weak self] in
      guard let `self` = self else { return }
      self.didDeleteAtIndex?(indexPath.row)
    }
    return removableCell
  }
}

// MARK: - UICollectionViewDataSource
extension BookAppointmentMultiSelectionCell: UICollectionViewDelegate {
}

public class RemovableContentCell: UICollectionViewCell {
  @IBOutlet private weak var containerView: DesignableView!
  @IBOutlet private weak var titleLabel: DesignableLabel!
  @IBOutlet private weak var deleteButton: DesignableButton!
  
  public var title: String? {
    didSet {
      guard let title = title else { return }
      titleLabel.attributedText = NSAttributedString(
        content: title,
        font: UIFont.Porcelain.openSans(14.0, weight: .regular),
        foregroundColor: UIColor.Porcelain.whiteTwo,
        paragraphStyle: ParagraphStyle.makeCustomStyle(
          lineHeight: 14.0,
          characterSpacing: 0.5))
      deleteButton.setAttributedTitle(NSAttributedString(
        content: MaterialDesignIcon.close.rawValue,
        font: UIFont.Porcelain.materialDesign(16.0),
        foregroundColor: UIColor.Porcelain.whiteTwo), for: .normal)
    }
  }
  
  public var deleteDidTapped: VoidCompletion?
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    containerView.backgroundColor = UIColor.Porcelain.metallicBlue
  }
  
  public override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    var frame = layoutAttributes.frame
    frame.size.width = titleLabel.getContentHeight(titleLabel.bounds.height) + 46.0
    layoutAttributes.frame = frame
    return layoutAttributes
  }
  
  @IBAction private func deleteTapped(_ sender: Any) {
    deleteDidTapped?()
  }
}

// MARK: - CellProtocol
extension RemovableContentCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 28.0)
  }
}
