//
//  NotificationHandler.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 10/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import R4pidKit

public enum NotificationActionType: String {
  case none = "none"
  case openWebView = "open-webview"
  case openDefaultBrowser = "open-default-browser"
  case openAppointmentDetails = "open-appointment-details"
  case refreshMyAppointments = "refresh-my-appointments"
  case refreshProfile = "refresh-profile"
  case refreshDashboard = "refresh-dashboard"
  case openProductInfo = "open-product-info"
  case openTreatmentInfo = "open-treatment-info"
}

public enum NotificationActionTrigger {
  case openAlert(title: String?, message: String?)
  case openWebView(url: String)
  case openDefaultBrowser(url: String)
  case openAppointmentDetails(appointmentID: String)
  case openMyAppointmentsAndRefresh
  case openProfileAndRefresh
  case openDashboardAndRefresh
  case openProductInfo(productID: String)
  case openTreatmentInfo(serviceID: String)
  case doNothing
}

public struct PushNotificationData {
  public struct APSAlert {
    public var title: String?
    public var body: String?
    public var sound: String?
    
    init?(data: JSON) {
      if let title = data.alert.title.string {
        self.title = title
        body = data.alert.body.string
        sound = data.sound.string
      } else if let body = data.alert.string {
        title = nil
        self.body = body
        sound = data.sound.string
      } else {
        return nil
      }
    }
  }
  
  public var alert: APSAlert
  public var id: String?
  public var trigger: NotificationActionTrigger
  public var data: JSON
  
  public init?(notificationRaw: [AnyHashable: Any]) {
    let notificationJSON = JSON(notificationRaw)
    guard let alert = APSAlert(data: notificationJSON.aps) else { return nil }
    guard let actionType = NotificationActionType(rawValue: notificationJSON.actionType.stringValue) else { return nil }
    id = notificationJSON.notificationID.string
    self.alert = alert
    data = JSON(parseJSON: notificationJSON.data.stringValue)
    switch actionType {
    case .none:
      trigger = .openAlert(title: alert.title, message: alert.body)
    case .openWebView:
      if let url = notificationJSON.url.string?.emptyToNil {
        trigger = .openWebView(url: url)
      } else {
        trigger = .openAlert(title: "Oops!", message: "URL does not exists.")
      }
    case .openDefaultBrowser:
      if let url = notificationJSON.url.string?.emptyToNil {
        trigger = .openDefaultBrowser(url: url)
      } else {
        trigger = .openAlert(title: "Oops!", message: "URL does not exists.")
      }
    case .openAppointmentDetails:
      if let appointmentID = data.appointmentID.string ?? notificationJSON.appointmentID.string {
        trigger = .openAppointmentDetails(appointmentID: appointmentID)
      } else {
        trigger = .openAlert(title: "Oops!", message: "Appointment id does not exists.")
      }
    case .refreshMyAppointments:
      trigger = .openMyAppointmentsAndRefresh
    case .refreshProfile:
      trigger = .openProfileAndRefresh
    case .refreshDashboard:
      trigger = .openDashboardAndRefresh
    case .openProductInfo:
      if let productID = notificationJSON.productID.string {
        trigger = .openProductInfo(productID: productID)
      } else {
        trigger = .openAlert(title: alert.title, message: alert.body)
      }
    case .openTreatmentInfo:
      if let serviceID = notificationJSON.serviceID.string {
        trigger = .openTreatmentInfo(serviceID: serviceID)
      } else {
        trigger = .openAlert(title: alert.title, message: alert.body)
      }
    }
  }
}

public final class NotificationHandler {
  /// Must be called on will present notification
  
  /// This is only called when the app is in foreground since it is called on will present notification; loading data  before showing the notif; this only  for  loading the alert do no action here
  /// - Parameters:
  ///   - notificationRaw: raw notification  user  info
  ///   - completion: must be called to complete the process
  public static func preparePushNotification(notificationRaw: [AnyHashable: Any], completion: VoidCompletion? = nil) {//this is only called when app is in
    let notificationJSON = JSON(notificationRaw)
    guard let actionType = NotificationActionType(rawValue: notificationJSON.actionType.stringValue) else {
      completion?()
      return
    }
    //Appointment parsing START
    let data = JSON(parseJSON: notificationJSON.data.stringValue)
    if let appointmentID = data.appointmentID.string, let customerID = data.userID.string {
      CoreDataUtil.performBackgroundTask({ (moc) in
        guard let customer = Customer.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
        let appointments = Appointment.getAppointments(appointmentIDs: [appointmentID], customerID: customerID, inMOC: moc)
        guard let appointment = Appointment.parseAppointmentFromData(data, customer: customer, appointments: appointments, inMOC: moc) else { return }
        guard let state = AppointmentState(rawValue: appointment.state ?? "") else { return }
        switch state {
        case .requested:
          appointment.type = AppointmentType.pending.rawValue
        case .reserved, .confirmed:
          appointment.type = AppointmentType.upcoming.rawValue
        default:
          appointment.type = nil
        }
      }, completion: { (_) in
        completion?()
      })
    } else {
      completion?()
    }
    //Appointment parsing END
    switch actionType {
    case .openAppointmentDetails: break
    default: break
    }
  }
  
