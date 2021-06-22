//
//  MarginLabel.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 17/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit

public final class MarginLabel: UILabel {
  public var edgeInsets: UIEdgeInsets = .zero
  
  public override func drawText(in rect: CGRect) {
    super.drawText(in: rect.inset(by: edgeInsets))
  }
}
