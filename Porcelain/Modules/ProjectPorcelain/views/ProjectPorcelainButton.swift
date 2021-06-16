//
//  ProjectPorcelainButton.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 26/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct PPAttributedTextAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? {
    return 0.54
  }
  var alignment: NSTextAlignment?
  var lineBreakMode: NSLineBreakMode? {
    return .byWordWrapping
  }
  var minimumLineHeight: CGFloat? {
    return 18.0
  }
  var font: UIFont? {
    return .idealSans(style: .light(size: 13.0))
  }
  var color: UIColor? {
    return .bluishGrey
  }
}

public final class ProjectPorcelainButton: DesignableControl {
  @IBOutlet private weak var view: UIView!
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .idealSans(style: .book(size: 14.0))
      titleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var contentLabel: UILabel!
  
  public var image: UIImage? {
    didSet {
      imageView.image = image
    }
  }
  
  public var title: String? {
    didSet {
      titleLabel.text = title
    }
  }
  
  public var content: String? {
    didSet {
      contentLabel.attributedText = content?.attributed.add(.appearance(PPAttributedTextAppearance()))
    }
  }
  
  public override var isHighlighted: Bool {
    didSet {
      view.alpha = isHighlighted ? 0.8: 1.0
    }
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    commonInit()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    commonInit()
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    addShadow(appearance: .default)
  }
  
  private func commonInit() {
    loadNib(ProjectPorcelainButton.self)
    addSubview(view)
    view.addSideConstraintsWithContainer()
  }
}