  /// Must be called on did recieved notification
  public static func evaluatePushNotification(notificationRaw: [AnyHashable: Any], completion: VoidCompletion? = nil) {
    guard let pushNotificationData = PushNotificationData(notificationRaw: notificationRaw) else {
      completion?()
      return
    }
    if let notificationID = pushNotificationData.id {
      readNotification(notificationID: notificationID)
    }
    perform(notificationActionTrigger: pushNotificationData.trigger)
    completion?()
  }
  
  public static func evaluateNotification(_ notification: AppNotification) {
    if let notificationID = notification.id {
      readNotification(notificationID: notificationID)
    }
    guard let action = notification.action else { return }
    guard let actionType = NotificationActionType(rawValue: action) else { return }
    switch actionType {
    case .none:
      perform(notificationActionTrigger: .openAlert(title: notification.title, message: notification.message))
    case .openWebView:
      if let url = notification.url?.emptyToNil {
        perform(notificationActionTrigger: .openWebView(url: url))
      } else {
        perform(notificationActionTrigger: .openAlert(title: "Oops!", message: "URL does not exists."))
      }
    case .openDefaultBrowser:
      if let url = notification.url?.emptyToNil {
        perform(notificationActionTrigger: .openDefaultBrowser(url: url))
      } else {
        perform(notificationActionTrigger: .openAlert(title: "Oops!", message: "URL does not exists."))
      }
    case .openAppointmentDetails:
      if let appointmentID = notification.commonID {
        perform(notificationActionTrigger: .openAppointmentDetails(appointmentID: appointmentID))
      } else {
        perform(notificationActionTrigger: .openAlert(title: "Oops!", message: "Appointment id does not exists."))
      }
    case .refreshProfile:
      perform(notificationActionTrigger: .openProfileAndRefresh)
    case .refreshMyAppointments:
      perform(notificationActionTrigger: .openMyAppointmentsAndRefresh)
    case .refreshDashboard:
      perform(notificationActionTrigger: .openDashboardAndRefresh)
    case .openProductInfo:
      if let productID = notification.commonID {
        perform(notificationActionTrigger: .openProductInfo(productID: productID))
      } else {
        perform(notificationActionTrigger: .openAlert(title: "Oops!", message: "Product id does not exists."))
      }
    case .openTreatmentInfo:
      if let serviceID = notification.commonID {
        perform(notificationActionTrigger: .openTreatmentInfo(serviceID: serviceID))
      } else {
        perform(notificationActionTrigger: .openAlert(title: "Oops!", message: "Service id does not exists."))
      }
    }
  }
  
