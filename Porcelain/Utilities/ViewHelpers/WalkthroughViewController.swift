//
//  WalkthroughViewController.swift
//  Porcelain
//
//  Created by Justine Rangel on 15/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import Popover

public typealias WalkthroughCompletion = (WalkthroughSteps) -> ()

public enum WalkthroughSteps: Int {
  case dashboard = 1001, profile, notifications, chat, scanQR, hightlights, shop, end
  
  public var value: (title: String, content: String, button: String) {
    switch self {
    case .dashboard:
      return ("Dashboard",
              "Everything about your journey at Porcelain at a glance.",
              "Next")
    case .profile:
      return ("Profile",
              "All your details at one glance.",
              "Next")
    case .notifications:
      return ("Notifications",
              "Keep this on to be the first to know about our latest offerings!",
              "Next")
    case .chat:
      return ("Live Chat Support",
              "Have a question or talk to one of us? Chat away!",
              "Next")
    case .scanQR:
      return ("Connect to Porcelain",
              "Sync with our Porcelain outlets to enjoy the complete digital  experience. Look out for QR codes!",
              "Next")
    case .hightlights:
      return ("Highlights",
              "Articles, Tips, News. Get updated with our latest!",
              "Next")
    case .shop:
      return ("Shop",
              "View all products and treatment offerings from Porcelain",
              "Got it!")
    case .end:
      return ("", "", "")
    }
  }
}

public class WalkthroughViewController: UIViewController {
  @IBOutlet private weak var curtainView: UIView!
  @IBOutlet private weak var bottomCurtainView: UIView!
  @IBOutlet private weak var stepsStack: UIStackView!
  @IBOutlet private weak var navigationStack: UIView!
  
  public var didNavigateToSteps: WalkthroughCompletion?
  private var tempActionHandler: VoidCompletion?
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if let startView = stepsStack.viewWithTag(WalkthroughSteps.dashboard.rawValue) {
      showPopOver(fromView: startView)
    }
  }
  
  public func showPopOver(fromView: UIView) {
    let walkthroughSteps = WalkthroughSteps(rawValue: fromView.tag)!
    let walkthroughDialogView = WalkthroughDialogView.getView(WalkthroughDialogView.self)
    walkthroughDialogView.title = walkthroughSteps.value.title
    walkthroughDialogView.content = walkthroughSteps.value.content
    walkthroughDialogView.buttonTitle = walkthroughSteps.value.button
    walkthroughDialogView.sizeToFit()
    var options = [
      .type(.up),
      .animationIn(0.0),
      .animationOut(0.0),
      .blackOverlayColor(.clear),
      .color(UIColor.Porcelain.whiteTwo),
      .dismissOnBlackOverlayTap(false),
      .arrowSize(CGSize(width: 24.0, height: 14.0))
      ] as [PopoverOption]
    options.append(.cornerRadius(6.0))
    options.append(.sideEdge(8.0))
    let ypos: CGFloat
    switch WalkthroughSteps(rawValue: fromView.tag)! {
    case .dashboard, .scanQR, .hightlights, .shop:
      options.append(.type(.up))
      ypos = curtainView.bounds.height - 8.0
    default:
      options.append(.type(.down))
      ypos = navigationStack.frame.origin.y + navigationStack.frame.height + 8.0
    }
    let popover = Popover(options: options, showHandler: nil) { [weak self] in
      guard let `self` = self else { return }
      self.didNavigateToSteps?(walkthroughSteps)
      let rawInt = walkthroughSteps.rawValue + 1
//      if walkthroughSteps.rawValue == WalkthroughSteps.notifications.rawValue {//skip chat
//        rawInt += 1
//      }
      self.hideAllNavigationViews()
      switch WalkthroughSteps(rawValue: rawInt)! {
      case .dashboard, .scanQR, .hightlights, .shop, .end:
        self.bottomCurtainView.isHidden = true
        if let newView = self.stepsStack.viewWithTag(rawInt) {
          self.showPopOver(fromView: newView)
        } else {
          AppUserDefaults.oneTimeWalkthrough = true
          self.dismiss(animated: false)
        }
      default:
        self.bottomCurtainView.isHidden = false
        if let newView = self.navigationStack.viewWithTag(rawInt) {
          newView.isHidden = false
          self.showPopOver(fromView: newView)
        } else {
          AppUserDefaults.oneTimeWalkthrough = true
          self.dismiss(animated: false)
        }
      }
    }
    popover.show(walkthroughDialogView, point: CGPoint(x: fromView.center.x, y: ypos), inView: curtainView)
    walkthroughDialogView.actionTapped = { [weak popover] in
      guard let `popover` = popover else { return }
      popover.dismiss()
    }
    tempActionHandler = { [weak popover] in
      guard let `popover` = popover else { return }
      popover.dismiss()
    }
  }
  
  @objc
  private func tapped(_ sender: Any) {
    tempActionHandler?()
  }
}

// MARK: - ControllerConfigurable
extension WalkthroughViewController: ControllerConfigurable {
  public static var segueIdentifier: String {
    return "showWalkthrough"
  }
  
  public func setupUI() {
    bottomCurtainView.isHidden = true
    hideAllNavigationViews()
  }
  
  public func setupController() {
  }
  
  public func setupObservers() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
    view.addGestureRecognizer(tap)
  }
}

extension WalkthroughViewController {
  private func hideAllNavigationViews() {
    navigationStack.subviews.forEach { (view) in
      view.isHidden = true
    }
  }
}
