//
//  PresenterViewController.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 10/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit

public enum PresenterSourcePosition {
  case verticalAutoRight
  case verticalAutoLeft
  case topCenter(offset: CGSize)
  case center(offset: CGSize)
  case bottomRight(offset: CGSize)
  case bottomLeft(offset: CGSize)
  case bottomCenter(offset: CGSize)
}

public struct PresenterAppearance {
  public var dimColor: UIColor = UIColor.black.withAlphaComponent(0.5)
  public var cornerRadius: CGFloat = 7.0
  public var backgroundColor: UIColor = .clear
  public var shadowAppearance: ShadowAppearance? = ShadowAppearance()
  public var dimAnchor: Bool = true
  public var minPadding: CGFloat = 16.0
  
  public init() {
  }
}

public enum PresenterSetting {
  case panToDismiss
  case tapToDismiss
  case anchor(view: UIView, position: PresenterSourcePosition)
  case forceAdaptAnchorWidth
  case appearance(_ appearance: PresenterAppearance)
}

public enum PresenterType {
  case popover(size: CGSize)
  case sheet(height: CGFloat)
}

public protocol PresentedControllerProtocol {
  var presenterType: PresenterType? { get }
  var presenterCanShowKeyboard: Bool { get }
  
  func presenterWillAppear(presenterViewController: PresenterViewController)
  func presenterDidAppear(presenterViewController: PresenterViewController)
  func presenterWillDisappear(presenterViewController: PresenterViewController)
}

extension PresentedControllerProtocol {
  public var presenterCanShowKeyboard: Bool {
    return true
  }
  
  public func presenterWillAppear(presenterViewController: PresenterViewController) {
  }
  
  public func presenterDidAppear(presenterViewController: PresenterViewController) {
  }
  
  public func presenterWillDisappear(presenterViewController: PresenterViewController) {
  }
}

extension PresentedControllerProtocol where Self: UIViewController {
  public func reloadPresenter(animated: Bool = false) {
    if let presentedController = self.parent as? PresentedControllerProtocol & UIViewController {
      presentedController.reloadPresenter(animated: animated)
    } else if let presenterViewController = self.parent as? PresenterViewController {
      presenterViewController.updateConstraintIfNeeded(animated: animated)
    }
  }
  
  public func dismissPresenter(completion: VoidCompletion? = nil) {
    if let presentedController = self.parent as? PresentedControllerProtocol & UIViewController {
      presentedController.dismissPresenter(completion: completion)
    } else if let presenterViewController = self.parent as? PresenterViewController {
      presenterViewController.dismissViewController(completion: completion)
    }
  }
}

public final class PresenterViewController: UIViewController {
  @IBOutlet private weak var dimView: UIView!
  @IBOutlet private weak var containerView: ContainerView!
  @IBOutlet private weak var containerTopConstraint: NSLayoutConstraint!
  @IBOutlet private weak var containerLeftConstraint: NSLayoutConstraint!
  @IBOutlet private weak var containerWidthConstraint: NSLayoutConstraint!
  @IBOutlet private weak var containerHeightConstraint: NSLayoutConstraint!
  
  private var keyboardSize: CGSize = .zero
  
