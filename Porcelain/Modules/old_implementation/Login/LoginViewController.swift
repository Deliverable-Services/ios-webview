//
//  ViewController.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 12/05/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import UIKit
import GoogleSignIn
import KRProgressHUD

class LoginViewController: UIViewController {
  @IBOutlet weak var facebookButton: UIButton!
  @IBOutlet weak var googleButton: UIButton!
  @IBOutlet weak var emailButton: UIButton! {
    didSet {
      self.emailButton.layer.borderWidth = 1.0
      self.emailButton.layer.borderColor = UIColor.white.cgColor
    }
  }
  
  lazy var handler: LoginHandler = {
    let handler = LoginHandler()
    handler.delegate = self
    return handler
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.initializeGoogleSignInInstance()
    self.addFacebookSignIn()
    self.addGoogleSignIn()
  }
}

/****************************************************************/

// Facebook and google sign in
extension LoginViewController {
  func addFacebookSignIn() {
    self.facebookButton.addTarget(self, action: #selector(facebookSignInButtonClicked), for: .touchUpInside)
  }
  
  func addGoogleSignIn() {
    self.googleButton.addTarget(self, action: #selector(googleSignInButtonClicked), for: .touchUpInside)
  }
  
  func initializeGoogleSignInInstance() {
    GIDSignIn.sharedInstance().clientID = AppConstant.Integration.Google.clientID
    GIDSignIn.sharedInstance().delegate = self
    GIDSignIn.sharedInstance().uiDelegate = self
  }
  
  // Once the button is clicked, show the login dialog
  @objc func facebookSignInButtonClicked() {
    if AppConfiguration.disableLogin {
      self.navigate(StoryboardIdentifier.toDashboard.rawValue)
    } else {
      self.handler.connectToFacebook()
    }
  }
  
  @objc func googleSignInButtonClicked() {
    if AppConfiguration.disableLogin {
      self.navigate(StoryboardIdentifier.toDashboard.rawValue)
    } else {
      GIDSignIn.sharedInstance().signIn()
    }
  }
}

/****************************************************************/

// Google sign in
extension LoginViewController: GIDSignInDelegate, GIDSignInUIDelegate {
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    guard error == nil else {
      print(error)
      return
    }
    self.handler.connectToGoogle(user)
  }
  
  func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
    
  }
  
  func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
    self.present(viewController, animated: true, completion: nil)
  }
  
  func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
    self.dismiss(animated: true) {
      self.navigate(StoryboardIdentifier.toDashboard.rawValue)
    }
  }
  
  func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
    
  }
}

/****************************************************************/

extension LoginViewController: LoginHandlerDelegate {
  func loginHandlerWillStart(_ handler: LoginHandler, action: LoginAction) {
    KRProgressHUD.showHUD()
  }
  
  func loginHandlerSuccessful(_ handler: LoginHandler, action: LoginAction) {
    KRProgressHUD.hideHUD()
    if !AppUserDefaults.oneTimeWalkthrough {
      self.navigate(StoryboardIdentifier.toDashboard.rawValue)
    } else {
      self.navigate(StoryboardIdentifier.toQuestionnaire.rawValue)
    }
  }
  
  func loginHandlerDidFail(_ handler: LoginHandler, action: LoginAction, error: Error?) {
    KRProgressHUD.hideHUD()
  }
}

/****************************************************************/

private enum StoryboardIdentifier: String {
  case toQuestionnaire = "LoginToQuestionnaire"
  case toDashboard = "LoginToDashboard"
}
