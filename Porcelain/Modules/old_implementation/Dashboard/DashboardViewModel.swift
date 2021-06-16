//
//  DashboardViewModel.swift
//  Porcelain
//
//  Created by Justine Rangel on 26/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import SwiftyJSON


public enum DashboardSection: Int {
  case bookAnAppointment = 0, upcomingAppointments, myAppointments, myProducts
  
  public static var count: Int {
    return 4
  }
}

public protocol DashboardViewModelProtocol: DashboardDailyLogViewModelProtocol {
  func fetchNotifications()
}

public class DashboardViewModel: DashboardViewModelProtocol {
  public var dailyLogProgress: Float = 34.0
  
  lazy private var notificationsHandler = NotificationsHandler()

  public func fetchNotifications() {
    notificationsHandler.getNotifications()
  }
}
