//
//  AppTheme.swift
//
//  Created by Patricia Cesar on 08/03/2018.
//  Copyright © 2018 Patricia Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public struct AttributedTextViewTextAppearance: AttributedStringAppearanceProtocol {
  public var characterSpacing: Double? {
    return 0.49
  }
  public var alignment: NSTextAlignment? {
    return .left
  }
  public var lineBreakMode: NSLineBreakMode? {
    return .byWordWrapping
  }
  public var minimumLineHeight: CGFloat? {
    return 20.0
  }
  public var font: UIFont? {
    return .openSans(style: .regular(size: 14.0))
  }
  public var color: UIColor? {
    return .gunmetal
  }
}

public struct DialogButtonAttributedTitleAppearance: AttributedStringAppearanceProtocol {
  public var characterSpacing: Double? {
    return 1.0
  }
  public var alignment: NSTextAlignment? {
    return nil
  }
  public var lineBreakMode: NSLineBreakMode? {
    return nil
  }
  public var minimumLineHeight: CGFloat? {
    return nil
  }
  public var font: UIFont? = .idealSans(style: .book(size: 14.0))
  public var color: UIColor? = .white
}

public struct FormSaveButtonAttributedTitleAppearance: AttributedStringAppearanceProtocol {
  public var characterSpacing: Double? {
    return 2.0
  }
  public var alignment: NSTextAlignment? {
    return nil
  }
  public var lineBreakMode: NSLineBreakMode? {
    return nil
  }
  public var minimumLineHeight: CGFloat? {
    return nil
  }
  public var font: UIFont? {
    return .openSans(style: .semiBold(size: 13.0))
  }
  public var color: UIColor? = .white
}

public struct DefaultTextViewTextAppearance: AttributedStringAppearanceProtocol {
  public var characterSpacing: Double? = 0.2
  public var alignment: NSTextAlignment?
  public var lineBreakMode: NSLineBreakMode?
  public var minimumLineHeight: CGFloat? = 18.0
  public var font: UIFont? = .openSans(style: .regular(size: 12.0))
  public var color: UIColor? = .gunmetal
}

public struct DefaultTextViewPlaceholderTextAppearance: AttributedStringAppearanceProtocol {
  public var characterSpacing: Double? = 0.2
  public var alignment: NSTextAlignment?
  public var lineBreakMode: NSLineBreakMode?
  public var minimumLineHeight: CGFloat?
  public var font: UIFont? = .openSans(style: .regular(size: 12.0))
  public var color: UIColor? = .bluishGrey
}

public struct BadgeAppearance: BadgeAppearanceProtoocol {
  public var font: UIFont = .openSans(style: .regular(size: 10.0))
  public var textColor: UIColor = .white
  public var backgroundColor: UIColor = .coral
}

public class BadgeableBarButtonItem: UIBarButtonItem,  BadgeableProtocol {
  public var badgeAppearance: BadgeAppearanceProtoocol {
    return BadgeAppearance()
  }
  
  public var badgeContainer: UIView?
  
  private var badge: String?
  
  public func setBadge(_ badge: String?) {
    self.badge = badge
    renderBadge(badge)
  }
  
  public override init() {
    super.init()
    
    addObserver(self, forKeyPath: "view", options: [], context: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    addObserver(self, forKeyPath: "view", options: [], context: nil)
  }
  
  deinit {
    self.removeObserver(self, forKeyPath: "view")
  }
  
  public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard let view = self.value(forKey: "view") as? UIView else { return }
    badgeContainer = view
    renderBadge(badge)
  }
}

public enum MaterialDesignIcon: String {
  case check = "\u{f26b}"
  case chevronDown = "\u{f2f9}"
  case chevronLeft = "\u{f2fa}"
  case chevronRight = "\u{f2fb}"
  case chevronUp = "\u{f2fc}"
  case close = "\u{f136}"
  case time = "\u{f337}"
  case pin = "\u{f1ab}"
  case star = "\u{f27d}"
  case starHalf = "\u{f27b}"
  case starOutline = "\u{f27c}"
  case search = "\u{f1c3}"
  
  public var attributed: NSMutableAttributedString  {
    return rawValue.attributed
  }
}
