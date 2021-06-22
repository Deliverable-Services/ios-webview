//
//  SimpleNotificationView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 15/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import UICircularProgressRing
import SwiftMessages
import R4pidKit

public enum SimpleTrigger {
  case action
  case auto
}

public protocol SimpleNotificationViewModelProtocol {
  var trigger: SimpleTrigger { get }
  var showProgress: Bool { get }
  var backgroundColor: UIColor { get }
  var foregroundColor: UIColor { get }
  var notification: String { get }
  var action: String { get }
  var notificationDescription: NSAttributedString { get }
  var actionDescription: NSAttributedString { get }
}

public struct SimpleNotificationViewModel: SimpleNotificationViewModelProtocol {
  public var trigger: SimpleTrigger = .auto
  public var showProgress: Bool = true
  public var backgroundColor: UIColor = .coral
  public var foregroundColor: UIColor = .white
  public var notification: String = "[Notification Description]"
  public var action: String = "[Action]"
  public var notificationDescription: NSAttributedString {
    return notification.attributed.add([.color(foregroundColor), .font(.openSans(style: .regular(size: 13.0)))])
  }
  
  public var actionDescription: NSAttributedString {
    return action.attributed.add([.color(foregroundColor), .font(.openSans(style: .regular(size: 13.0)))])
  }
}

public class SimpleNotificationView: MessageView {
  @IBOutlet private weak var progressRingContainer: UIView!
  @IBOutlet private weak var progressRing: SimpleNotificationProgressRing!
  @IBOutlet private weak var notificationLabel: UILabel!
  @IBOutlet private weak var actionButton: UIButton!
  
  public var didTriggerWithID: ((SimpleTrigger, String) -> ())?
  
  public var viewModel: SimpleNotificationViewModel = SimpleNotificationViewModel() {
    didSet {
      updateUI()
    }
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    progressRing.setTheme(.white)
    updateUI()
  }
  
  private func updateUI() {
    notificationLabel.attributedText = viewModel.notificationDescription
    actionButton.setAttributedTitle(viewModel.actionDescription, for: .normal)
    actionButton.backgroundColor = viewModel.backgroundColor
    backgroundView.backgroundColor = viewModel.backgroundColor
    progressRingContainer.isHidden = !viewModel.showProgress
    progressRing.value = 0.0
  }
  
  @IBAction private func didClickAction(_ sender: Any) {
    viewModel.trigger = .action
    progressRing.value = 100.0
    SwiftMessages.hide(id: id)
  }
}

extension SimpleNotificationView {  
  public enum Theme {
    case undo
    case custom(backgroundColor: UIColor, foregroundColor: UIColor)
    
    public var colors: (backgroundColor: UIColor, foregroundColor: UIColor) {
      switch self {
      case .undo:
        return (.coral, .white)
      case .custom(let backgroundColor, let foregroundColor):
        return (backgroundColor, foregroundColor)
      }
    }
  }
  
  @discardableResult
  public func setTheme(_ theme: Theme) -> Self {
    viewModel.backgroundColor = theme.colors.backgroundColor
    viewModel.foregroundColor = theme.colors.foregroundColor
    return self
  }
  
  @discardableResult
  public func setContent(notification: String, action: String) -> Self {
    viewModel.notification = notification
    viewModel.action = action
    return self
  }
  
  public func show() {
    updateUI()
    var config = SwiftMessages.Config()
    config.presentationStyle = .bottom
    config.preferredStatusBarStyle = UIApplication.shared.topViewController()?.preferredStatusBarStyle ?? .lightContent
    config.duration = .seconds(seconds: 5)
    let event: SwiftMessages.EventListener = { event in
      switch event {
      case .willHide:
        self.didTriggerWithID?(self.viewModel.trigger, self.id)
      case .willShow:
        self.progressRing.animateProgressWithDuration(5.0)
      default: break
      }
    }
    config.eventListeners.append(event)
    SwiftMessages.pauseBetweenMessages = 0.0
    SwiftMessages.show(config: config, view: self)
  }
}

extension SimpleNotificationView {
  /// hide ids
  public static func hideIDs(_ ids: [String]) {
    for id in ids { SwiftMessages.hide(id: id) }
  }
}

public final class SimpleNotificationProgressRing: UICircularProgressRing, Designable {
  public var cornerRadius: CGFloat = 0.0
  public var borderWidth: CGFloat = 0.0
  public var borderColor: UIColor = .clear
}

// MARK: - SimpleNotificationProgressRing
extension  SimpleNotificationProgressRing {
  public enum Theme {
    case white
    
    public var startAngle: CGFloat {
      switch self {
      case .white:
        return 270.0
      }
    }
    
    public var style: UICircularProgressRingStyle {
      switch self {
      case .white:
        return .inside
      }
    }
    
    public var outerRingWidth: CGFloat {
      switch self {
      case .white:
        return 2.0
      }
    }
    
    public var outerRingColor: UIColor {
      switch self {
      case .white:
        return .clear
      }
    }
    
    public var innerRingWidth: CGFloat {
      switch self {
      case .white:
        return 5.0
      }
    }
    
    public var innerRingColor: UIColor {
      switch self {
      case .white:
        return .white
      }
    }
    
    public var innerCapStype: CGLineCap {
      switch self {
      case .white:
        return .butt
      }
    }
    
    public var fontColor: UIColor {
      switch self {
      case .white:
        return .white
      }
    }
  }
  
  public func setTheme(_ theme: Theme) {
    startAngle = theme.startAngle
    ringStyle = theme.style
    outerRingWidth = theme.outerRingWidth
    outerRingColor = theme.outerRingColor
    innerRingWidth = theme.innerRingWidth
    innerRingColor =  theme.innerRingColor
    innerCapStyle = theme.innerCapStype
    fontColor = theme.fontColor
    cornerRadius = 13.0
    borderWidth = 1.0
    borderColor = .white
    updateLayer()
  }
  
  public func animateProgressWithDuration(_ duration: TimeInterval, completion: VoidCompletion? = nil) {
    DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.1) {
      DispatchQueue.main.async {
        let newValue = self.value + CGFloat(10/duration)
        if self.maxValue >= newValue {
          self.value = newValue
        } else {
          self.value = self.maxValue
        }
      }
      if self.value < 100 {
        self.animateProgressWithDuration(duration, completion: completion)
      } else {
        DispatchQueue.main.async {
          completion?()
        }
      }
    }
  }
}

// MARK: - SwiftMessages
extension MessageView {
  public enum NewLayout: String {
    case simpleNotificationView = "SimpleNotificationView"
  }
  
  public static func viewFromNib<T: MessageView>(newLayout: NewLayout) -> T {
    return try! SwiftMessages.viewFromNib(named: newLayout.rawValue)
  }
}
