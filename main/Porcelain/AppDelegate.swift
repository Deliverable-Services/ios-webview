
//
//  AppDelegate.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 12/05/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import FirebaseMessaging
import R4pidKit

public let appDelegate = UIApplication.shared.delegate as! AppDelegate

@UIApplicationMain
public class AppDelegate: UIResponder, UIApplicationDelegate {
  public var window: UIWindow?
  public var mainView: MainView!
  
  public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    if AppConfiguration.isProduction {
      AppUserDefaults.isProduction = true
    }
    showLogs = AppConfiguration.showLogs
    CoreDataUtil.dbName = AppConfiguration.dbName
    CoreDataUtil.showLogs = AppConfiguration.showLogs
    APIServiceConstant.isProduction = AppUserDefaults.isProduction
    APIServiceConstant.accessToken = AppUserDefaults.customer?.accessToken
    DropDownHandler.Config.type = .singleSelection(appearance: DropDownAppearance())
    configureAppDelegate(application, launchOptions: launchOptions)
  
    
    return true
  }
  
  public func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }
  
  public func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  public func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }
  
  public func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.applicationIconBadgeNumber = 0
  }
  
  public func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    AppSocketManager.shared.exitSmartMirror()
  }
  
  public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    osLogComposeInfo(#function, log: .ui)
    AppUserDefaults.deviceToken = deviceToken.map{ String(format: "%02.2hhx", $0) }.joined()
    Freshchat.sharedInstance().setPushRegistrationToken(deviceToken)
    Messaging.messaging().apnsToken = deviceToken
  }
  
  public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    osLogComposeError(error.localizedDescription, log: .default)
  }
}

// MARK: - URLRedirectionHandlerProtocol
extension AppDelegate: URLRedirectionHandlerProtocol {
  public func redirect(type: URLRedirectionType, url: URL?, link: String?) {
    appDelegate.mainView.goToTab(.scanQR)?.getChildController(ScanQRViewController.self)?.redirect(type: type, url: url, link: link)
  }
  
  public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    let urlRedirectionFlag = evaluateURLForRedirection(url: url)
    let socialHandlerFlag = SocialHandler.shared.application(app, open: url, options: options)
    return urlRedirectionFlag || socialHandlerFlag
  }
}
