//
//  CenteredCollectionView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 27/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import CenteredCollectionView

@IBDesignable
public class CenteredCollectionView: UICollectionView {
  @IBInspectable
  public var sidePadding: CGFloat = 8.0
  
  @IBInspectable
  public var itemSpacing: CGFloat = 8.0
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    let layout = CenteredCollectionViewFlowLayout()
    layout.itemSize = CGSize(width: rect.width - (sidePadding * 2.0), height: rect.height)
    layout.minimumInteritemSpacing = itemSpacing
    layout.minimumLineSpacing = itemSpacing
    collectionViewLayout = layout
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    isPagingEnabled = false
    decelerationRate = UIScrollViewDecelerationRateFast
  }
}
