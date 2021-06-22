//
//  SkinQuizResultViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 12/5/19.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import WebKit
import SwiftyJSON

public protocol SkinQuizResultViewControllerDelegate: class {
  func skinQuizResultRetakeDidTapped()
}

public final class SkinQuizResultViewController: UIViewController {
  @IBOutlet private weak var retakeSkinQuizButton: DesignableButton! {
    didSet {
      retakeSkinQuizButton.cornerRadius = 20.0
      retakeSkinQuizButton.backgroundColor = .heather
      retakeSkinQuizButton.setAttributedTitle(
        "RETAKE QUIZ".attributed.add(.appearance(DialogButtonAttributedTitleAppearance())),
        for: .normal)
    }
  }
  @IBOutlet private weak var webView: WKWebView! {
    didSet {
      webView.navigationDelegate = self
    }
  }
  
  public weak var delegate: SkinQuizResultViewControllerDelegate?
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public func loadQuizResultIfNeeded() {
    guard let url = URL(string: AppUserDefaults.customer?.skinQuizResultURL ?? "") else { return }
    webView.stopLoading()
    webView.load(URLRequest(url: url))
  }
  
  @IBAction private func retakeSkinQuizTapped(_ sender: Any) {
    delegate?.skinQuizResultRetakeDidTapped()
  }
}

// MARK: - ControllerProtocol
extension SkinQuizResultViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("SkinQuizResultViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    loadQuizResultIfNeeded()
    if JSON(parseJSON: AppUserDefaults.customer?.skinQuizAnswerRaw ?? "").isDone.boolValue {
      appDelegate.showLoading()
      PPAPIService.User.computeMySkinQuiz().call { (response) in
        switch response {
        case .success(let result):
          CoreDataUtil.performBackgroundTask({ (moc) in
            guard let customerID = AppUserDefaults.customerID else { return }
            guard let customer = Customer.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
            customer.skinQuizResultURL = result.data.redirectURL.string
          }, completion: { (_) in
            appDelegate.hideLoading()
            self.loadQuizResultIfNeeded()
          })
        case .failure(let error):
          appDelegate.hideLoading()
          self.loadQuizResultIfNeeded()
          self.showAlert(title: "Oops!", message: error.localizedDescription)
        }
      }
    }  else {
      showAlert(title: "Oops!", message: "Quiz is not done yet.")
    }
  }
  
  public func setupObservers() {
  }
}

// MARK: - WKNavigationDelegate
extension SkinQuizResultViewController: WKNavigationDelegate {
  public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    if webView.url?.absoluteString == navigationAction.request.url?.absoluteString {
      decisionHandler(.allow)
    } else {
      print("REQUEST URL: ", navigationAction.request.url ?? "")
      decisionHandler(.cancel)
    }
  }
}
