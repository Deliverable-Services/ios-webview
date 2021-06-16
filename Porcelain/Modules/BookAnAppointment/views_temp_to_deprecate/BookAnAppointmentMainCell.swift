//
//  BookAnAppointmentMainCell.swift
//  Porcelain
//
//  Created by Justine Rangel on 09/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public class BookAnAppointmentMainCell: UITableViewCell {
  @IBOutlet private weak var contentStack: UIStackView!
  
  @IBOutlet private weak var calloutView: UIView!
  @IBOutlet private weak var calloutButton: UIButton!
  
  @IBOutlet private weak var _contentView: UIView!
  @IBOutlet private weak var contentTitleLabel: UILabel!
  @IBOutlet private weak var contentSubtitleLabel: UILabel!
  
  @IBOutlet private weak var subContentView: UIView!
  @IBOutlet private weak var subContentTitleLabel: UILabel!
  @IBOutlet private weak var subContentSubtitleLabel: UILabel!
  
  private var viewModel: BookAnAppointmentCellModelProtocol!
  
  public func configure(viewModel: BookAnAppointmentCellModelProtocol) {
    self.viewModel = viewModel
    if let content = viewModel.content, let subContent = viewModel.subcontent {
      calloutView.isHidden = true
      _contentView.isHidden = false
      subContentView.isHidden = true
      contentTitleLabel.text = content
      contentSubtitleLabel.text = subContent
    } else if let content = viewModel.content, let info = viewModel.info, let subInfo = viewModel.subInfo {
      calloutView.isHidden = false
      _contentView.isHidden = true
      subContentView.isHidden = false
      calloutButton.setTitle(content, for: .normal)
      calloutButton.setTitleColor(UIColor.Porcelain.greyishBrown, for: .normal)
      subContentTitleLabel.text = info
      subContentSubtitleLabel.text = subInfo
    } else if let content = viewModel.content {
      calloutView.isHidden = false
      _contentView.isHidden = true
      subContentView.isHidden = true
      calloutButton.setTitle(content, for: .normal)
      calloutButton.setTitleColor(UIColor.Porcelain.greyishBrown, for: .normal)
    } else {
      calloutView.isHidden = false
      _contentView.isHidden = true
      subContentView.isHidden = true
      calloutButton.setTitle(viewModel.placeholder, for: .normal)
      calloutButton.setTitleColor(UIColor(hex: 0x909090), for: .normal)
    }
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    contentTitleLabel.font = UIFont.Porcelain.idealSans(18.0, weight: .book)
    contentTitleLabel.textColor = UIColor.Porcelain.greyishBrown
    contentSubtitleLabel.font = UIFont.Porcelain.idealSans(14.0, weight: .book)
    contentSubtitleLabel.textColor = UIColor.Porcelain.greyishBrown
    
    subContentTitleLabel.font = UIFont.Porcelain.idealSans(18.0, weight: .book)
    subContentTitleLabel.textColor = UIColor.Porcelain.greyishBrown
    subContentSubtitleLabel.font = UIFont.Porcelain.idealSans(13.0, weight: .book)
    subContentSubtitleLabel.textColor = UIColor.Porcelain.greyishBrown
  }
  
  @IBAction func calloutTapped(_ sender: Any) {
    viewModel.actionTapped()
  }
}

extension BookAnAppointmentMainCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 117.0)
  }
}
