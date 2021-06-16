//
//  EmptyNotificationView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 10/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct AttributedTitleAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? {
    return 0.46
  }
  var alignment: NSTextAlignment? {
    return .center
  }
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat?
  var font: UIFont? {
    return .openSans(style: .regular(size: 13.0))
  }
  var color: UIColor? {
    return .bluishGrey
  }
}

@IBDesignable
public final class EmptyNotificationView: DesignableView, ActivityIndicatorProtocol {
  public var activityIndicatorView: UIActivityIndicatorView? {
    didSet {
      activityIndicatorView?.color = .bluishGrey
      activityIndicatorView?.backgroundColor =  .clear
    }
  }
  
  @IBOutlet private weak var view: UIView!
  @IBOutlet private weak var button: UIButton!
  
  public var message: String? {
    didSet {
      button.setAttributedTitle(
        message?.attributed.add(.appearance(AttributedTitleAppearance())),
        for: .normal)
      invalidateIntrinsicContentSize()
    }
  }
  
  public var isLoading: Bool = false   {
    didSet {
      if isLoading {
        showActivityOnView(self)
        view.isHidden = true
      } else {
        hideActivity()
        view.isHidden = false
      }
    }
  }
  
  public var tapped: VoidCompletion?
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    commonInit()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    commonInit()
  }
  
  private func commonInit() {
    loadNib(EmptyNotificationView.self)
    addSubview(view)
    view.addContainerBoundsResizingMask()
    cornerRadius = 7.0
    backgroundColor = .whiteFive
  }
  
  @IBAction private func actionTapped(_ sender: Any) {
    tapped?()
  }
  
  public override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    commonInit()
    message = "Button"
    view.prepareForInterfaceBuilder()
  }
  
  public override var intrinsicContentSize: CGSize {
    return CGSize(width: bounds.width, height: min(54.0, button.intrinsicContentSize.height))
  }
}
