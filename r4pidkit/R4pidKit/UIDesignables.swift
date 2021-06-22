//
//  UIDesignables.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 01/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
open class UIDesignableControl: UIControl, Designable, Shadowable {
  public var shadowLayer: CAShapeLayer!
  
  @IBInspectable
  public var cornerRadius: CGFloat = 0.0 {
    didSet {
      updateLayer()
    }
  }
  
  @IBInspectable
  public var borderWidth: CGFloat = 0.0 {
    didSet {
      updateLayer()
    }
  }
  
  @IBInspectable
  public var borderColor: UIColor = .clear {
    didSet {
      updateLayer()
    }
  }
  
  open override func awakeFromNib() {
    super.awakeFromNib()
    
    updateLayer()
  }
}

@IBDesignable
open class UIDesignableSegmentedControl: UISegmentedControl, Designable, Shadowable {
  public var shadowLayer: CAShapeLayer!
  
  @IBInspectable
  public var cornerRadius: CGFloat = 0.0 {
    didSet {
      updateLayer()
    }
  }
  
  @IBInspectable
  public var borderWidth: CGFloat = 0.0 {
    didSet {
      updateLayer()
    }
  }
  
  @IBInspectable
  public var borderColor: UIColor = .clear {
    didSet {
      updateLayer()
    }
  }
  
  open override func awakeFromNib() {
    super.awakeFromNib()
    
    updateLayer()
  }
}

@IBDesignable
open class UIDesignableView: UIView, Designable, Shadowable {
  public var shadowLayer: CAShapeLayer!
  
  @IBInspectable
  public var cornerRadius: CGFloat = 0.0 {
    didSet {
      updateLayer()
    }
  }
  
  @IBInspectable
  public var borderWidth: CGFloat = 0.0 {
    didSet {
      updateLayer()
    }
  }
  
  @IBInspectable
  public var borderColor: UIColor = .clear {
    didSet {
      updateLayer()
    }
  }
  
  open override func awakeFromNib() {
    super.awakeFromNib()
    
    updateLayer()
  }
}

@IBDesignable
open class UIDesignableTextField: UITextField, Designable, Shadowable {
  public var shadowLayer: CAShapeLayer!
  
  @IBInspectable
  public var showDoneToolBar: Bool = false
  
  @IBInspectable
  public var cornerRadius: CGFloat = 0.0 {
    didSet {
      updateLayer()
    }
  }
  
  @IBInspectable
  public var borderWidth: CGFloat = 0.0 {
    didSet {
      updateLayer()
    }
  }
  
  @IBInspectable
  public var borderColor: UIColor = .clear {
    didSet {
      updateLayer()
    }
  }
  
  @IBInspectable
  public var topEdgeInset: CGFloat = 0.0
  
  @IBInspectable
  public var leftEdgeInset: CGFloat = 0.0
  
  @IBInspectable
  public var bottomEdgeInset: CGFloat = 0.0
  
  @IBInspectable
  public var rightEdgeInset: CGFloat = 0.0
  
  @IBInspectable
  public var leftViewLeftPadding: CGFloat = 0.0
  
  open override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
    var textRect = super.leftViewRect(forBounds: bounds)
    textRect.origin.x += leftViewLeftPadding
    return textRect
  }
  
  open override func textRect(forBounds bounds: CGRect) -> CGRect {
    return super.textRect(forBounds: bounds.inset(by: UIEdgeInsets(top: topEdgeInset, left: leftEdgeInset, bottom: bottomEdgeInset, right: rightEdgeInset)))
  }
  
  open override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return super.editingRect(forBounds: bounds.inset(by: UIEdgeInsets(top: topEdgeInset, left: leftEdgeInset, bottom: bottomEdgeInset, right: rightEdgeInset)))
  }
  
  open override func awakeFromNib() {
    super.awakeFromNib()
    
    updateLayer()
    if showDoneToolBar {
      let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 48.0))
      doneToolbar.isTranslucent = true
      doneToolbar.barStyle = .default
      let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
      let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didClickDoneButton))
      doneToolbar.items = [flexSpace, done]
      doneToolbar.sizeToFit()
      inputAccessoryView = doneToolbar
    }
  }
  
  @objc
  private func didClickDoneButton() {
    resignFirstResponder()
  }
}

