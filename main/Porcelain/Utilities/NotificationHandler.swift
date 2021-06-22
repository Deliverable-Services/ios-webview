//
//  NotificationHandler.swift
//  Porcelain
//
//  Created by Justine on 06/02/2019.
//  Copyright © 2019 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

//action:
//`none` - do nothing, just open app
//`open-webview` - just open a modal webview and load *url*
//`open-default-browser` - just redirect to default web browser  then open the *url*
//`open-appointment-details` - go to appointment details
//`refresh-profile` - go to profile screen and refresh
//`refresh-my-appointments` - go to my appoinments screen and refresh
//`refresh-dashboard` - go to dashboard and refresh dashboard
public enum NotificationActionType: String {
  case none = "none"
  case openWebView = "open-webview"
  case openDefaultBrowser = "open-default-browser"
  case openAppointmentDetails = "open-appointment-details"
  case refreshProfile = "refresh-profile"
  case refreshMyAppointments = "refresh-my-appointments"
  case refreshDashboard = "refresh-dashboard"
}

public enum NotificationActionTrigger {
  case openWebView(url: String?)
  case openDefaultBrowser(url: String?)
  case openAppointmentDefails(appointment: Appointment?)
  case openProfileAndRefresh
  case openMyAppointmentsAndRefresh
  case openDashboardAndRefresh
}


public struct PushNotificationData {
  public struct APSAlert {
    public var title: String?
    public var body: String?
    
    init(json: JSON) {
      title = json[PorcelainAPIConstant.Key.alert][PorcelainAPIConstant.Key.title].string
      body = json[PorcelainAPIConstant.Key.alert][PorcelainAPIConstant.Key.body].string
    }
  }
  public var id: String
  public var action: NotificationActionType
  public var type: String?
  public var aps: APSAlert?
  public var appointmentID: String?
  public var appointment: Appointment?
  public var url: String?
  
  public static func generate(notificationRaw: [AnyHashable: Any]) -> PushNotificationData? {
    let notificationJSON = JSON(notificationRaw)
    guard let id = notificationJSON[PorcelainAPIConstant.Key.notificationID].string else { return nil }
    guard let actionRaw = AppConfiguration.notificationTestAction ?? notificationJSON[PorcelainAPIConstant.Key.action].string else { return nil } //notification must contain action
    guard let action = NotificationActionType(rawValue: actionRaw) else { return nil }
    let url = notificationJSON["url"].string
    var appointment: Appointment?
    if let appointmetRaw = JSON(notificationRaw)[PorcelainAPIConstant.Key.appointment].string {
      appointment = Appointment.object(from: JSON(parseJSON: appointmetRaw))
      appointment?.user = User.getUserAccount()
    }
    return PushNotificationData(
      id: id,
      action: action,
      type: notificationJSON[PorcelainAPIConstant.Key.type].string,
      aps: APSAlert(json: notificationJSON[PorcelainAPIConstant.Key.aps]),
      appointmentID: notificationJSON[PorcelainAPIConstant.Key.appointmentID].string,
      appointment: appointment,
      url: url)
  }
}

public final class NotificationHandler {
  public static func evaluatePushNotification(notificationRaw: [AnyHashable: Any]) {
    guard let pushNotificationData = PushNotificationData.generate(notificationRaw: notificationRaw) else { return }
    evaluateNotificationType(pushNotificationData.action, appointment: pushNotificationData.appointment, url: pushNotificationData.url)
  }
  
  public static func evaluateAppNotification(_ appNotification: AppNotification) {
    guard let action = appNotification.action else { return }
    guard let notificationType = NotificationActionType(rawValue: AppConfiguration.notificationTestAction ?? action) else { return }
    evaluateNotificationType(notificationType, appointment: appNotification.appointment, url: nil)
  }
  
  private static func evaluateNotificationType(_ notificationType: NotificationActionType, appointment: Appointment?,  url: String?) {
    switch notificationType {
    case .none: break //do nothing
    case .openWebView:
      if let url = url {
        print("OPEN URL: \(url)")
        perform(notificationActionTrigger: .openWebView(url: url))
      }
    case .openDefaultBrowser:
      if let url = url {
        print("OPEN DEFAULT URL: \(url)")
        perform(notificationActionTrigger: .openDefaultBrowser(url: url))
      }
    case .openAppointmentDetails:
      print("OPEN APPOINTMENT DETAILS")
      guard appointment != nil && appointment?.id != "" else {
        AlertViewController.loadAlertWithContent(
          "This appointment has been deleted".localized(),
          actions: ["OK".localized()])
          .show(in: appDelegate.mainViewController)
        return
      }
      perform(notificationActionTrigger: .openAppointmentDefails(appointment: appointment))
    case .refreshProfile:
      print("REFRESH PROFILE")
      perform(notificationActionTrigger: .openProfileAndRefresh)
    case .refreshMyAppointments:
      print("REFRESH MY APPOINTMENTS")
      perform(notificationActionTrigger: .openMyAppointmentsAndRefresh)
    case .refreshDashboard:
      print("REFRESH DASHBOARD")
      perform(notificationActionTrigger: .openDashboardAndRefresh)
    }
  }
  
  private static func perform(notificationActionTrigger: NotificationActionTrigger) {
    switch notificationActionTrigger {
    case .openWebView(let url):
      guard let url = URL(string: url ?? "") else { return }
      let webViewController = UIStoryboard.get(.main).getController(WebViewController.self)
      webViewController.url = url
      appDelegate.mainViewController.present(NavigationController(rootViewController: webViewController), animated: true) {}
    case .openDefaultBrowser(let url):
      guard let url = URL(string: url ?? "") else { return }
      UIApplication.shared.open(url, options: [:]) { (_) in}
    case .openAppointmentDefails(let appointment):
      guard let appointment = appointment, let navigationController = findSelectedNavigationController() else { return }
      let myAppointmentViewController = UIStoryboard.get(.myTreatment).getController(MyAppointmentViewController.self)
      myAppointmentViewController.initFromNotification(appointment: AppointmentStruct.object(from: appointment))
      navigationController.pushViewController(myAppointmentViewController, animated: true)
    case .openProfileAndRefresh:
      guard let profileViewController  = UIStoryboard.get(.profile).instantiateInitialViewController() else { return }
      appDelegate.mainViewController.present(profileViewController, animated: true) {}
    case .openMyAppointmentsAndRefresh:
      guard let navigationController = findSelectedNavigationController() else { return }
      let appointmentViewController = UIStoryboard.get(.myTreatment).getController(AppointmentViewController.self)
      navigationController.pushViewController(appointmentViewController, animated: true)
    case .openDashboardAndRefresh:
      findSelectedNavigationController()?.popToRootViewController(animated: true)
      appDelegate.mainViewController.goToTab(.dashboard)
      AppNotificationCenter.default.post(name: .didSync, object: nil)
    }
  }
  
  private static func findSelectedNavigationController() -> NavigationController? {
    return appDelegate.mainViewController.selectedViewController as? NavigationController
  }
}

