//
//  BookAnAppointmentNoteCell.swift
//  Porcelain
//
//  Created by Justine Rangel on 09/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public class BookAnAppointmentNoteCell: UITableViewCell {
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var textView: DesignableTextView!
  @IBOutlet private weak var calloutImageViewContainer: UIView!
  @IBOutlet private weak var calloutImageView: UIImageView!
  
  public var showableDatePicker: UIDatePicker? {
    didSet {
      guard let showableDatePicker = showableDatePicker else { return }
      textView.inputView = showableDatePicker
    }
  }
  
  private var viewModel: BookAnAppointmentCellModelProtocol!
  
  public func configure(viewModel: BookAnAppointmentCellModelProtocol) {
    self.viewModel = viewModel
    
    titleLabel.attributedText = NSAttributedString(content: viewModel.title,
                                                   font: UIFont.Porcelain.idealSans(16.0, weight: .book),
                                                   foregroundColor: UIColor.Porcelain.greyishBrown,
                                                   paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 16.0, characterSpacing: 1.0))
    if let buttonTitle = viewModel.content {
      textView.attributedText = NSAttributedString(content: buttonTitle,
                                                   font: UIFont.Porcelain.openSans(14.0, weight: .regular),
                                                   foregroundColor: UIColor.Porcelain.greyishBrown,
                                                   paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 14.0, characterSpacing: 0.5))
    } else {
      textView.attributedText = NSAttributedString(content: viewModel.placeholder,
                                                   font: UIFont.Porcelain.openSans(14.0, weight: .regular),
                                                   foregroundColor: UIColor.Porcelain.warmGrey,
                                                   paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 14.0, characterSpacing: 0.5))
    }
    
    switch viewModel.calloutType {
    case .action:
      calloutImageViewContainer.isHidden = false
      calloutImageView.image = #imageLiteral(resourceName: "arrowRight").withRenderingMode(.alwaysTemplate)
    case .add:
      calloutImageViewContainer.isHidden = false
      calloutImageView.image = #imageLiteral(resourceName: "plus-icon").withRenderingMode(.alwaysTemplate)
    case .calendar:
      calloutImageViewContainer.isHidden = false
      calloutImageView.image = #imageLiteral(resourceName: "calendar-add").withRenderingMode(.alwaysTemplate)
    case .actionDown:
      calloutImageViewContainer.isHidden = false
      calloutImageView.image = #imageLiteral(resourceName: "arrowDown").withRenderingMode(.alwaysTemplate)
    case .none:
      calloutImageViewContainer.isHidden = true
      calloutImageView.image = nil
    }
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()

    calloutImageView.tintColor = UIColor.Porcelain.greyishBrown
    textView.delegate = self
  }
}

// MARK: - UITextViewDelegate
extension BookAnAppointmentNoteCell: UITextViewDelegate {
  public func textViewDidBeginEditing(_ textView: UITextView) {
    if viewModel.content == nil || viewModel.content == "" || showableDatePicker != nil {
      textView.text = ""
      textView.textColor = UIColor.Porcelain.greyishBrown
    }
  }
  
  public func textViewDidEndEditing(_ textView: UITextView) {
    if viewModel.content == nil || viewModel.content == "" {
      textView.text = viewModel.placeholder
      textView.textColor = UIColor.Porcelain.warmGrey
    }
    
    if showableDatePicker != nil {
      let minDate = showableDatePicker!.date
      let maxDate = minDate.dateByAdding(days: 7)
      viewModel.saveInfo = minDate
      viewModel.content = concatenate(minDate.toString(WithFormat: "MM/dd/YY"), " - ", maxDate.toString(WithFormat: "MM/dd/YY"))
      viewModel.triggerReload()
    }
  }
  
  public func textViewDidChange(_ textView: UITextView) {
    viewModel.content = textView.text
    viewModel.actionTapped()
  }
}

// MARK: - CellProtocol
extension BookAnAppointmentNoteCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 99.0)
  }
}
