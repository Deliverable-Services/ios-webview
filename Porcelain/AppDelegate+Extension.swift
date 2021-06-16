//
//  AppDelegate+Extensions.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 22/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import Stripe
import CardScan
import Siren
import UserNotifications
import NVActivityIndicatorView
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import R4pidKit
import os.log
import YPImagePicker

extension AppDelegate {
  public func showAlert(title: String?, message: String?) {
    guard let topViewController = UIApplication.shared.topViewController() else { return }
    let dialogHandler = DialogHandler()
    dialogHandler.title = title
    dialogHandler.message = message
    dialogHandler.actions = [.confirm(title: "GOT IT!")]
    DialogViewController.load(handler: dialogHandler).show(in: topViewController)
  }
  
  public func showLoading(message: String? = nil) {
    let data = ActivityData(message: message, type: .circleStrokeSpin)
    NVActivityIndicatorPresenter.sharedInstance.startAnimating(data, nil)
  }
  
  public func hideLoading() {
    NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
  }
  
  public func freshChatRegisterIfPossible() {
    guard let customer = AppUserDefaults.customer else { return }
    let user = FreshchatUser.sharedInstance()
    user.firstName = customer.firstName
    user.lastName = customer.lastName
    user.email = customer.email
    user.phoneCountryCode = customer.phoneCode
    user.phoneNumber = customer.phone
    if let email = customer.email {
      Freshchat.sharedInstance().identifyUser(withExternalID: email, restoreID: nil)
    }
    Freshchat.sharedInstance().setUser(user)
  }
  
  public func showFreshChatWithUser(identifier: String, in vc: UIViewController) {
    Freshchat.sharedInstance().identifyUser(withExternalID: identifier, restoreID: nil)
    Freshchat.sharedInstance().showConversations(vc)
  }
  
  public func freshChatShowConversations(in vc: UIViewController) {
    Freshchat.sharedInstance().showConversations(vc)
  }
  
  public func freshChatLogout() {
    Freshchat.sharedInstance().resetUser() {
    }
  }
  
  public func logout() {
    APIServiceConstant.accessToken = nil
    freshChatLogout()
    AppUserDefaults.clearData()
    mainView.resetTabs()
    mainView.goToTab(.home)
  }
  
  public func preloadAPIsIfNeeded() {
    guard AppUserDefaults.isLoggedIn else { return }
    PPAPIService.Center.getCenters().call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          Center.parseCentersFromData(result.data, inMOC: moc)
        }, completion: { (_) in
        })
      case .failure: break
      }
    }
  }
}