@IBDesignable
open class UIDesignableTextView: UITextView, Designable, Shadowable {
  public var shadowLayer: CAShapeLayer!
  
  @IBInspectable
  public var showDoneToolBar: Bool = true
  
  @IBInspectable
  public var cornerRadius: CGFloat = 0.0 {
    didSet {
      updateLayer()
    }
  }
  
  @IBInspectable
  public var borderWidth: CGFloat = 0.0 {
    didSet {
      updateLayer()
    }
  }
  
  @IBInspectable
  public var borderColor: UIColor = .clear {
    didSet {
      updateLayer()
    }
  }
  
  @IBInspectable
  public var topMargin: CGFloat = 8.0 {
    didSet {
      updateContainerInset()
    }
  }
  
  @IBInspectable
  public var leftMargin: CGFloat = 0.0 {
    didSet {
      updateContainerInset()
    }
  }
  
  @IBInspectable
  public var bottomMargin: CGFloat = 8.0 {
    didSet {
      updateContainerInset()
    }
  }
  
  @IBInspectable
  public var rightMargin: CGFloat = 0.0 {
    didSet {
      updateContainerInset()
    }
  }
  
  private func updateContainerInset() {
    textContainerInset = UIEdgeInsets(top: topMargin, left: leftMargin, bottom: bottomMargin, right: rightMargin)
    if textContainerInset == .zero {
      textContainer.lineFragmentPadding = 0
    }
  }
  
  open override func awakeFromNib() {
    super.awakeFromNib()
    
    updateContainerInset()
    updateLayer()
    if showDoneToolBar {
      let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 48.0))
      doneToolbar.isTranslucent = true
      doneToolbar.barStyle = .default
      let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
      let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didClickDoneButton))
      doneToolbar.items = [flexSpace, done]
      doneToolbar.sizeToFit()
      inputAccessoryView = doneToolbar
    }
  }
  
  @objc
  private func didClickDoneButton() {
    resignFirstResponder()
  }
}

@IBDesignable
open class UIDesignableButton: UIButton, Designable, Shadowable {
  public var shadowLayer: CAShapeLayer!
  
  @IBInspectable
  public var cornerRadius: CGFloat = 0.0 {
    didSet {
      updateLayer()
    }
  }
  
  @IBInspectable
  public var borderWidth: CGFloat = 0.0 {
    didSet {
      updateLayer()
    }
  }
  
  @IBInspectable
  public var borderColor: UIColor = .clear {
    didSet {
      updateLayer()
    }
  }
  
  open override func awakeFromNib() {
    super.awakeFromNib()
    
    updateLayer()
  }
}

@IBDesignable
open class UIDesignableLabel: UILabel, Designable, Shadowable {
  public var shadowLayer: CAShapeLayer!
  
  @IBInspectable
  public var cornerRadius: CGFloat = 0.0 {
    didSet {
      updateLayer()
    }
  }
  
  @IBInspectable
  public var borderWidth: CGFloat = 0.0 {
    didSet {
      updateLayer()
    }
  }
  
  @IBInspectable
  public var borderColor: UIColor = .clear {
    didSet {
      updateLayer()
    }
  }
  
  open override func awakeFromNib() {
    super.awakeFromNib()
    
    updateLayer()
  }
}

@IBDesignable
open class UIDesignableTableView: UITableView, Designable, Shadowable {
  public var shadowLayer: CAShapeLayer!
  
  @IBInspectable
  public var cornerRadius: CGFloat = 0.0 {
    didSet {
      updateLayer()
    }
  }
  
  @IBInspectable
  public var borderWidth: CGFloat = 0.0 {
    didSet {
      updateLayer()
    }
  }
  
  @IBInspectable
  public var borderColor: UIColor = .clear {
    didSet {
      updateLayer()
    }
  }
  
  open override func awakeFromNib() {
    super.awakeFromNib()
    
    updateLayer()
  }
}