  private var presentedVC: (PresentedControllerProtocol & UIViewController)?
  private var settings: [PresenterSetting] = []
  private var anchorView: UIView?
  private var anchorPosition: PresenterSourcePosition?
  private var forceAdaptAnchorWidth: Bool = false
  private var presenterAppearance: PresenterAppearance! {
    didSet {
      dimView.backgroundColor = presenterAppearance.dimColor
      dimView.tag = NSNumber(value: presenterAppearance.dimAnchor).intValue
      containerView.backgroundColor = presenterAppearance.backgroundColor
    }
  }
  private var maxLayoutFrame: CGRect {
    return view.safeAreaLayoutGuide.layoutFrame
  }
  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    updateConstraintIfNeeded()
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    presentedVC?.presenterWillAppear(presenterViewController: self)
    setupPresentedVCIfNeeded()
    updateConstraintIfNeeded()
    UIView.animate(withDuration: 0.3) {
      self.view.alpha = 1.0
    }
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    presentedVC?.presenterDidAppear(presenterViewController: self)
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    presentedVC?.presenterWillDisappear(presenterViewController: self)
  }
  
  deinit {
    r4pidLog("deinit PresenterViewController")
  }
  
  private func setupPresentedVCIfNeeded() {
    guard let presentedVC = presentedVC else { return }
    addChild(presentedVC)
    containerView.addSubview(presentedVC.view)
    presentedVC.view.addSideConstraintsWithContainer(containerView)
    presentedVC.didMove(toParent: self)
  }
  
  fileprivate func updateConstraintIfNeeded(animated: Bool = false) {
    guard let presentedVC = presentedVC, presentedVC.isViewLoaded, let presenterType = presentedVC.presenterType else { return }
    switch presenterType {
    case .popover(var size):
      let maxWidth = maxLayoutFrame.width - (presenterAppearance.minPadding * 2)
      let maxHeight = maxLayoutFrame.height - ((presenterAppearance.minPadding * 2) + keyboardSize.height)
      if size.width > maxWidth {
        size.width = maxWidth
      }
      if size.height > maxHeight {
        size.height = maxHeight
      }
      
      presentedVC.view.layer.cornerRadius = presenterAppearance.cornerRadius
      if presenterAppearance.cornerRadius > 0.0 {
        presentedVC.view.clipsToBounds = true
      } else {
        presentedVC.view.clipsToBounds = false
      }
      if let shadowAppearance = presenterAppearance.shadowAppearance {
        containerView.addShadow(appearance: shadowAppearance)
      } else {
        containerView.removeShadow()
      }
      if keyboardSize != .zero {//keyboard shown
        if forceAdaptAnchorWidth {
          containerWidthConstraint.constant = anchorView?.bounds.width ?? size.width
        } else {
          containerWidthConstraint.constant = size.width
        }
        containerHeightConstraint.constant = size.height
        containerTopConstraint.constant = view.bounds.height - (keyboardSize.height + size.height + presenterAppearance.minPadding + maxLayoutFrame.origin.y)
        containerLeftConstraint.constant = (view.bounds.width - containerWidthConstraint.constant)/2
      } else if updateAnchorConstraintsIfNeeded(targetSize: size) {
        //do nothing
      } else {
        containerWidthConstraint.constant = size.width
        containerHeightConstraint.constant = size.height
        containerTopConstraint.constant = ((view.bounds.height - keyboardSize.height) - size.height)/2
        containerLeftConstraint.constant = (view.bounds.width - size.width)/2
      }
      if animated {
        UIView.animate(withDuration: 0.3) {
          self.view.layoutIfNeeded()
        }
      }
    case .sheet(let height):
      containerTopConstraint.constant = view.bounds.height - height
      containerLeftConstraint.constant = 0.0
      containerWidthConstraint.constant = view.bounds.width
      containerHeightConstraint.constant = height
    }
  }
  
  @discardableResult
  private func updateAnchorConstraintsIfNeeded(targetSize: CGSize) -> Bool {
    guard let anchorView = anchorView, let windowFrame = anchorView.superview?.convert(anchorView.frame, to: nil) else { return false }
    if dimView.tag == 0 {// creates hole in background
      let fillPath = UIBezierPath(roundedRect: CGRect(origin: .zero, size: dimView.bounds.size), cornerRadius: 0)
      let circlePath = UIBezierPath(roundedRect: CGRect(origin: windowFrame.origin, size: windowFrame.size), cornerRadius: anchorView.layer.cornerRadius)
      fillPath.append(circlePath)
      fillPath.usesEvenOddFillRule = true
      
      let fillLayer = CAShapeLayer()
      fillLayer.path = fillPath.cgPath
      fillLayer.fillRule = .evenOdd
      dimView.layer.mask = fillLayer
      dimView.tag = 1
    }
    guard let anchorPosition = anchorPosition else { return false }
    if forceAdaptAnchorWidth {
      containerWidthConstraint.constant = anchorView.bounds.width
    } else {
      if view.frame.width == anchorView.bounds.width {
        let newWidth = anchorView.bounds.width - (presenterAppearance.minPadding + 2.0)
        if targetSize.width < 1 {
          containerWidthConstraint.constant = newWidth
        } else {
          containerWidthConstraint.constant = targetSize.width
        }
      } else {
        let newWidth = anchorView.bounds.width
        if targetSize.width < 1 {
          containerWidthConstraint.constant = newWidth
        } else {
          containerWidthConstraint.constant = targetSize.width
        }
      }
    }
    switch anchorPosition {
    case .verticalAutoRight:
      let centerY = windowFrame.origin.y +  windowFrame.height/2
      if centerY > view.bounds.height/2 {//post is top
        containerHeightConstraint.constant = min(targetSize.height, windowFrame.origin.y - (presenterAppearance.minPadding + 2.0))
        containerTopConstraint.constant = windowFrame.origin.y - (containerHeightConstraint.constant + 2.0)
        containerLeftConstraint.constant = windowFrame.origin.x + anchorView.bounds.width - containerWidthConstraint.constant
      } else {
        containerTopConstraint.constant = windowFrame.origin.y + anchorView.bounds.height + 2.0
        containerLeftConstraint.constant = windowFrame.origin.x + anchorView.bounds.width - containerWidthConstraint.constant
        containerHeightConstraint.constant = min(targetSize.height, view.bounds.height - (containerTopConstraint.constant + presenterAppearance.minPadding))
      }
    case .verticalAutoLeft:
      let centerY = windowFrame.origin.y +  windowFrame.height/2
      if centerY > view.bounds.height/2 {//post is top
        containerHeightConstraint.constant = min(targetSize.height, windowFrame.origin.y - (presenterAppearance.minPadding + 2.0))
        containerTopConstraint.constant = windowFrame.origin.y - (containerHeightConstraint.constant + 2.0)
        containerLeftConstraint.constant = windowFrame.origin.x
      } else {
        containerTopConstraint.constant = windowFrame.origin.y + anchorView.bounds.height + 2.0
        containerLeftConstraint.constant = windowFrame.origin.x
        containerHeightConstraint.constant = min(targetSize.height, view.bounds.height - (containerTopConstraint.constant + presenterAppearance.minPadding))
      }
    case .topCenter(let offset):
      containerHeightConstraint.constant = min(targetSize.height, windowFrame.origin.y - (presenterAppearance.minPadding + 2.0))
      containerTopConstraint.constant = windowFrame.origin.y - (containerHeightConstraint.constant + 2.0 + offset.height)
      containerLeftConstraint.constant = windowFrame.origin.x - (containerWidthConstraint.constant - anchorView.bounds.width)/2 + offset.width
    case .center(let offset):
      containerTopConstraint.constant = windowFrame.origin.y - (containerHeightConstraint.constant - anchorView.bounds.height)/2 + offset.height
      containerLeftConstraint.constant = windowFrame.origin.x - (containerWidthConstraint.constant - anchorView.bounds.width)/2 + offset.width
      containerHeightConstraint.constant = min(targetSize.height, view.bounds.height - (containerTopConstraint.constant + presenterAppearance.minPadding))
    case .bottomLeft(let offset):
      containerTopConstraint.constant = windowFrame.origin.y + anchorView.bounds.height + offset.height
      containerLeftConstraint.constant = windowFrame.origin.x + offset.width
      containerHeightConstraint.constant = min(targetSize.height, view.bounds.height - (containerTopConstraint.constant + presenterAppearance.minPadding))
    case .bottomRight(let offset):
      containerTopConstraint.constant = windowFrame.origin.y + anchorView.bounds.height + offset.height
      containerLeftConstraint.constant = windowFrame.origin.x + anchorView.bounds.width + offset.width - containerWidthConstraint.constant
      containerHeightConstraint.constant = min(targetSize.height, view.bounds.height - (containerTopConstraint.constant + presenterAppearance.minPadding))
    case .bottomCenter(let offset):
      containerTopConstraint.constant = windowFrame.origin.y + anchorView.bounds.height + offset.height
      containerLeftConstraint.constant = windowFrame.origin.x - (containerWidthConstraint.constant - anchorView.bounds.width)/2 + offset.width
      containerHeightConstraint.constant = min(targetSize.height, view.bounds.height - (containerTopConstraint.constant + presenterAppearance.minPadding))
    }
    return true
  }
  
  fileprivate func dismissViewController(completion: VoidCompletion? = nil) {
    UIView.animate(withDuration: 0.3, animations: {
      self.view.alpha = 0.0
    }, completion: { (_) in
      self.dismiss(animated: false) {
        completion?()
      }
    })
  }
}

