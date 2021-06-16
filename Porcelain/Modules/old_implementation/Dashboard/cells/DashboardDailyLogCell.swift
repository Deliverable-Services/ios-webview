//
//  DashboardDailyLogCell.swift
//  Porcelain
//
//  Created by Justine Rangel on 26/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import UICircularProgressRing
import R4pidKit

public protocol DashboardDailyLogViewModelProtocol {
  var dailyLogProgress: Float { get }
}

public class DashboardDailyLogCell: UICollectionViewCell, Shadowable {
  public var shadowLayer: CAShapeLayer!
  
  @IBOutlet private weak var titleLabel: DesignableLabel!
  @IBOutlet private weak var progressRing: UICircularProgressRing!
  @IBOutlet private weak var comingSoonLabel: DesignableLabel!
  
  public func configure(viewModel: DashboardDailyLogViewModelProtocol) {
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    addShadow(color: UIColor.Porcelain.metallicBlue2, opacity: 0.2)
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    backgroundColor = .clear
    titleLabel.attributedText = NSAttributedString(content: "DAILY LOG".localized(),
                                                   font: UIFont.Porcelain.idealSans(16.0, weight: .book),
                                                   foregroundColor: UIColor.Porcelain.warmGrey,
                                                   paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 16.0, characterSpacing: 0.5, alignment: .center))
    progressRing.font = UIFont.Porcelain.openSans(18.0, weight: .semiBold)
    progressRing.fontColor = UIColor.Porcelain.metallicBlue
    comingSoonLabel.attributedText = NSAttributedString(content: "COMING SOON".localized(),
                                                        font: UIFont.Porcelain.openSans(16.0, weight: .semiBold),
                                                        foregroundColor: UIColor.Porcelain.warmGrey,
                                                        paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 16.0, characterSpacing: 1.0, alignment: .center))
  }
}

// MARK: - CellProtocol
extension DashboardDailyLogCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 184.0)
  }
}
