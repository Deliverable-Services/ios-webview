//
//  AddressBookViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 19/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit

public protocol AddressBookView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func showError(message: String?)
}

public protocol AddressBookViewModelProtocol {
  var cardsRecipe: CoreDataRecipe { get }
  var emptyNotificationActionData: EmptyNotificationActionData? { get }
  
  func attachView(_ view: AddressBookView)
  func initialize()
  func setAddressPrimary(_ address: ShippingAddress)
  func deleteAddress(_ address: ShippingAddress)
}

public final class AddressBookViewModel: AddressBookViewModelProtocol {
  private weak var view: AddressBookView?
  public var cardsRecipe: CoreDataRecipe {
    var recipe = CoreDataRecipe()
    recipe.sorts = [.dateCreated(isAscending: false)]
    let predicates: [CoreDataRecipe.Predicate] = [
      .isEqual(key: "customer.id", value: AppUserDefaults.customerID)]
    recipe.predicate = CoreDataRecipe.Predicate.compoundAnd(predicates: predicates).rawValue
    return recipe
  }
  public var emptyNotificationActionData: EmptyNotificationActionData?
}

extension AddressBookViewModel {
  public func attachView(_ view: AddressBookView) {
    self.view = view
  }
  
  public func initialize() {
    view?.reload()
    view?.showLoading()
    PPAPIService.User.getShippingAddresses().call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customerID = AppUserDefaults.customerID else { return }
          guard let customer = Customer.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
          ShippingAddress.parseAddresses(result.data, customer: customer, inMOC: moc)
        }, completion: { (_) in
          if result.data.isEmpty {
            self.emptyNotificationActionData = EmptyNotificationActionData(
              title: "You haven't added any addresses yet.",
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
  
  public func setAddressPrimary(_ address: ShippingAddress) {
    guard let customerID = AppUserDefaults.customerID else { return }
    guard let addressID = address.id else { return }
    PPAPIService.User.markShippingAddressAsDefault(shippingID: addressID).call { (_) in}
    CoreDataUtil.performBackgroundTask({ (moc) in
      let addresses = ShippingAddress.getAddresses(customerID: customerID, inMOC: moc)
      addresses.forEach { (address) in
        address.primary = address.id == addressID
      }
    }, completion: { (_) in
    })
  }
  
  public func deleteAddress(_ address: ShippingAddress) {
    guard let customerID = AppUserDefaults.customerID else { return }
    guard let addressID = address.id else { return }
    PPAPIService.User.deleteShippingAddress(shippingID: addressID).call { (_) in}
    CoreDataUtil.performBackgroundTask({ (moc) in
      guard let address = ShippingAddress.getAddress(id: addressID, customerID: customerID, inMOC: moc) else { return }
      address.delete()
    }, completion: { (_) in
    })
  }
}
