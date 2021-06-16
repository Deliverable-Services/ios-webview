//
//  MainViewController.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 22/05/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct Constant {
  static let defaultScreen: TabIndex = .shop
}

public enum TabIndex: Int {
  case home = 0, scanQR, porcelain, profile, shop
}

public protocol MainView {
  var selectedTab: TabIndex { get }
  var selectedTabBar: UITabBarItem? { get }
  var selectedVC: UIViewController? { get }
  var selectedNavC: NavigationController? { get }
  
  @discardableResult
  func goToTab(_ tab: TabIndex) -> NavigationController?
  func resetTabs()
  func showLogin(completion: @escaping VoidCompletion)
  func validateSession(loginCompletion: @escaping VoidCompletion, validCompletion: @escaping VoidCompletion)
}

public final class MainViewController: UITabBarController {
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    appDelegate.mainView = self
    delegate = self
  }
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    appDelegate.mainView = self
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    updateTabBars()
  }
}

// MARK: - UITabBarControllerDelegate
extension MainViewController: UITabBarControllerDelegate {
  public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    let index = tabBarController.viewControllers?.index(of: viewController)
    if index == 1 && AppUserDefaults.isLoggedIn == false {
      appDelegate.mainView.validateSession(loginCompletion: {
        self.goToTab(TabIndex.scanQR)
      }) {
        self.goToTab(TabIndex.scanQR)
      }
      return false
    }
    return true
  }
}

// MARK: - APIServiceError401HandlerProtocol
extension MainViewController: APIServiceError401HandlerProtocol {
  public func didReceiveError401(notification: Notification) {
    guard AppUserDefaults.isLoggedIn else { return }
    let dialogHandler = DialogHandler()
    dialogHandler.message = "Your session has expired and You have been logged out."
    dialogHandler.actions = [.confirm(title: "GOT IT!")]
    dialogHandler.actionCompletion = { (dialogAction, dialogView) in
      dialogView.dismiss()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        appDelegate.logout()
      }
    }
    DialogViewController.load(handler: dialogHandler).show(in: self)
  }
}

// MARK: - ControllerProtocol
extension MainViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    return "showMainViewController"
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
//    guard !AppUserDefaults.isLoggedIn else { return }
//    selectedIndex = Constant.defaultScreen.rawValue
  }
  
  public func setupObservers() {
    observeError401()
  }
}

extension MainViewController {
  private func updateTabBars() {
    tabBar.tintColor = .lightNavy
    guard let tabItems = tabBar.items else { return }
    tabItems.enumerated().forEach { (offset, tabItem) in
      switch offset {
      case 0:
        updateTabBarItem(tabItem, title: "HOME", image: .icTabHome)
      case 1:
        updateTabBarItem(tabItem, title: "SCAN QR", image: .icTabScanQR)
      case 2:
        updateTabBarItem(tabItem, title: "PORCELAIN", image: .icTabPorcelain)
      case 3:
        updateTabBarItem(tabItem, title: "PROFILE", image: .icTabProfile)
      case 4:
        updateTabBarItem(tabItem, title: "SHOP", image: .icTabShop)
      default: break
      }
    }
  }
  
  private struct TabAttributedTitleAppearance: AttributedStringAppearanceProtocol {
    var characterSpacing: Double? {
      return 0.5
    }
    var alignment: NSTextAlignment?
    var lineBreakMode: NSLineBreakMode?
    var minimumLineHeight: CGFloat?
    var font: UIFont? {
      return .openSans(style: .semiBold(size: 10.0))
    }
    var color: UIColor?
  }
  
  private func updateTabBarItem(_ tabBarItem: UITabBarItem, title: String, image: UIImage) {
    tabBarItem.title = title.localized()
    tabBarItem.image = image.maskWithColor(.bluishGrey)
    tabBarItem.selectedImage = image.maskWithColor(.lightNavy)
    tabBarItem.titlePositionAdjustment =  .zero
    var tabAttributedTitleAppearance = TabAttributedTitleAppearance()
    tabAttributedTitleAppearance.color = .bluishGrey
    tabBarItem.setTitleTextAttributes(
      NSAttributedString.createAttributes([
        .appearance(tabAttributedTitleAppearance)]),
      for: .normal)
    tabAttributedTitleAppearance.color = .lightNavy
    tabBarItem.setTitleTextAttributes(
      NSAttributedString.createAttributes([
        .appearance(tabAttributedTitleAppearance)]),
      for: .selected)
  }
}

// MARK: - MainView
extension MainViewController: MainView {
  public var selectedTab: TabIndex {
    return TabIndex(rawValue: selectedIndex)!
  }
  
  public var selectedTabBar: UITabBarItem? {
    return tabBar.items?[selectedIndex]
  }
  
  public var selectedVC: UIViewController? {
    return selectedViewController
  }
  
  public var selectedNavC: NavigationController? {
    if let selectedNavigationController = selectedViewController as? NavigationController {
      return selectedNavigationController
    } else {
      return selectedViewController?.navigationController as? NavigationController
    }
  }
  
  @discardableResult
  public func goToTab(_ tab: TabIndex) -> NavigationController? {
    selectedIndex = tab.rawValue
    return viewControllers?[selectedIndex] as? NavigationController
  }
  
  public func resetTabs() {
    for navC in (viewControllers as? [NavigationController]) ?? [] {
      navC.popToRootViewController(animated: false)
    }
  }
  
  public func showLogin(completion: @escaping VoidCompletion) {
    let handler = LoginHandler()
    handler.didLoggedIn = { [weak self] in
      guard let `self` = self else { return }
      if appDelegate.hasPendingMainWalkthrough {
        self.resetTabs()
        self.goToTab(.home)
      } else {
        completion()
      }
    }
    LoginViewController.showLogin(handler: handler, in: self)
  }
  
  public func validateSession(loginCompletion: @escaping VoidCompletion, validCompletion: @escaping VoidCompletion) {
    if AppUserDefaults.isLoggedIn {
      validCompletion()
    } else {
      let handler = DialogHandler()
      handler.message = """
Not logged in.
Please log in to continue.
"""
      handler.actions = [.confirm(title: "LOG IN")]
      handler.actionCompletion = { [weak self] (dialogAction, dialogView) in
        guard let `self` = self else { return }
        dialogView.dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          self.showLogin(completion: loginCompletion)
        }
      }
      PresenterViewController.show(
        presentVC: DialogViewController.load(handler: handler),
        settings: [
          .appearance(.default),
          .panToDismiss,
          .tapToDismiss],
        onVC: self)
    }
  }
}
