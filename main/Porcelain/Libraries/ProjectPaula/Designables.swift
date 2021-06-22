//
//  Designables.swift
//  Porcelain
//
//  Created by Justine Rangel on 10/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

extension Designable where Self: UIView {
  @discardableResult
  public func addGradientBackground(colors: [CGColor], name: String? = nil) -> CAGradientLayer {
    let gradient:CAGradientLayer = CAGradientLayer()
    gradient.frame = bounds
    gradient.colors = colors
    gradient.name = name
    layer.insertSublayer(gradient, at: 0)
    return gradient
  }
}


public class DesignableView: UIDesignableView {
}

public class DesignableControl: UIDesignableControl {
}

public class DesignableTextField: UIDesignableTextField {
  public var canPerformAction: Bool = true
  public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    return canPerformAction
  }
}

public class DesignableTextView: UIDesignableTextView {
}

public class DesignableButton: UIDesignableButton, ActivityIndicatorProtocol {
  public var activityIndicatorView: UIActivityIndicatorView? {
    didSet {
      activityIndicatorView?.color = .lightNavy
      activityIndicatorView?.backgroundColor = .clear
    }
  }
  
  public var shadowAppearance: ShadowAppearance? {
    didSet {
      if let shadowAppearance = shadowAppearance {
        addShadow(appearance: shadowAppearance)
      }
    }
  }
  
  public var isLoading: Bool = false {
    didSet {
      if isLoading {
        isUserInteractionEnabled = false
        showActivityOnView(self)
      } else {
        isUserInteractionEnabled = true
        hideActivity()
      }
    }
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    if let shadowAppearance = shadowAppearance {
      addShadow(appearance: shadowAppearance)
    }
  }
}

public class DesignableLabel: UIDesignableLabel {
}

public class DesignableTableView: UIDesignableTableView {
}

@IBDesignable
public class DesignableSegmentedControl: UIDesignableSegmentedControl {
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    commonInit()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    commonInit()
  }
  
  public override init(items: [Any]?) {
    super.init(items: items)
    
    commonInit()
  }
  
  private func commonInit() {
    let capInsets = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 6.0, right: 5.0)
    let selectedImage = UIImage.imgSegmentedLine.maskWithColor(.lightNavy).resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
    let normalImage = UIColor.clear.toImage(withSize: CGSize(width: 5.0, height: bounds.height)).resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
    tintColor = .clear
    setTitleTextAttributes(
      NSAttributedString.createAttributes([.color(.gunmetal), .font(.idealSans(style: .book(size: 14.0)))]), for: .normal)
    setTitleTextAttributes(
      NSAttributedString.createAttributes([.color(.lightNavy), .font(.idealSans(style: .book(size: 14.0)))]),
      for: .selected)
    setBackgroundImage(selectedImage, for: .selected, barMetrics: .default)
    setBackgroundImage(normalImage, for: .normal, barMetrics: .default)
    setDividerImage(UIColor.clear.toImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
  }
  
  public override var intrinsicContentSize: CGSize {
    return CGSize(width: bounds.width, height: 50.0)
  }
}
