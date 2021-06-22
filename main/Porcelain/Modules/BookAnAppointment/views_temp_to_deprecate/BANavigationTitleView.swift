//
//  BANavigationTitleView.swift
//  Porcelain
//
//  Created by Justine Rangel on 11/10/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public struct BANavigationTitleData {
  init(title: String, subtitle: String?, color: UIColor = UIColor.Porcelain.greyishBrown) {
    self.title = title
    self.subtitle = subtitle
    self.color = color
  }
  var title: String
  var subtitle: String?
  var color: UIColor
}

public final class BANavigationTitleView: UIView {
  public var shadowLayer: CAShapeLayer!
  
  @IBOutlet private weak var titleButton: UIButton!
  @IBOutlet private weak var subtitleLabel: UILabel!
  
  public var titleDidTapped: VoidCompletion?
  
  public var data: BANavigationTitleData? {
    didSet {
      guard let data = data else { return }
      let titleAttributedText = NSMutableAttributedString()
      titleAttributedText.append(NSAttributedString(
        content: concatenate(data.title, "  "),
        font: UIFont.Porcelain.openSans(14.0, weight: .semiBold),
        foregroundColor: data.color,
        paragraphStyle: ParagraphStyle.makeCustomStyle(
          lineHeight: 14.0,
          characterSpacing: 0.5)))
      titleAttributedText.append(NSAttributedString(
        content: MaterialDesignIcon.chevronDown.rawValue,
        font: UIFont.Porcelain.materialDesign(14.0),
        foregroundColor: data.color))
      titleButton.setAttributedTitle(titleAttributedText, for: .normal)
      if let subtitle = data.subtitle {
        subtitleLabel.isHidden = false
        subtitleLabel.attributedText = NSAttributedString(
          content: subtitle,
          font: UIFont.Porcelain.openSans(12.0, weight: .regular),
          foregroundColor: data.color,
          paragraphStyle: ParagraphStyle.makeCustomStyle(
            lineHeight: 16.0,
            characterSpacing: 0.4,
            alignment: .center))
      } else {
        subtitleLabel.isHidden = true
      }
    }
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    data = BANavigationTitleData(title: "Select Location", subtitle: "")
    data = nil
  }
  
  @IBAction private func titleTapped(sender: Any) {
    titleDidTapped?()
  }
}

public final class BANavigationExtensionView: UIView, Shadowable {
  public var shadowLayer: CAShapeLayer!
  @IBOutlet private weak var titleLabel: UILabel!
  
  public var title: String? {
    didSet {
      if let title = title {
        titleLabel.isHidden = false
        titleLabel.attributedText = NSAttributedString(
          content: title,
          font: UIFont.Porcelain.openSans(12.0, weight: .regular),
          foregroundColor: UIColor.Porcelain.greyishBrown,
          paragraphStyle: ParagraphStyle.makeCustomStyle(
            lineHeight: 16.0,
            characterSpacing: 0.4,
            alignment: .center))
      } else {
        titleLabel.isHidden = true
      }
    }
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    addShadow(cornerRadius: 0.0)
  }
}
