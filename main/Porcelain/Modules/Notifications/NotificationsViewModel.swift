//
//  NotificationsViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 10/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit

public protocol NotificationsView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func showError(message: String?)
}

public protocol NotificationsViewModelProtocol {
  var notificationsRecipe: CoreDataRecipe { get }
  var emptyNotificationActionData: EmptyNotificationActionData? { get }
  
  func initialize()
  func markNotificationAsRead(notificationID: String)
}

public final class NotificationsViewModel: NotificationsViewModelProtocol {
  private weak var view: NotificationsView?
  public init(view: NotificationsView) {
    self.view = view
  }
  
  public var notificationsRecipe: CoreDataRecipe {
    var recipe = CoreDataRecipe()
    recipe.sorts = [.custom(key: "dateCreated", isAscending: false)]
    let predicates: [CoreDataRecipe.Predicate] = [.isEqual(key: "customer.id", value: AppUserDefaults.customerID)]
    recipe.predicate = CoreDataRecipe.Predicate.compoundAnd(predicates: predicates).rawValue
    return recipe
  }
  public var emptyNotificationActionData: EmptyNotificationActionData?
}

extension NotificationsViewModel {
  public func initialize() {
    view?.reload()
    view?.showLoading()
    PPAPIService.User.getMyNotifications().call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customerID = AppUserDefaults.customerID else { return }
          guard let customer = User.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
          AppNotification.parseNotificationsFromData(result.data, customer: customer, inMOC: moc)
        }, completion: { (_) in
          if let message = result.message, result.data.array?.isEmpty ?? true {
            self.emptyNotificationActionData = EmptyNotificationActionData(
              title: message,
              subtitle: nil,
              action: nil)
          } else {
            self.emptyNotificationActionData = nil
          }
          self.view?.hideLoading()
          self.view?.reload()
        })
      case .failure(let error):
        self.emptyNotificationActionData = EmptyNotificationActionData(
          title: error.localizedDescription,
          subtitle: nil,
          action: nil)
        self.view?.hideLoading()
      }
    }
  }
  
  public func markNotificationAsRead(notificationID: String) {

  }
}