  private static func perform(notificationActionTrigger: NotificationActionTrigger) {
    switch notificationActionTrigger {
    case .openAlert(let title, let message):
      guard let topViewController = UIApplication.shared.topViewController() else { return }
      topViewController.showAlert(title: title, message: message)
    case .openWebView(let url):
      UIApplication.shared.inAppSafariOpen(url: url)
    case .openDefaultBrowser(let url):
      guard let url = URL(string: url) else { return }
      UIApplication.shared.open(url, options: [:]) { (_) in}
    case .openAppointmentDetails(let appointmentID):
      guard let topViewController = UIApplication.shared.topViewController() else { return }
      guard let customerID = AppUserDefaults.customerID else { return }
      appDelegate.showLoading()
      PPAPIService.Appointment.getAppointment(appointmentID: appointmentID).call { (response) in
        switch response {
        case .success(let result):
          CoreDataUtil.performBackgroundTask({ (moc) in
            guard let customer = User.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
            let appointments = Appointment.getAppointments(appointmentIDs: [appointmentID], customerID: customerID, inMOC: moc)
            guard let appointment = Appointment.parseAppointmentFromData(result.data, customer: customer, appointments: appointments, inMOC: moc) else { return }
            guard let state = AppointmentState(rawValue: appointment.state ?? "") else { return }
            switch state {
            case .requested:
              appointment.type = AppointmentType.pending.rawValue
            case .reserved, .confirmed:
              appointment.type = AppointmentType.upcoming.rawValue
            default: break
            }
          }, completion: { (_) in
            appDelegate.hideLoading()
            if let appointment = Appointment.getAppointment(id: appointmentID, customerID: customerID) {
              if let state = AppointmentState(rawValue: appointment.state ?? "") {
                switch state {
                case .cancelled:
                  self.perform(notificationActionTrigger: .openAlert(title: nil, message: "Appointment has been cancelled already."))
                case .rejected:
                  self.perform(notificationActionTrigger: .openAlert(title: nil, message: "Appointment has been rejected already."))
                case .confirmed, .reserved, .requested:
                  AppointmentPopupViewController.load(withAppointment: appointment).show(in: topViewController)
                case .done:
                  self.perform(notificationActionTrigger: .openAlert(title: nil, message: "Appointment is already done."))
                }
              } else {
                self.perform(notificationActionTrigger: .openAlert(title: "Oops!", message: "Appontment state is undefined."))
              }
            } else {
              self.perform(notificationActionTrigger: .openAlert(title: "Oops!", message: "Appointment could not be saved."))
            }
          })
        case .failure(let error):
          appDelegate.hideLoading()
          self.perform(notificationActionTrigger: .openAlert(title: "Oops!", message: error.localizedDescription))
        }
      }
    case .openMyAppointmentsAndRefresh:
      guard let navigationController = appDelegate.mainView.goToTab(.home) else { return }
      if  let myAppointmentsViewController = navigationController.getChildController(MyAppointmentsViewController.self) {
        myAppointmentsViewController.initialize()
      } else {
        navigationController.getChildController(HomeViewController.self)?.showMyAppointments()
      }
    case .openProfileAndRefresh:
      appDelegate.mainView.goToTab(.profile)?.getChildController(ProfileViewController.self)?.initialize()
    case .openDashboardAndRefresh:
      appDelegate.mainView.goToTab(.home)?.getChildController(HomeViewController.self)?.initialize()
    case .openProductInfo(let productID):
      appDelegate.showLoading()
      PPAPIService.getProducts().call { (response) in
        switch response {
        case .success(let result):
          CoreDataUtil.performBackgroundTask({ (moc) in
            result.data.arrayValue.forEach { (data) in
              guard let category = data.name.string else { return }
              Product.parseProductsFromData(data.products, category: category, inMOC: moc)
            }
          }, completion: { (_) in
            appDelegate.hideLoading()
            if Product.getProduct(id: productID) != nil {
              self.perform(notificationActionTrigger: .openProductInfo(productID: productID))
            } else {
              self.perform(notificationActionTrigger: .openAlert(title: "Oops!", message: "Product not available."))
            }
          })
        case .failure(let error):
          appDelegate.hideLoading()
          self.perform(notificationActionTrigger: .openAlert(title: "Oops!", message: error.localizedDescription))
        }
      }
    case .openTreatmentInfo(let serviceID):
      if let treatment = Treatment.getTreatment(id: serviceID) {
        guard let navigationController = appDelegate.mainView.goToTab(.shop) else { return }
        navigationController.popToRootViewController(animated: true)
        navigationController.getChildController(ShopViewController.self)?.showTreatment(treatment)
      } else {
        appDelegate.showLoading()
        PPAPIService.Center.getAllServices().call { (response) in
          switch response {
          case .success(let result):
            CoreDataUtil.performBackgroundTask({ (moc) in
              Treatment.parseTreatmentsFromData(result.data, inMOC: moc)
            }, completion: { (_) in
              appDelegate.hideLoading()
              if Treatment.getTreatment(id: serviceID) != nil {
                self.perform(notificationActionTrigger: .openTreatmentInfo(serviceID: serviceID))
              } else {
                self.perform(notificationActionTrigger: .openAlert(title: "Oops!", message: "Treatment not available."))
              }
            })
          case .failure(let error):
            appDelegate.hideLoading()
            self.perform(notificationActionTrigger: .openAlert(title: "Oops!", message: error.localizedDescription))
          }
        }
      }
    case .doNothing: break
    }
  }
  
  public static func readNotification(notificationID: String) {
    PPAPIService.User.readMyNotification(notificationID: notificationID).call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customerID = AppUserDefaults.customerID else { return }
          guard let customer = Customer.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
          guard let notificationID = result.data.id.numberString else { return }
          let notifications = AppNotification.getNotifications(notificationIDs: [notificationID], customerID: customerID, inMOC: moc)
          AppNotification.parseNotificationFromData(result.data, customer: customer, notifications: notifications, inMOC: moc)
        }, completion: { (_) in
        })
      case .failure: break
      }
    }
  }
}

extension Notification.Name {
  public static let didReceiveNotification = Notification.Name("didReceiveNotification")
}
