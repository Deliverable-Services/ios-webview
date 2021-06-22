//
//  BookAppointmentRequestActionCell.swift
//  Porcelain
//
//  Created by Justine Rangel on 20/10/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class BookAppointmentRequestActionCell: UITableViewCell {
  @IBOutlet weak var requestButton: UIButton!
  
  public var requestDidTapped: VoidCompletion?
  
  public var isEnabled: Bool? {
    didSet {
      updateUI()
    }
  }
  
  private func updateUI() {
    guard let isEnabled = isEnabled else { return }
    requestButton.setAttributedTitle(NSAttributedString(
      content: "REQUEST NOW".localized(),
      font: UIFont.Porcelain.idealSans(14.0, weight: .book),
      foregroundColor: isEnabled ? .white: UIColor.Porcelain.warmGrey,
      paragraphStyle: ParagraphStyle.makeCustomStyle(
        lineHeight: 14.0,
        characterSpacing: 1.0)), for: .normal)
    requestButton.backgroundColor = isEnabled ? UIColor.Porcelain.metallicBlue: UIColor.Porcelain.whiteFour
    requestButton.isUserInteractionEnabled = isEnabled
  }
  
  @IBAction private func requestTapped(_ sender: Any) {
    requestDidTapped?()
  }
}

// MARK: - CellProtocol
extension BookAppointmentRequestActionCell: CellProtocol {
  public static var defaultSize: CGSize {
    return .zero
  }
}
