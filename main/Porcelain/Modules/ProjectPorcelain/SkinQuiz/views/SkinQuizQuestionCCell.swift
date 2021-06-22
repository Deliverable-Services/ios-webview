//
//  SkinQuizQuestionCCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 11/27/19.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct TipsAttributedTextAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? = 0.0
  var alignment: NSTextAlignment? = .center
  var lineBreakMode: NSLineBreakMode? = .byWordWrapping
  var minimumLineHeight: CGFloat? = 20.0
  var font: UIFont? = .idealSans(style: .light(size: 12.0))
  var color: UIColor? = .bluishGrey
}

public protocol SkinQuizQuestionAnswersModelDelegate: class {
  var skinQuizAnswers: [SkinQuizAnwerData] { get set }
  
  func saveAnswers()
}

public final class SkinQuizQuestionCCell: UICollectionViewCell {
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .idealSans(style: .italic(size: 18.0))
      titleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var subtitleLabel: UILabel! {
    didSet {
      subtitleLabel.font = .openSans(style: .regular(size: 12.0))
      subtitleLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var collectionView: UICollectionView! {
    didSet {
      collectionView.registerWithNib(SkinQuizAnswerCCell.self)
      collectionView.allowsMultipleSelection = true
      collectionView.contentInset = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 16.0, right: 0.0)
      collectionView.dataSource = self
      collectionView.delegate = self
    }
  }
  @IBOutlet private weak var tipStack: UIStackView!
  @IBOutlet private weak var tipTitleLabel: UILabel! {
    didSet {
      tipTitleLabel.font = .idealSans(style: .book(size: 14.0))
      tipTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var tipLabel: UILabel!
  
  private var isSelectionEnabled: Bool = true
  private var selectedRows: [Int] {
    guard let questionID = skinQuizQuestion?.id, let answers = skinQuizQuestion?.answers, let skinQuizAnswers = modelDelegate?.skinQuizAnswers else { return [] }
    return answers.enumerated().filter { (_, elem) -> Bool in
      return skinQuizAnswers.contains(where: { $0.questionID == questionID && $0.id == elem.id })
    }.map({ $0.offset })
  }
  private var displayStyle: SkinQuizQuestionDisplayStyle = .singleColumn
  
  public weak var modelDelegate: SkinQuizQuestionAnswersModelDelegate?
  public var skinQuizQuestion: SkinQuizQuestionData? {
    didSet {
      titleLabel.text = skinQuizQuestion?.title
      if let maxSelections = skinQuizQuestion?.maxSelections, maxSelections > 0 {
        if maxSelections == 1 {
          collectionView.allowsMultipleSelection = false
          subtitleLabel.text = "Select up to 1 choice"
        } else {
          collectionView.allowsMultipleSelection = true
          subtitleLabel.text = "Select up to \(maxSelections) choices"
        }
      } else {
        collectionView.allowsMultipleSelection = false
        subtitleLabel.text = "Select up to 1 choice"
      }
      if let tips = skinQuizQuestion?.description, !tips.isEmpty {
        tipLabel.attributedText = tips.attributed.add(.appearance(TipsAttributedTextAppearance()))
        tipStack.isHidden = false
      } else {
        tipStack.isHidden = true
      }
      displayStyle = skinQuizQuestion?.displayStyle ?? .singleColumn
      updateSelectionInteraction()
      collectionView.reloadData()
      selectedRows.forEach { (row) in
        collectionView.selectItem(at: IndexPath(item: row, section: 0), animated: false, scrollPosition: .top)
      }
      collectionView.scrollToTop()
    }
  }
  
  private func reloadUnselectedVisibleCells() {
    updateSelectionInteraction()
    let reloadIndexPaths = collectionView.visibleIndexPaths.filter({ !(collectionView.indexPathsForSelectedItems?.contains($0) ?? false) })
    guard !reloadIndexPaths.isEmpty else { return }
    collectionView.performBatchUpdates({
      collectionView.reloadItems(at: reloadIndexPaths)
    }, completion: { (_) in
    })
  }
  
  private func updateSelectionInteraction() {
    guard let skinQuizQuestion = skinQuizQuestion, let skinQuizAnswers = modelDelegate?.skinQuizAnswers else { return }
    isSelectionEnabled = skinQuizAnswers.filter({ $0.questionID == skinQuizQuestion.id }).count < skinQuizQuestion.maxSelections
  }
}

// MARK: - CellProtocol
extension SkinQuizQuestionCCell: CellProtocol {
}

// MARK: - UICollectionViewDataSource
extension SkinQuizQuestionCCell: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return skinQuizQuestion?.answers?.count ?? 0
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let skinQuizCCell = collectionView.dequeueReusableCell(SkinQuizAnswerCCell.self, atIndexPath: indexPath)
    skinQuizCCell.displayStyle = displayStyle
    skinQuizCCell.isEnabled = isSelectionEnabled
    skinQuizCCell.data = skinQuizQuestion?.answers?[indexPath.row]
    return skinQuizCCell
  }
}

// MARK: - UICollectionViewDelegate
extension SkinQuizQuestionCCell: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let questionID = skinQuizQuestion?.id, var selectedAnswer = skinQuizQuestion?.answers?[indexPath.row] else { return }
    guard let skinQuizAnswers = modelDelegate?.skinQuizAnswers else { return }
    guard !skinQuizAnswers.contains(where: { $0.questionID == questionID && $0.id == selectedAnswer.id }) else { return }
    selectedAnswer.questionID = questionID
    modelDelegate?.skinQuizAnswers.append(selectedAnswer)
    modelDelegate?.saveAnswers()
    reloadUnselectedVisibleCells()
  }
  
  public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    return isSelectionEnabled || !collectionView.allowsMultipleSelection
  }
  
  public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    guard let questionID = skinQuizQuestion?.id, let unselectedAnswer = skinQuizQuestion?.answers?[indexPath.row] else { return }
    guard let indx = modelDelegate?.skinQuizAnswers.firstIndex(where: { $0.questionID == questionID && $0.id == unselectedAnswer.id }) else { return }
    modelDelegate?.skinQuizAnswers.remove(at: indx)
    modelDelegate?.saveAnswers()
    reloadUnselectedVisibleCells()
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SkinQuizQuestionCCell: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    switch displayStyle {
    case .singleColumn:
      return CGSize(width: UIScreen.main.bounds.width - 32.0, height: 80.0)
    case .doubleColumn:
      return CGSize(width: (UIScreen.main.bounds.width - 32.0 - 8.0)/2.0, height: 130.0)
    case .singleRadioColumn, .singleCheckboxColumn:
      return CGSize(width: UIScreen.main.bounds.width - 32.0, height: 24.0)
    }
  }
}
