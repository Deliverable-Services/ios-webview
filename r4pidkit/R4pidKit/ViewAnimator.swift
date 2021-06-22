//
//  ViewAnimator.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 01/08/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
  public func addBounceAnimate() {
    UIView.animate(withDuration: 0.15, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
      self.transform = .init(scaleX: 0.9, y: 0.9)
    }) { (_) in
      UIView.animate(withDuration: 0.15, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
        self.transform = .init(scaleX: 1.0, y: 1.0)
      }) { (_) in
      }
    }
  }
}
