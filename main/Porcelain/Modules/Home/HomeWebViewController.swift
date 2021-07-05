//
//  HomeWebViewController.swift
//  Porcelain
//
//  Created by Rajan Arora on 05/07/21.
//  Copyright © 2021 R4pid Inc. All rights reserved.
//

import UIKit
import WebKit

class HomeWebViewController: UIViewController,WKNavigationDelegate {

    
    @IBOutlet var webView: WKWebView!
    var urlString : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        guard let urlstring = urlString else {
            return
        }
        
        guard  let url = URL(string: urlstring) else {
            return
        }
        
        appDelegate.showLoading()
        webView.load(URLRequest(url: url))
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        appDelegate.showLoading()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        appDelegate.hideLoading()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        appDelegate.hideLoading()
    }

}
