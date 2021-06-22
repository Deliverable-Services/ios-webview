//
//  DashboardMyProductsCell.swift
//  Porcelain
//
//  Created by Justine Rangel on 26/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public class DashboardMyProductsCell: UICollectionViewCell, Shadowable {
  public var shadowLayer: CAShapeLayer!
  
  @IBOutlet private weak var titleLabel: DesignableLabel!
  @IBOutlet private weak var imageView: UIImageView!
 
  var title: String = "" {
    didSet {
      titleLabel.attributedText = NSAttributedString(content: title.localized(),
                                                     font: UIFont.Porcelain.idealSans(16.0, weight: .book),
                                                     foregroundColor: UIColor.Porcelain.metallicBlue,
                                                     paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 16.0, characterSpacing: 0.5, alignment: .center))
    }
  }
  
  var image: UIImage! {
    didSet {
      imageView.image = image
    }
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    addShadow(color: UIColor.Porcelain.metallicBlue2, opacity: 0.2)
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    backgroundColor = .clear
    
    
  }
}

// MARK: - CellProtocol
extension DashboardMyProductsCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 184.0)
  }
}