// MARK: - ControllerProtocol
extension PresenterViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("PresenterViewController segueIdentifier not set")
  }
  
  public func setupUI() {
    view.alpha = 0.0
    presenterAppearance = .init()
  }
  
  public func setupController() {
    settings.forEach { (setting) in
      switch setting {
      case .tapToDismiss:
        observeTapToDismiss(view: dimView)
      case .panToDismiss:
        observePanToDismiss(view: containerView)
      case .appearance(let appearance):
        presenterAppearance = appearance
      case .anchor(let view, let position):
        anchorView = view
        anchorPosition = position
      case .forceAdaptAnchorWidth:
        forceAdaptAnchorWidth = true
      }
    }
  }
  
  public func setupObservers() {
    observeKeyboard()
  }
}

// MARK: - TapToDismissProtocol
extension PresenterViewController: TapToDismissProtocol {
  public func handleTapToDismiss(_ tapGesture: UITapGestureRecognizer) {
    dismissViewController()
  }
}

// MARK: - PanToDismissProtocol
extension PresenterViewController: PanToDismissProtocol {
  public func handlePanToDismiss(_ panGesture: UIPanGestureRecognizer) {
    evaluatePanToDismiss(panGesture: panGesture) { [weak self] in
      guard let `self` = self else { return }
      self.dismissViewController()
    }
  }
}

