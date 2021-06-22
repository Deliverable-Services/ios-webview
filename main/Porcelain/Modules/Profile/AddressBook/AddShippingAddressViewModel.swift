//
//  AddShippingAddressViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 19/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit
import PhoneNumberKit

public enum AddShippingAddressType {
  case create
  case update(address: ShippingAddress)
}

public protocol AddShippingAddressView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func showError(message: String?)
  func successSubmit()
}

public protocol AddShippingAddressViewModelProtocol {
  var type: AddShippingAddressType { get }
  var name: String? { get set }
  var email: String? { get set }
  var address: String? { get set }
  var country: String? { get set }
  var state: String? { get set }//City
  var postalCode: String? { get set }
  var phoneCode: String? { get set }
  var phone: String? { get set }
  var isPrimary: Bool { get set }
  var navTitle: String { get }
  var submitTitle: String { get }

  func attachView(_ view: AddShippingAddressView)
  func initialize()
  func reload()
  func submit()
}

public final class AddShippingAddressViewModel: AddShippingAddressViewModelProtocol {
  private weak var view: AddShippingAddressView?
  
  init(type: AddShippingAddressType) {
    self.type = type
    switch type {
    case .update(let address):
      name = address.name
      self.address = address.address
      country = address.country
      state = address.state
      postalCode = address.postalCode
      let phoneNumber = try? PhoneNumberKit().parse(address.phone ?? "")
      phoneCode = phoneNumber?.countryCode.stringValue
      phone = phoneNumber?.nationalNumber.stringValue
      email = address.email
      isPrimary = address.primary
      navTitle = "EDIT SHIPPING ADDRESS"
      submitTitle = "UPDATE"
    default:
      isPrimary = false
      navTitle = "ADD SHIPPING ADDRESS"
      submitTitle = "ADD"
    }
  }
  
  private lazy var phoneNumberKit = PhoneNumberKit()
  
  public var type: AddShippingAddressType
  public var name: String?
  public var email: String?
  public var address: String?
  public var country: String?
  public var state: String?
  public var postalCode: String?
  public var phoneCode: String?
  public var phone: String?
  public var isPrimary: Bool
  public var navTitle: String
  public var submitTitle: String
}

extension AddShippingAddressViewModel {
  public func attachView(_ view: AddShippingAddressView) {
    self.view = view
  }
  
  public func initialize() {
    view?.reload()
  }
  
  public func reload() {
    view?.reload()
  }
  
  public func submit() {
    var request: [APIServiceConstant.Key: Any] = [:]
    request[.name] = name?.clean()
    request[.email] = email?.clean()
    request[.address] = address?.clean()
    request[.country] = country
    request[.state] = state?.clean()
    request[.postalCode] = postalCode
    request[.phone] = try? phoneNumberKit.parse([phoneCode, phone].compactMap({ $0 }).joined()).numberString
    request[.primary] = isPrimary
    
    switch type {
    case .create:
      view?.showLoading()
      PPAPIService.User.createShippingAddress(request: request).call { (response) in
        switch response {
        case .success(let result):
          CoreDataUtil.performBackgroundTask({ (moc) in
            guard let addressID = result.data.id.numberString else { return }
            guard let customerID = AppUserDefaults.customerID else { return }
            guard let customer = User.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
            if self.isPrimary, let primaryAddress = CoreDataUtil.get(ShippingAddress.self, predicate: .compoundAnd(predicates: [
              .isEqual(key: "primary", value: true),
              .isEqual(key: "customer.id", value: customerID)])) {
              primaryAddress.primary = false
            }
            let addresses = ShippingAddress.getAddresses(addressIDs: [addressID], customerID: customerID, inMOC: moc)
            ShippingAddress.parseAddressFromData(result.data, customer: customer, addresses: addresses, inMOC: moc)
          }, completion: { (_) in
            self.view?.hideLoading()
            self.view?.successSubmit()
          })
        case .failure(let error):
          self.view?.hideLoading()
          self.view?.showError(message: error.localizedDescription)
        }
      }
    case .update(let address):
      guard let addressID = address.id else {
        view?.showError(message: "Address id is missing.")
        return
      }
      view?.showLoading()
      PPAPIService.User.updateShippingAddress(shippingID: addressID, request: request).call { (response) in
        switch response {
        case .success(let result):
          CoreDataUtil.performBackgroundTask({ (moc) in
            guard let addressID = result.data.id.numberString else { return }
            guard let customerID = AppUserDefaults.customerID else { return }
            guard let customer = User.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
            if self.isPrimary, let primaryAddress = CoreDataUtil.get(ShippingAddress.self, predicate: .compoundAnd(predicates: [
              .isEqual(key: "primary", value: true),
              .isEqual(key: "customer.id", value: customerID)])) {
              primaryAddress.primary = false
            }
            let addresses = ShippingAddress.getAddresses(addressIDs: [addressID], customerID: customerID, inMOC: moc)
            ShippingAddress.parseAddressFromData(result.data, customer: customer, addresses: addresses, inMOC: moc)
          }, completion: { (_) in
            self.view?.hideLoading()
            self.view?.successSubmit()
          })
          self.view?.hideLoading()
        case .failure(let error):
          self.view?.hideLoading()
          self.view?.showError(message: error.localizedDescription)
        }
      }
    }
  }
}
