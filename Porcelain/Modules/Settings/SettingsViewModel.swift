//
//  SettingsViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 19/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit
import PhoneNumberKit

public enum SocialType: Int {
  case facebook = 1
  case google
}

public protocol SettingsView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func showSuccess(message: String?)
  func showError(message: String?)
}

public protocol SettingsViewModelProtocol {
  var customer: Customer? { get }
  var optInPhoneCalls: Bool { get set }
  var optPushNotifications: Bool { get set }
  var optTransactionalEmail: Bool { get set }
  var optNewsletter: Bool { get set }
  var isFacebookLinked: Bool { get }
  var isGoogleLinked: Bool { get }
  
  func attachView(_ view: SettingsView)
  func initialize()
  func update()
  func socialLink(type: SocialType)
  func socialUnlink(type: SocialType)
}

public final class SettingsViewModel: SettingsViewModelProtocol {
  private weak var view: SettingsView?
  private var updateService: URLSessionDataTask?
  
  public var customer: Customer? {
    return AppUserDefaults.customer
  }
  
  public var optInPhoneCalls: Bool = false
  public var optTransactionalEmail: Bool = false
  public var optNewsletter: Bool = false
  public var optPushNotifications: Bool = false
  public var isFacebookLinked: Bool {
    return customer?.facebookLinked ?? false
  }
  public var isGoogleLinked: Bool {
    return customer?.googleLinked ?? false
  }
}

extension SettingsViewModel {
  public func attachView(_ view: SettingsView) {
    self.view = view
  }
  
  public func initialize() {
    optInPhoneCalls = customer?.optInPhoneCalls ?? false
    optTransactionalEmail = customer?.optTransactionalEmail ?? false
    optNewsletter = customer?.optNewsLetter ?? false
    optPushNotifications = customer?.optPushNotif ?? false
    
    view?.reload()
  }
  
  public func update() {
    updateService?.cancel()
    guard let customerID = customer?.id else { return }
    CoreDataUtil.performBackgroundTask({ (moc) in
      guard let user = User.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
      user.optInPhoneCalls = self.optInPhoneCalls
      user.optPushNotif = self.optPushNotifications
      user.optTransactionalEmail = self.optTransactionalEmail
      user.optNewsLetter = self.optNewsletter
    })
    var request: [APIServiceConstant.Key: Any] = [:]
    request[.firstName] = customer?.firstName?.emptyToNil ?? NSNull()
    request[.lastName] = customer?.lastName?.emptyToNil ?? NSNull()
    request[.email] = customer?.email?.emptyToNil ?? NSNull()
    request[.phone] = (try? PhoneNumberKit().parse([customer?.phoneCode, customer?.phone].compactMap({ $0 }).joined()).numberString)?.prependPlusIfNeeded()
    request[.birthDate] = customer?.birthDate?.toString(WithFormat: "yyyy-MM-dd")
    request[.gender] = customer?.gender
    var personalAddress: [APIServiceConstant.Key: Any] = [:]
    personalAddress[.address] = customer?.personalAddress?.address ?? NSNull()
    personalAddress[.postalCode] = customer?.personalAddress?.postalCode ?? NSNull()
    request[.personalAddress] = personalAddress
    request[.preferredCenterID] = customer?.preferredCenterID
    request[.optInPhoneCalls] = optInPhoneCalls
    request[.optPushNotif] = optPushNotifications
    request[.optTransactionalEmail] = optTransactionalEmail
    request[.optNewsLetter] = optNewsletter
    request[.preferredCenterID] = customer?.preferredCenterID
    updateService = PPAPIService.User.updateProfile(request: request).call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          let users = User.getUsers(userIDs: [customerID], type: .customer, inMOC: moc)
          User.parseUserFromData(result.data, users: users, type: .customer, inMOC: moc)
        }, completion: { (_) in
        })
      case .failure: break
      }
    }
  }
  
  public func socialLink(type: SocialType) {
    guard let customerID = customer?.id else { return }
    switch type {
    case .facebook:
      SocialHandler.shared.loginFB { (result) in
        switch result {
        case .success(let user):
          var request: [APIServiceConstant.Key: Any] = [:]
          request[.facebookToken] = user.authToken
          self.view?.showLoading()
          PPAPIService.User.socialLink(request: request).call { (response) in
            switch response {
            case .success(let result):
              CoreDataUtil.performBackgroundTask({ (moc) in
                let user = User.getUser(id: customerID, type: .customer, inMOC: moc)
                user?.facebookLinked =  true
              }, completion: { (_) in
                self.view?.showSuccess(message: result.message)
                self.view?.hideLoading()
                self.view?.reload()
              })
            case .failure(let error):
              self.view?.hideLoading()
              self.view?.showError(message: error.localizedDescription)
            }
          }
        case .failure(let error):
          self.view?.showError(message: error.localizedDescription)
        }
      }
    case .google:
      SocialHandler.shared.loginGoogle { (result) in
        switch result {
        case .success(let user):
          var request: [APIServiceConstant.Key: Any] = [:]
          request[.googleID] = user.id
          self.view?.showLoading()
          PPAPIService.User.socialLink(request: request).call { (response) in
            switch response {
            case .success(let result):
              CoreDataUtil.performBackgroundTask({ (moc) in
                let user = User.getUser(id: customerID, type: .customer, inMOC: moc)
                user?.googleLinked =  true
              }, completion: { (_) in
                self.view?.showSuccess(message: result.message)
                self.view?.hideLoading()
                self.view?.reload()
              })
            case .failure(let error):
              self.view?.hideLoading()
              self.view?.showError(message: error.localizedDescription)
            }
          }
        case .failure(let error):
          self.view?.showError(message: error.localizedDescription)
        }
      }
    }
  }
  
  public func socialUnlink(type: SocialType) {
    guard let customerID = customer?.id else { return }
    var request: [APIServiceConstant.Key: Any] = [:]
    request[.socialType] = type.rawValue
    view?.showLoading()
    PPAPIService.User.socialUnlink(request: request).call { (response) in
      switch response {
      case .success:
        CoreDataUtil.performBackgroundTask({ (moc) in
          let user = User.getUser(id: customerID, type: .customer, inMOC: moc)
          switch type {
          case .facebook:
            user?.facebookLinked =  false
          case .google:
            user?.googleLinked =  false
          }
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
