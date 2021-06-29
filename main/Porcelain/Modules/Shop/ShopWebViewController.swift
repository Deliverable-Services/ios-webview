//
//  ShopWebViewController.swift
//  Porcelain
//
//  Created by Rajan Arora on 24/06/21.
//  Copyright © 2021 R4pid Inc. All rights reserved.
//

import UIKit
import WebKit



class ShopWebViewController: UIViewController,WKNavigationDelegate {

    @IBOutlet var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self
        
        guard  let url = URL(string: "https://porcelainskin.com/shop/") else {
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
