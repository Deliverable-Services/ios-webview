//
//  MyTreatmentsItemCell.swift
//  Porcelain
//
//  Created by Justine Rangel on 14/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public protocol MyTreatmentsItemViewModelProtocol {
  var title: String { get }
  var imageURL: String? { get }
  var description: String? { get }
  var frequencyDescription: String? { get }
  var tipsDescription: String? { get }
}

public class MyTreatmentsItemCell: UICollectionViewCell {
  @IBOutlet private weak var _contentView: DesignableView!
  @IBOutlet private weak var productTitleLabel: UILabel!
  @IBOutlet private weak var productImageView: UIImageView!
  @IBOutlet private weak var descriptionLabel: UILabel!
  @IBOutlet private weak var frequencyStack: UIView!
  @IBOutlet private weak var frequencyTitleLabel: UILabel!
  @IBOutlet private weak var frequencyDescriptionLabel: UILabel!
  @IBOutlet private weak var tipsStack: UIView!
  @IBOutlet private weak var tipsTitleLabel: UILabel!
  @IBOutlet private weak var tipsDescriptionLabel: UILabel!
  
  public func configure(viewModel: MyTreatmentsItemViewModelProtocol) {
    productTitleLabel.attributedText = NSAttributedString(content: viewModel.title,
                                                          font: UIFont.Porcelain.idealSans(18.0, weight: .book),
                                                          foregroundColor: UIColor.Porcelain.greyishBrown,
                                                          paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 26.0, characterSpacing: 0.6))
    productImageView.image = #imageLiteral(resourceName: "sample-porcelein")
    if let description = viewModel.description {
      descriptionLabel.isHidden = false
      descriptionLabel.attributedText = NSAttributedString(content: description,
                                                           font: UIFont.Porcelain.idealSans(14.0, weight: .book),
                                                           foregroundColor: UIColor.Porcelain.warmGrey,
                                                           paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 24.0, characterSpacing: 0.2))
    } else {
      descriptionLabel.isHidden = true
    }
    if let frequencyDescription = viewModel.frequencyDescription {
      frequencyStack.isHidden = false
      frequencyDescriptionLabel.attributedText = NSAttributedString(content: frequencyDescription,
                                                                    font: UIFont.Porcelain.idealSans(14.0, weight: .book),
                                                                    foregroundColor: UIColor.Porcelain.warmGrey,
                                                                    paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 24.0, characterSpacing: 0.2))
    } else {
      frequencyStack.isHidden = true
    }
    if let tipsDescription = viewModel.tipsDescription {
      tipsStack.isHidden = false
      tipsDescriptionLabel.attributedText = NSAttributedString(content: tipsDescription,
                                                               font: UIFont.Porcelain.idealSans(14.0, weight: .book),
                                                               foregroundColor: UIColor.Porcelain.warmGrey,
                                                               paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 24.0, characterSpacing: 0.2))
    } else {
      tipsStack.isHidden = true
    }
  }
  
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    _contentView.addShadow()
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()

    frequencyTitleLabel.attributedText = NSAttributedString(content: "Frequency:",
                                                            font: UIFont.Porcelain.idealSans(14.0, weight: .book),
                                                            foregroundColor: UIColor.Porcelain.warmGrey,
                                                            paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 24.0, characterSpacing: 0.2))
    tipsTitleLabel.attributedText = NSAttributedString(content: "Skin Tips:",
                                                       font: UIFont.Porcelain.idealSans(14.0, weight: .book),
                                                       foregroundColor: UIColor.Porcelain.warmGrey,
                                                       paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 24.0, characterSpacing: 0.2))
  }
}

extension MyTreatmentsItemCell: CellProtocol {
  public static var defaultSize: CGSize {
    return .zero
  }
}
