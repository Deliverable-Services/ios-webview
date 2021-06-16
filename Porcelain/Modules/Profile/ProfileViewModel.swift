//
//  ProfileViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 17/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit

public protocol ProfileView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func showError(message: String?)
}

public protocol ProfileViewModelProtocol {
  var customer: Customer? { get }
  var profileItems: [ProfileItemData] { get }
  
  func attachView(_ view: ProfileView)
  func initialize()
}

public final class ProfileViewModel: ProfileViewModelProtocol {
  private weak var view: ProfileView?
  
  public var customer: Customer? {
    return AppUserDefaults.customer
  }
  
  public var profileItems: [ProfileItemData] {
    return [
      ProfileItemData(title: "Credit | Debit Card", subtitle: "Link a payment card", isCallOutShown: true),
      ProfileItemData(title: "Purchase History", subtitle: nil, isCallOutShown: false),
      ProfileItemData(title: "Address Book", subtitle: "Manage address information", isCallOutShown: true)]
  }
}

extension ProfileViewModel {
  public func attachView(_ view: ProfileView) {
    self.view = view
  }
  
  public func initialize() {
    view?.reload()
    reloadProfile()
  }
}

extension ProfileViewModel {
  private func reloadProfile() {
    guard let customerID = customer?.id else { return }
    view?.showLoading()
    PPAPIService.User.getProfile().call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          let users = User.getUsers(userIDs: [customerID], type: .customer, inMOC: moc)
          User.parseUserFromData(result.data, users: users, type: .customer, inMOC: moc)
        }, completion: { (_) in
          self.view?.hideLoading()
          self.view?.reload()
        })
      case .failure(let error):
        self.view?.hideLoading()
        self.view?.showError(message: error.localizedDescription)
      }
    }
  }
}
