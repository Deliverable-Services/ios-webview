//
//  BookAnAppointmentActionCell.swift
//  Porcelain
//
//  Created by Justine Rangel on 09/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public class BookAnAppointmentActionCell: UITableViewCell {
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var calloutButton: DesignableButton!
  @IBOutlet private weak var calloutImageView: UIImageView!
  
  private var viewModel: BookAnAppointmentCellModelProtocol!
  
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
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()

    calloutImageView.tintColor = UIColor.Porcelain.greyishBrown
  }
  
  @IBAction private func calloutTapped(_ sender: Any) {
    viewModel.actionTapped()
  }
}

extension BookAnAppointmentActionCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 99.0)
  }
}
