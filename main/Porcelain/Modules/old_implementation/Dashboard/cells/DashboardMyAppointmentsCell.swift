//
//  DashboardMyAppointmentsCell.swift
//  Porcelain
//
//  Created by Justine Rangel on 27/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public class DashboardMyAppointmentsCell: UICollectionViewCell, Shadowable {
  public var shadowLayer: CAShapeLayer!
  @IBOutlet private weak var titleLabel: DesignableLabel!
  @IBOutlet private weak var callOutImageView: UIImageView!
  
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    backgroundColor = UIColor.Porcelain.whiteTwo
    titleLabel.attributedText = NSAttributedString(content: "MY APPOINTMENTS".localized(),
                                                   font: UIFont.Porcelain.idealSans(14.0, weight: .book),
                                                   foregroundColor: UIColor.Porcelain.metallicBlue,
                                                   paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 14.0, characterSpacing: 0.5))
    callOutImageView.image = #imageLiteral(resourceName: "arrowRight").withRenderingMode(.alwaysOriginal)
    callOutImageView.tintColor = UIColor.Porcelain.metallicBlue
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    addShadow(color: UIColor.Porcelain.metallicBlue2, opacity: 0.2)
  }
}

// MARK: - CellProtocol
extension DashboardMyAppointmentsCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 50.0)
  }
}