// MARK: - KeyboardHandlerProtocol
extension PresenterViewController: KeyboardHandlerProtocol {
  public func keyboardWillHide(_ notification: Notification) {
    guard presentedVC?.presenterCanShowKeyboard ?? false  else { return }
    keyboardSize = .zero
    updateConstraintIfNeeded()
  }
  
  public func keyboardWillShow(_ notification: Notification) {
    guard presentedVC?.presenterCanShowKeyboard ?? false  else { return }
    keyboardSize = evaluateKeyboardFrameFromNotification(notification).size
    updateConstraintIfNeeded()
  }
}

extension PresenterViewController {
  public static func show(presentVC: PresentedControllerProtocol & UIViewController, settings: [PresenterSetting] = [], onVC: UIViewController) {
    let presenterViewController = UIStoryboard.get(.presenterStory, bundle: .r4pidKit).getController(PresenterViewController.self)
    presenterViewController.presentedVC = presentVC
    presenterViewController.settings = settings
    onVC.present(presenterViewController, animated: false) {
    }
  }
}

extension StoryboardName {
  static var presenterStory: StoryboardName {
    return "Presenter"
  }
}

@IBDesignable
final class ContainerView: UIView, Designable, Shadowable {
  var shadowLayer: CAShapeLayer!
  
  @IBInspectable
  var cornerRadius: CGFloat = 0.0 {
    didSet {
      updateLayer()
    }
  }
  
  @IBInspectable
  var borderWidth: CGFloat = 0.0 {
    didSet {
      updateLayer()
    }
  }
  
  @IBInspectable
  var borderColor: UIColor = .clear {
    didSet {
      updateLayer()
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    updateLayer()
  }
}
