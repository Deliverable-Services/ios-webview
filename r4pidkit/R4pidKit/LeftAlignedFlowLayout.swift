//
//  LeftAlignedFlowLayout.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 11/29/19.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit

public final class LeftAlignedFlowLayout: UICollectionViewFlowLayout {
  public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let originalAttributes = super.layoutAttributesForElements(in: rect) else {
      return nil
    }
    var leftMargin: CGFloat = 0.0
    var lastY: Int = 0
    return originalAttributes.map {
      let changedAttribute = $0
      // Check if start of a new row.
      // Center Y should be equal for all items on the same row
      if Int(changedAttribute.center.y.rounded()) != lastY {
        leftMargin = sectionInset.left
      }
      changedAttribute.frame.origin.x = leftMargin
      lastY = Int(changedAttribute.center.y.rounded())
      leftMargin += changedAttribute.frame.width + minimumInteritemSpacing
      return changedAttribute
    }
  }
}
