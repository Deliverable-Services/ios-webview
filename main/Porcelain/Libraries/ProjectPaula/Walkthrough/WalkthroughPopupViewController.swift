//
//  WalkthroughPopupViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 12/10/19.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public struct WalkthroughPopupAnchor {
  public var view: UIView
  public var position: PresenterSourcePosition
}

public final class WalkthroughPopupViewController: UIViewController {
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var scrollView: ObservingContentScrollView!
  @IBOutlet private weak var contentLabel: UILabel!
  @IBOutlet private weak var skipButton: UIButton!
  @IBOutlet private weak var nextButton: UIButton!
  
  fileprivate var wTitle: String?
  fileprivate var wAttrContent: NSAttributedString?
  fileprivate var skipTitle: String?
  fileprivate var nextTitle: String?
  fileprivate var skipDidTapped: ((WalkthroughPopupViewController) -> Void)?
  fileprivate var nextDidTapped: ((WalkthroughPopupViewController) -> Void)?
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  @IBAction private func skipTapped(_ sender: Any) {
    skipDidTapped?(self)
  }
  
  @IBAction private func nextTapped(_ sender: Any) {
    nextDidTapped?(self)
  }
}

// MARK: - ControllerProtocol
extension WalkthroughPopupViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("WalkthroughPopupViewController segueIdentifier not set")
  }
  
  public func setupUI() {
    titleLabel.attributedText = wTitle?.attributed.add([.color(.lightNavy), .font(.idealSans(style: .book(size: 18.0)))])
    contentLabel.attributedText = wAttrContent
    if let skipTitle = skipTitle, !skipTitle.isEmpty {
      skipButton.isHidden = false
      skipButton.setAttributedTitle(
        skipTitle.attributed.add([.color(.greyblue), .font(.openSans(style: .semiBold(size: 13.0)))]),
        for: .normal)
    } else {
      skipButton.isHidden = true
    }
    if let nextTitle = nextTitle, !nextTitle.isEmpty {
      nextButton.isHidden = false
      nextButton.setAttributedTitle(
        nextTitle.attributed.add([.color(.greyblue), .font(.openSans(style: .semiBold(size: 13.0)))]),
        for: .normal)
    } else {
      nextButton.isHidden = true
    }
  }
  
  public func setupController() {
  }
  
  public func setupObservers() {
    scrollView.observeContentSizeUpdates = { [weak self] (size) in
      guard let `self` = self else { return }
      self.reloadPresenter()
    }
  }
}

// MARK: PresentedControllerProtocol
extension WalkthroughPopupViewController: PresentedControllerProtocol  {
  public var presenterType: PresenterType? {
    if UIScreen.main.bounds.width <= 320.0 {
      return .popover(size: CGSize(width: UIScreen.main.bounds.width - 32.0, height: min(300.0, scrollView.contentSize.height + 140.0)))
    } else {
      return .popover(size: CGSize(width: 343.0, height: min(300.0, scrollView.contentSize.height + 140.0)))
    }
  }
}

public protocol WalkthroughPopupPresenterProtocol {
  func walkthroughPopupTitle() -> String?
  func walkthroughPopupContent() -> NSAttributedString?
  func walkthroughPopupSkipTitle() -> String?
  func walkthroughPopupNextTitle() -> String?
  
  func walkthroughPopupSkipDidTapped(walkthroughPopupViewController: WalkthroughPopupViewController)
  func walkthroughPopupNextDidTapped(walkthroughPopupViewController: WalkthroughPopupViewController)
}

extension WalkthroughPopupPresenterProtocol where Self: ControllerProtocol & UIViewController {
  public func showWalkthroughPopup(anchor: WalkthroughPopupAnchor? = nil) {
    let walkthroughPopupViewController = UIStoryboard.get(.walkthrough).getController(WalkthroughPopupViewController.self)
    walkthroughPopupViewController.wTitle = walkthroughPopupTitle()
    walkthroughPopupViewController.wAttrContent = walkthroughPopupContent()
    walkthroughPopupViewController.skipTitle = walkthroughPopupSkipTitle()
    walkthroughPopupViewController.nextTitle = walkthroughPopupNextTitle()
    walkthroughPopupViewController.skipDidTapped = { [weak self] (walkthroughPopupViewController) in
      guard let `self` = self else { return }
      self.walkthroughPopupSkipDidTapped(walkthroughPopupViewController: walkthroughPopupViewController)
    }
    walkthroughPopupViewController.nextDidTapped = { [weak self] (walkthroughPopupViewController) in
      guard let `self` = self else { return }
      self.walkthroughPopupNextDidTapped(walkthroughPopupViewController: walkthroughPopupViewController)
    }
    var appearance = PresenterAppearance.default
    appearance.dimColor = .clear
    appearance.minPadding = 16.0
    var settings: [PresenterSetting] = [.appearance(appearance)]
    if let anchor = anchor {
      settings.append(.anchor(view: anchor.view, position: anchor.position))
    }
    PresenterViewController.show(
      presentVC: walkthroughPopupViewController,
      settings: settings,
      onVC: self)
  }
}
