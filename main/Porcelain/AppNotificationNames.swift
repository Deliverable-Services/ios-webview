//
//  AppNotificationConstants.swift
//  Porcelain
//
//  Created by Jean on 7/6/18.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import NotificationCenter

public typealias AppNotificationCenter = NotificationCenter
public typealias AppNotificationNames = NSNotification.Name
extension AppNotificationNames {
  static let appointmentsDidChange = NSNotification.Name("AppointmentsDidChange")
  static let didLogOut = NSNotification.Name("User did log out")
  static let didSync = NSNotification.Name("UserDidSync")
  static let didUpdateProfile = NSNotification.Name("DidUpdateUserProfile")
  static let didUpdateNotifications = NSNotification.Name("DidUpdateNotifications")
}
