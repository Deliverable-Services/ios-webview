//
//  MyProductPrescriptionViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 27/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit
import SwiftyJSON

public protocol MyProductPrescriptionView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func showError(message: String?)
  func navigateToShop()
  func navigateToMyProducts()
}

public protocol MyProductPrescriptionViewModelProtocol: MyProductPrescriptionHeaderViewModel {
  var prescriptionsRecipe: CoreDataRecipe { get }
  var emptyNotificationActionData: EmptyNotificationActionData? { get }
  var note: String? { get }
  
  func attachView(_ view: MyProductPrescriptionView)
  func initialize()
}

public final class MyProductPrescriptionViewModel: MyProductPrescriptionViewModelProtocol {
  private weak var view: MyProductPrescriptionView?
  public var emptyNotificationActionData: EmptyNotificationActionData?
  public var note: String?
  
  public var prescriptionsRecipe: CoreDataRecipe {
    var recipe = CoreDataRecipe()
    recipe.sorts = [.custom(key: "sequenceNumber", isAscending: true)]
    recipe.predicate = CoreDataRecipe.Predicate.compoundAnd(predicates: [.isEqual(key: "customer.id", value: AppUserDefaults.customerID)]).rawValue
    return recipe
  }
}

extension MyProductPrescriptionViewModel {
  public func attachView(_ view: MyProductPrescriptionView) {
    self.view = view
  }
  
  public func initialize() {
    view?.reload()
    view?.showLoading()
    PPAPIService.User.getMyPrescriptions().call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customerID = AppUserDefaults.customerID else { return }
          guard let customer = Customer.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
          Prescription.parsePrescriptionsFromData(result.data.products, customer: customer, inMOC: moc)
        }, completion: { (_) in
          self.note = result.data.note.string
          if let message = result.message, result.data.products.array?.isEmpty ?? true {
            if JSON(parseJSON: AppUserDefaults.customer?.skinQuizAnswerRaw ?? "").isDone.boolValue {
              self.emptyNotificationActionData = EmptyNotificationActionData(
                title: message,
                subtitle: nil,
                action: "RELOAD")
            } else {
              self.emptyNotificationActionData = EmptyNotificationActionData(
                title: message,
                subtitle: nil,
                action: "START SKIN QUIZ")
            }
          } else {
            self.emptyNotificationActionData = nil
          }
          self.view?.hideLoading()
          self.view?.reload()
        })
      case .failure(let error):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customerID = AppUserDefaults.customerID else { return }
          guard let customer = Customer.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
          guard let prescriptions = customer.prescriptions?.allObjects as? [Prescription] else { return }
          CoreDataUtil.deleteEntities(prescriptions, inMOC: moc)
        }, completion: { (_) in
          self.emptyNotificationActionData = EmptyNotificationActionData(
            title: error.localizedDescription,
            subtitle: nil,
            action: "RELOAD")
          self.view?.hideLoading()
          self.view?.reload()
        })
      }
    }
  }
}

// MARK: - MyProductPrescriptionHeaderViewModel
extension MyProductPrescriptionViewModel {
  public func shopNowDidTapped() {
    view?.navigateToShop()
  }
  
  public func myProductsDidTapped() {
    view?.navigateToMyProducts()
  }
}
