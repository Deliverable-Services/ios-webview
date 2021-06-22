//
//  AppDelegate+ForceLogout.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 11/03/2019.
//  Copyright © 2019 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import SwiftyJSON

extension AppDelegate: PorcelainNetworkRequestDelegateProtocol {
  func checkAPIVersion() {
    networkRequest.getAPIVersion()
    
  }
  
  func requestWillStart(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction) {
    
  }
  
  func requestSuccessful(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction, result: Any?) {
    guard let r = result, let apiVersion = JSON(r).arrayValue[0].dictionaryValue["data"]?["version"].stringValue else { return }
    print("AppUserDefaults.apiVersion: \(AppUserDefaults.apiVersion)")
    print("API version: \(apiVersion)")
    
    if apiVersion != AppUserDefaults.apiVersion {
      AppUserDefaults.apiVersion = apiVersion
      let alert = UIAlertController(title: "Important Update", message: "Hi dear! This important update will log you out from app but you may log in right after clicking OK. Thank you!", preferredStyle: .alert)
      let topVC = UIApplication.topViewController()!
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
        AppDelegate.logout()
        topVC.view.window?.rootViewController?.dismissViewController()
        let mainStoryboard: UIStoryboard? = UIStoryboard.get(.main)
        let vc: UIViewController = (mainStoryboard?.instantiateInitialViewController())!
        topVC.view.window?.rootViewController = vc
        
        if !appDelegate.mainViewController.shouldLogin(reloadCompletion: {
          
        }) {
          
        }
        
      }))
      topVC.present(alert, animated: true)
    }
  }
  
  func requestDidFail(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction, error: Error?, statusCode: Int?, errorMessage: String?) {
    
  }

}

extension AppDelegate {
  static func logout() {
    AppUserDefaults.clearData()
    appDelegate.freshChatLogout()
    ShoppingCart.shared.clearItems()
  }
}
