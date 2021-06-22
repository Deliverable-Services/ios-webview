//
//  PurchasesViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 29/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit

public protocol PurchasesView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func showError(message: String?)
}

public protocol PurchasesViewModelProtocol {
  var recipe: CoreDataRecipe { get }
  var emptyNotificationActionData: EmptyNotificationActionData? { get }
  
  func initialize()
}

public final class PurchasesViewModel: PurchasesViewModelProtocol {
  private weak var view: PurchasesView?
  
  public init(view: PurchasesView) {
    self.view = view
  }
  
  public var recipe: CoreDataRecipe {
    var recipe = CoreDataRecipe()
    recipe.sorts = [
      .custom(key: "monthYear", isAscending: false),
      .dateCreated(isAscending: false)]
    let predicates: [CoreDataRecipe.Predicate] = [
      .isEqual(key: "isActive", value: true),
      .notEqual(key: "monthYear", value: nil),
      .notEqual(key: "wcOrderID", value: nil),//remove orders without wcOrderID
      .isEqual(key: "customerID", value: AppUserDefaults.customerID)]
    recipe.predicate = CoreDataRecipe.Predicate.compoundAnd(predicates: predicates).rawValue
    return recipe
  }
  
  public var emptyNotificationActionData: EmptyNotificationActionData?
}

extension PurchasesViewModel {
  public func attachView(_ view: PurchasesView) {
    self.view = view
  }
  
  public func initialize() {
    view?.reload()
    view?.showLoading()
    PPAPIService.User.getPurchases().call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customerID = AppUserDefaults.customerID else { return }
          Purchase.parsePurchasesFromData(result.data, customerID: customerID, inMOC: moc)
        }, completion: { (_) in
          if let message = result.message, result.data.array?.isEmpty ?? true {
            self.emptyNotificationActionData = EmptyNotificationActionData(
              title: message,
              subtitle: nil,
              action: "LET'S GO SHOPPING")
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
          action: "LET'S GO SHOPPING")
        self.view?.hideLoading()
      }
    }
  }
}
