//
//  NavigationController.swift
//  Porcelain
//
//  Created by Justine Rangel on 16/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct NavAttributedTitleAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? {
    return 2.0
  }
  var alignment: NSTextAlignment?
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat?
  var font: UIFont? {
    return .openSans(style: .semiBold(size: 14.0))
  }
  var color: UIColor?
}

public enum NavigationTheme {
  case white
  case blue
  case custom(barColor: UIColor, tintColor: UIColor)
  
  public var barTintColor: UIColor {
    switch self {
    case .white:
      return .white
    case .blue:
      return .lightNavy
    case .custom(let barColor,_):
      return barColor
    }
  }
  
  public var tintColor: UIColor {
    switch self {
    case .white:
      return .lightNavy
    case .blue:
      return .white
    case .custom(_, let tintColor):
      return tintColor
    }
  }
  
  public var titleTextAttributes: [NSAttributedString.Key: Any]? {
    var navAttributedTitleAppearance  = NavAttributedTitleAppearance()
    navAttributedTitleAppearance.color = tintColor
    return NSAttributedString.createAttributes([.appearance(navAttributedTitleAppearance)])
  }
}

public class NavigationController: UINavigationController {
  public var statusBarStyle: UIStatusBarStyle = .default
  
  public override init(rootViewController: UIViewController) {
    super.init(rootViewController: rootViewController)
  }
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override var preferredStatusBarStyle : UIStatusBarStyle {
    return statusBarStyle
  }
  
  public func overrideStatusBarStyle(_ style: UIStatusBarStyle) {
    statusBarStyle = style
    UIView.animate(withDuration: 0.3) {
      self.setNeedsStatusBarAppearanceUpdate()
    }
  }
}

// MARK: - ControllerProtocol
extension NavigationController: ControllerProtocol, NavigationProtocol {
  public static var segueIdentifier: String {
    return "showNavigationController"
  }
  
  public func setupUI() {
    setTheme(.white)
  }
  
  public func setupController() {
    delegate = self
    interactivePopGestureRecognizer?.delegate = nil
  }
  
  public func setupObservers() {
  }
}

extension NavigationController {
  public func setTheme(_ theme: NavigationTheme) {
    navigationBar.backgroundColor = theme.barTintColor
    navigationBar.barTintColor = theme.barTintColor
    navigationBar.isTranslucent = false
    navigationBar.tintColor = theme.tintColor
    navigationBar.titleTextAttributes = theme.titleTextAttributes
    navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationBar.shadowImage = UIImage()
    view.backgroundColor = .white
  }
}

// MARK: - UINavigationControllerDelegate
extension NavigationController: UINavigationControllerDelegate {
}
