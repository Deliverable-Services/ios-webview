//
//  MyProductsViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 27/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit

public protocol MyProductsView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func showError(message: String?)
}

public protocol MyProductsViewModelProtocol {
  var myProductsRecipe: CoreDataRecipe { get }
  var emptyNotificationActionData: EmptyNotificationActionData? { get }
  
  func attachView(_ view: MyProductsView)
  func initialize()
}

public final class MyProductsViewModel: MyProductsViewModelProtocol {
  private weak var view: MyProductsView?
  
  public var myProductsRecipe: CoreDataRecipe {
    var recipe = CoreDataRecipe()
    recipe.sorts = [
      .custom(key: "datePurchased", isAscending: false),
      .custom(key: "id", isAscending: false)]
    recipe.predicate = CoreDataRecipe.Predicate.compoundAnd(predicates: [
      .isEqual(key: "isActive", value: true),
      .isEqual(key: "customerID", value: AppUserDefaults.customerID)]).rawValue
    return recipe
  }
  
  public var emptyNotificationActionData: EmptyNotificationActionData?
}

extension MyProductsViewModel {
  public func attachView(_ view: MyProductsView) {
    self.view = view
  }
  
  public func initialize() {
    view?.reload()
    view?.showLoading()
    PPAPIService.User.getMyProducts().call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customerID = AppUserDefaults.customerID else { return }
          CustomerProduct.parseProductsFromData(result.data, customerID: customerID, inMOC: moc)
        }, completion: { (_) in
          if let message = result.message, result.data.array?.isEmpty ?? true {
            self.emptyNotificationActionData = EmptyNotificationActionData(
              title: message,
              subtitle: nil,
              action: "SHOP NOW")
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
          action: "SHOP NOW")
          self.view?.hideLoading()
      }
    }
  }
}
