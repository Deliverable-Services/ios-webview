//
//  AppConfiguration.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 21/05/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

public class AppConfiguration {
  /// Set the app's environment
  public static var isProduction = true
  /// force app to use debug login using phone number only; only applicable on AppUserDefaults.isProduction == false
  public static let debugLoginWithPhone = false
  /// appointment default cancel hours
  public static let appointmentMinCancelHours: Int = 72
  /// enable/disable walkthrough
  public static let enableWalkthrough = true
  /// core data created database name; must be same as the xcdatamodelId file
  public static let dbName = "Porcelain"
  /// print the log in the  app
  public static let showLogs = false
  /// force app to  update when new update on appstore
  public static let forceUpdate = true
  /// enable/disable dev payment for testing; will use stripe key test if true, stripe key live if false
  public static let useDevPayment = false
  /// enable/disable apple pay
  public static let enableApplePay = true
  /// enable/disable social login (show/hide)
  public static let enableSocialLogin = false
  /// used in apple review to force login with this number
  public static let appleTestPhone = "94884399"//"98009174"//"9158012509"//"87429769"//"9777246746"
}

public enum TestUsers {
}