public protocol AppDelegateExtensionProtocol {
  func configureSocial(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
  func configureSiren()
  func configureStripe()
  func configureFirebaseIndentityIfNeeded()
  func configurePushNotification()
  func configureFreshChat(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
  func configurePreload()
}

extension AppDelegateExtensionProtocol {
  public func configureAppDelegate(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    os_log(
      """
%{public}@
DIR: %{public}@
APP NAME: %{public}@
APP VERSION: %{public}@
APP BUILD: %{public}@
IS DEVELOPMENT: %{public}@
""",
      log: .application,
      type: .info,
      #function, dirPaths.joined(separator: "\n"), AppMainInfo.identifier ?? "", AppMainInfo.version ?? "", AppMainInfo.build ?? "", concatenate(!AppUserDefaults.isProduction))
    
    configureSocial(application: application, launchOptions: launchOptions)
    configureSiren()
    configureStripe()
    configurePushNotification()
    configureFreshChat(application: application, launchOptions: launchOptions)
    configurePreload()
    
    //do more...
    UINavigationBar.appearance().titleTextAttributes = NavigationTheme.white.titleTextAttributes
    UINavigationBar.appearance().tintColor = NavigationTheme.white.tintColor
    UINavigationBar.appearance().tintColor = NavigationTheme.white.barTintColor
    UIBarButtonItem.appearance().setTitleTextAttributes(NavigationTheme.white.titleTextAttributes, for: .normal)
    
    var config = YPImagePickerConfiguration()
    config.showsPhotoFilters = false
    config.hidesStatusBar = false
    config.onlySquareImagesFromCamera = false
    config.shouldSaveNewPicturesToAlbum = false
    config.albumName = "PorcelainSkin"
    config.library.isSquareByDefault = false
    config.colors.tintColor = .lightNavy
    YPImagePickerConfiguration.shared = config
  }
}

// MARK: - AppDelegateExtensionProtocol
extension AppDelegate: AppDelegateExtensionProtocol {
  public func configureSocial(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
    FirebaseApp.configure()
    SocialHandler.shared.configureOnLaunch(application: application, launchOptions: launchOptions)
  }
  
  public func configureSiren() {
    let siren = Siren.shared
    siren.presentationManager = PresentationManager(
      alertTitle: "App Update Available",
      alertMessage: "Hi there! A new version of Porcelain app is available now. Please update from AppStore to get the latest version.",
      updateButtonTitle: "Update",
      nextTimeButtonTitle: "Next time",
      skipButtonTitle: "Skip this version")
    if AppConfiguration.forceUpdate {
      siren.rulesManager = RulesManager(globalRules: .critical)
    } else {
      siren.rulesManager = RulesManager(globalRules: .default)
    }
    siren.wail()
  }
  
  public func configureStripe() {
    Stripe.setDefaultPublishableKey(AppConstant.Integration.Stripe.publishableKey)
    ScanViewController.configure()
  }
  
  public func configureFirebaseIndentityIfNeeded() {
    guard let customer = AppUserDefaults.customer else { return }
    Analytics.setUserID(customer.id)
    // Firebase set user id
    if let email = customer.email {
      Analytics.setUserProperty(email, forName: "customer_email")
    }
    if let phone = [customer.phoneCode, customer.phone].compactMap({ $0 }).joined().prependPlusIfNeeded().emptyToNil {
      Analytics.setUserProperty(phone, forName: "customer_phone")
    }
  }
  
  public func configurePushNotification() {
    UNUserNotificationCenter.current().delegate = self
    Messaging.messaging().delegate = self
    
    UNUserNotificationCenter.current().getNotificationSettings { (settings) in
      switch settings.authorizationStatus {
      case .authorized, .denied: break
      default:
        self.requestAuthorization()
      }
    }
    
    UIApplication.shared.registerForRemoteNotifications()
  }
  
  public func configureFreshChat(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    let freshChatConfig = FreshchatConfig(
      appID: AppConstant.Integration.FreshChat.appID,
      andAppKey: AppConstant.Integration.FreshChat.appKey)
    freshChatConfig.gallerySelectionEnabled = true
    freshChatConfig.cameraCaptureEnabled = true
    freshChatConfig.teamMemberInfoVisible = true
    freshChatConfig.showNotificationBanner = true
    Freshchat.sharedInstance().initWith(freshChatConfig)
    if let info = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
      if Freshchat.sharedInstance().isFreshchatNotification(info) {
        Freshchat.sharedInstance().handleRemoteNotification(info, andAppstate: application.applicationState)
      }
    }
  }
  
  public func configurePreload() {
    preloadAPIsIfNeeded()
    freshChatRegisterIfPossible()
  }
}

// MARK: - Notifications
extension AppDelegate {
  public func requestAuthorization() {
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (granted, error) in
      if granted {
      } else {
      }
    }
  }
  
  public func updateFCMTokenIfNeeded() {
    guard AppUserDefaults.isLoggedIn else {
      osLogComposeInfo("FCM Not updated User is not logged in.", log: .default)
      return
    }
    if let fcmToken = Messaging.messaging().fcmToken {
      PPAPIService.User.updateFCMToken(fcmToken).call {(_) in}
    } else {
      InstanceID.instanceID().instanceID { (result, error) in
        if let error = error {
          osLogComposeError(error.localizedDescription, log: .network)
        } else if let result = result {
          r4pidLog("FCM token: ", result.token)
          self.updateFCMTokenIfNeeded()
        }
      }
    }
  }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
  public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    osLogComposeDebug("\(#function) : \(userInfo)", log: .network)
    if Freshchat.sharedInstance().isFreshchatNotification(userInfo) {
      completionHandler([.sound])
    } else {
      NotificationHandler.preparePushNotification(notificationRaw: userInfo) {
        completionHandler([.alert, .sound])
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.sendDidRecieveNotification), object: nil)
        self.perform(#selector(self.sendDidRecieveNotification), with: nil, afterDelay: 1.0)
      }
    }
  }
  
  public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    osLogComposeDebug("\(#function) : \(userInfo)", log: .network)
    if Freshchat.sharedInstance().isFreshchatNotification(userInfo) {
      Freshchat.sharedInstance().handleRemoteNotification(userInfo, andAppstate: UIApplication.shared.applicationState)
      completionHandler()
    } else {
      NotificationHandler.evaluatePushNotification(notificationRaw: userInfo, completion: completionHandler)
    }
  }
  
  @objc private func sendDidRecieveNotification() {
    NotificationCenter.default.post(name: .didReceiveNotification, object: nil)//called to reload notification badge if needed
  }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
  public func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
    osLogComposeInfo("\(#function) : \(remoteMessage.appData)", log: .ui)
  }
  
  public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    osLogComposeInfo(#function, log: .ui)
    updateFCMTokenIfNeeded()
  }
}
