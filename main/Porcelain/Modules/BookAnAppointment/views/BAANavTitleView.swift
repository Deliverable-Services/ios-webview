//
//  BAANavTitleView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 22/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import MarqueeLabel

public final class BAANavTitleView: UIView {
  @IBOutlet private weak var centerButton: UIButton!
  @IBOutlet private weak var subtitleLabel: MarqueeLabel! {
    didSet {
      subtitleLabel.type = .rightLeft
      subtitleLabel.font = .openSans(style: .regular(size: 12.0))
      subtitleLabel.textColor = .bluishGrey
    }
  }
  
  public var isWalkthrough: Bool = false
  public var isSelected: Bool = false {
    didSet {
      updateCenterButton()
    }
  }
  
  public var selectedCenter: Center? {
    didSet {
      updateCenterButton()
      subtitleLabel.text = selectedCenter?.address1
    }
  }
  
  private func updateCenterButton() {
    let color: UIColor = isWalkthrough ? .white: .lightNavy
    let materialIcon: MaterialDesignIcon = isSelected ? .chevronUp: .chevronDown
    centerButton.setAttributedTitle(
      selectedCenter?.name?.clean().appending(" ").attributed.add([
        .color(color),
        .font(.openSans(style: .semiBold(size: 14.0)))]).append(
          attrs: materialIcon.attributed.add([
            .color(color), .font(
              .materialDesign(size: 14.0))])),
      for: .normal)
    subtitleLabel.textColor = isWalkthrough ? .white: .bluishGrey
  }
}
