//
//  LoginViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 22/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class LoginHandler {
  public var didLoggedIn: VoidCompletion?
}

public final class LoginViewController: UIViewController {
  private var stepsNavigationController: LoginStepsNavigationController? {
    return getChildController(LoginStepsNavigationController.self)
  }
  
  private var handler: LoginHandler!
  
  private lazy var viewModel: LoginViewModelProtocol = LoginViewModel()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    setStatusBarNav(style: .lightContent)
    hideBarSeparator()
    navigationController?.navigationBar.isTranslucent = true
    navigationController?.navigationBar.backgroundColor = .clear
  }
  
  public override func dismissViewController() {
    let stepsCount = stepsNavigationController?.childViewControllers.count ?? 1
    if stepsCount > 1 {
      generateLeftNavigationButton(image: UIImage.icClose, color: .white, selector: #selector(dismissViewController))
      stepsNavigationController?.popToRootViewController(animated: true)
    } else {
      super.dismissViewController()
    }
  }
}

// MARK: - Segue
extension LoginViewController {
  public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let stepsNavigationController = segue.destination as? LoginStepsNavigationController {
      stepsNavigationController.getChildController(WelcomeAuthMobileViewController.self)?.configure(viewModel: viewModel)
    }
  }
}
// MARK: - ControllerProtocol
extension LoginViewController: ControllerProtocol, NavigationProtocol {
  public static var segueIdentifier: String {
    fatalError("LoginViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: UIImage.icClose, color: .white, selector: #selector(dismissViewController))
    viewModel.attachView(self)
    viewModel.initialize()
  }
  
  public func setupObservers() {
    observeTapToDismiss(view: view)
  }
}

// MARK: - LoginView
extension LoginViewController: LoginView {
  public func reload() {
  }
  
  public func navigateToAuthStep(_ step: AuthenticationStep) {
    guard let stepsNavigationController = stepsNavigationController else { return }
    switch step {
    case .root:
      generateLeftNavigationButton(image: UIImage.icClose, color: .white, selector: #selector(dismissViewController))
      stepsNavigationController.popToRootViewController(animated: true)
    case .otp:
      generateLeftNavigationButton(image: UIImage.icLeftArrow, color: .white, selector: #selector(dismissViewController))
      let otpAuthMobileViewController = UIStoryboard.get(.authentication).getController(OTPAuthMobieViewController.self)
      otpAuthMobileViewController.configure(viewModel: viewModel)
      stepsNavigationController.pushViewController(otpAuthMobileViewController, animated: true)
    case .userRegistration:
      generateLeftNavigationButton(image: UIImage.icLeftArrow, color: .white, selector: #selector(dismissViewController))
      let userRegistrationViewController = UIStoryboard.get(.authentication).getController(UserRegistrationViewController.self)
      userRegistrationViewController.configure(viewModel: viewModel)
      stepsNavigationController.pushViewController(userRegistrationViewController, animated: true)
    }
  }
  
  public func loginSuccess() {
    dismiss(animated: true) { [weak self] in
      guard let `self` = self else { return }
      self.handler.didLoggedIn?()
    }
  }
  
  public func showLoading() {
    view.endEditing(true)
    appDelegate.showLoading()
  }
  
  public func hideLoading() {
    appDelegate.hideLoading()
    stepsNavigationController?.topViewController?.becomeFirstResponder()
  }
  
  public func showError(message: String?) {
    showAlert(title: "Oops!", message: message)
  }
  
  public func showOTPSuccess(message: String?, completion: @escaping VoidCompletion) {
    let dialogHandler = DialogHandler()
    dialogHandler.message = message
    dialogHandler.actions = [.confirm(title: "GOT IT!")]
    dialogHandler.actionCompletion = { (action, dialogView) in
      dialogView.dismiss()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        completion()
      }
    }
    DialogViewController.load(handler: dialogHandler).show(in: self)
  }
  
  public func showAuthenticateIssueAction(_ action: AuthenticationIssueAction) {
    switch action {
    case .retriveExistingAccount(let message):
      let dialogHandler = DialogHandler()
      dialogHandler.message = message
      dialogHandler.actions = [.cancel(title: "Cancel"), .confirm(title: "Proceed")]
      dialogHandler.actionCompletion = { [weak self] (action, dialogView) in
        dialogView.dismiss()
        guard let `self` = self else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          if action.title == "Proceed" {
            self.viewModel.sendMobileOTP()
          }
        }
      }
      DialogViewController.load(handler: dialogHandler).show(in: self)
    case .showSupport(let message, let email):
      let dialogHandler = DialogHandler()
      dialogHandler.message = message
      dialogHandler.actions = [.cancel(title: "Cancel"), .confirm(title: "Proceed")]
      dialogHandler.actionCompletion = { [weak self] (action, dialogView) in
        dialogView.dismiss()
        guard let `self` = self else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          if action.title == "Proceed" {
            appDelegate.showFreshChatWithUser(identifier: email, in: self)
          }
        }
      }
      DialogViewController.load(handler: dialogHandler).show(in: self)
    }
  }
}

// MARK: - TapToDismissProtocol
extension LoginViewController: TapToDismissProtocol {
  public func handleTapToDismiss(_ tapGesture: UITapGestureRecognizer) {
    view.endEditing(true)
  }
}

extension LoginViewController {
  public static func showLogin(handler: LoginHandler, in vc: UIViewController) {
    guard let navigationController = UIStoryboard.get(.authentication).instantiateInitialViewController() as? NavigationController else { return }
    navigationController.getChildController(LoginViewController.self)?.handler = handler
    vc.present(navigationController, animated: true) {
    }
  }
}

public final class LoginStepsNavigationController: UINavigationController {
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
}

// MARK: - ControllerProtocol
extension LoginStepsNavigationController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("LoginStepsNavigationController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    addCustomTransitioning()
  }
  
  public func setupObservers() {
  }
}
