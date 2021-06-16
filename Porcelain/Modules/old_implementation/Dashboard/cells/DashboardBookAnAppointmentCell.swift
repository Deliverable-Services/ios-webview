//
//  DashboardBookAnAppointmentCell.swift
//  Porcelain
//
//  Created by Justine Rangel on 27/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public class DashboardBookAnAppointmentCell: UICollectionViewCell, Shadowable {
  public var shadowLayer: CAShapeLayer!
  
  @IBOutlet private weak var iconImageView: UIImageView!
  @IBOutlet private weak var titleLabel: DesignableLabel!
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    backgroundColor = UIColor.Porcelain.whiteTwo
    iconImageView.image = #imageLiteral(resourceName: "calendar").withRenderingMode(.alwaysOriginal)
    iconImageView.tintColor = UIColor.Porcelain.metallicBlue
    titleLabel.attributedText = NSAttributedString(content: "BOOK AN APPOINTMENT".localized(),
                                                   font: UIFont.Porcelain.idealSans(14.0, weight: .book),
                                                   foregroundColor: UIColor.Porcelain.metallicBlue,
                                                   paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 14.0, characterSpacing: 0.5))
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    addShadow(color: UIColor.Porcelain.metallicBlue2, opacity: 0.2)
  }
}

// MARK: - CellProtocol
extension DashboardBookAnAppointmentCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 50.0)
  }
}

