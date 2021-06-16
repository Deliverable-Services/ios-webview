//
//  WebViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 7/18/19.
//  Copyright © 2018 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import R4pidKit

public struct WebViewConfig {
  var title: String?
  var topSpacing: CGFloat = 0
  var url: String?
}

public final class WebViewController: UIViewController {
  @IBOutlet private weak var webView: WKWebView!
  @IBOutlet private weak var topConstraint: NSLayoutConstraint!
  
  fileprivate var config: WebViewConfig!
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
}

// MARK: - NavigationProtocol
extension WebViewController: NavigationProtocol {
}

// MARK: - ControllerProtocol
extension WebViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    return "showWebView"
  }
  
  public func setupUI() {
    navigationItem.title = config.title
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: #imageLiteral(resourceName: "ic-left-arrow"), selector: #selector(popOrDismissViewController))
    guard let url = URL(string: config.url ?? "") else { return }
    osLogComposeDebug("will open URL: \(url.absoluteString)", log: .ui)
    let request = URLRequest(url: url)
    webView.load(request)
    webView.navigationDelegate = self
    topConstraint.constant = config.topSpacing
  }
  
  public func setupObservers() {
  }
}

// MARK: - WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {
  public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    if navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    decisionHandler(.allow)
  }
  public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    guard let url = webView.url else { return }
    osLogComposeDebug("did open URL: \(url.absoluteString)", log: .ui)
  }
}

extension UIViewController {
  public func showWebView(config: WebViewConfig, animated: Bool = true) {
    let webViewController = UIStoryboard.get(.settings).getController(WebViewController.self)
    webViewController.config = config
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(webViewController, animated: animated)
    } else {
      let navigationController = NavigationController(rootViewController: webViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
  }
}
