//
//  LoginEmailViewController.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 22/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit

class LoginEmailViewController: UIViewController {
  
  @IBOutlet weak var emailTextField: UITextField! {
    didSet {
      self.emailTextField.layer.borderColor = UIColor.Porcelain.whiteFour.cgColor
      self.emailTextField.layer.borderWidth = 1.0
    }
  }
  
  @IBOutlet weak var passwordTextField: UITextField! {
    didSet {
      self.passwordTextField.layer.borderColor = UIColor.Porcelain.whiteFour.cgColor
      self.passwordTextField.layer.borderWidth = 1.0
    }
  }
  
  @IBAction func signInButtonClicked() {
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
}

/****************************************************************/

private enum StoryboardIdentifier: String {
  case toQuestionnaire = "LoginEmailToQuestionnaire"
  case toDashboard = "LoginEmailToDashboard"
}

extension LoginEmailViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = StoryboardIdentifier(rawValue: segue.identifier ?? "") else {
      return
    }
    var destinationVC: UIViewController? = segue.destination
    if let navigationVC = segue.destination as? UINavigationController {
      destinationVC = navigationVC.childViewControllers.first
    }
    
    switch identifier {
    case .toQuestionnaire: break
    case .toDashboard: break
    }
  }
  
  @objc func goToQuestionnaireScreen() {
    self.performSegue(withIdentifier: StoryboardIdentifier.toQuestionnaire.rawValue, sender: nil)
  }
}

/**
 import SlackKit
 let slackkit = SlackKit()
 slackkit.addWebAPIAccessWithToken("xoxp-324445085298-323790980992-389555237664-16186a864c64fb0c2bd3220f6b23a9ac")
 
 slackkit.webAPI?.authenticationTest(success: { (a, b) in
 print(a ?? "", b ?? "")
 }, failure: nil)
 
 //    slackkit.webAPI?.sendMessage(channel: "test", text: "```Sync customer account\nEmail address: *patcesar@gmail.com*\nMobile number: *123 345 456* ```", success: { (ts, channel) in
 //      print("Success: \(String(describing: ts))  \(String(describing: channel))")
 //    }, failure: { (error) in
 //      print("Slack error: \(error)")
 //    })
 */
