//
//  EditProfileViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 17/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit
import Kingfisher
import PhoneNumberKit

public enum EditProfileSection {
  case updateAvatar
  case updateProfile
}

public protocol EditProfileView: class {
  func reload(section: EditProfileSection)
  func showLoading(section: EditProfileSection)
  func hideLoading(section: EditProfileSection)
  func showError(message: String?)
  func successUpdate()
}

public protocol EditProfileViewModelProtocol {
  var customer: Customer { get }
  var avatar: String? { get }
  var firstName: String? { get set }
  var lastName: String? { get set }
  var email: String? { get set }
  var phoneCode: String? { get set }
  var phone: String? { get set }
  var birthDate: Date? { get set }
  var gender: GenderType? { get set }
  var address: String? { get set }
  var postalCode: String? { get set }
  
  func attachView(_ view: EditProfileView)
  func initialize()
  func updateAvatar(imageData: Data)
  func update()
}

public final class EditProfileViewModel: EditProfileViewModelProtocol {
  private weak var view: EditProfileView?
  
  init(customer: Customer) {
    self.customer = customer
    firstName = customer.firstName
    lastName = customer.lastName
    email = customer.email
    phoneCode = customer.phoneCode
    phone = customer.phone
    birthDate = customer.birthDate
    gender = customer.genderType
    address = customer.personalAddress?.address
    postalCode = customer.personalAddress?.postalCode
  }
  
  public var customer: Customer
  
  public var avatar: String? {
    return customer.avatar
  }
  
  public var firstName: String?
  
  public var lastName: String?
  
  public var email: String?
  
  public var phoneCode: String?
  
  public var phone: String?
  
  public var birthDate: Date?
  
  public var gender: GenderType?
  
  public var address: String?
  
  public var postalCode: String?
}

extension EditProfileViewModel {
  public func attachView(_ view: EditProfileView) {
    self.view = view
  }
  
  public func initialize() {
    view?.reload(section: .updateAvatar)
    view?.reload(section: .updateProfile)
  }
  
  public func updateAvatar(imageData: Data) {
    guard let customerID = customer.id else { return }
    guard let uploadPart = UploadPart(filename: "avatar.png", data: imageData) else {
      view?.showError(message: "Image could not be loaded.")
      return
    }
    view?.showLoading(section: .updateAvatar)
    PPAPIService.User.updateAvatar(uploadPart: uploadPart).call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customer = User.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
          if let avatar = result.data.string {
            customer.avatar = avatar
            if let url = URL(string: avatar) {//reset image
              ImageCache.default.removeImage(forKey: url.absoluteString)
            }
          }
        }, completion: { (_) in
          self.view?.hideLoading(section: .updateAvatar)
          self.view?.reload(section: .updateAvatar)
        })
      case .failure(let error):
        self.view?.hideLoading(section: .updateAvatar)
        self.view?.showError(message: error.localizedDescription)
      }
    }
  }
  
  public func update() {
    guard let customerID = customer.id else { return }
    view?.showLoading(section: .updateProfile)
    var request: [APIServiceConstant.Key: Any] = [:]
    request[.firstName] = firstName?.emptyToNil ?? NSNull()
    request[.lastName] = lastName?.emptyToNil ?? NSNull()
    request[.email] = email?.emptyToNil ?? NSNull()
    request[.phone] = (try? PhoneNumberKit().parse([phoneCode, phone].compactMap({ $0 }).joined()).numberString)?.prependPlusIfNeeded()
    request[.birthDate] = birthDate?.toString(WithFormat: "yyyy-MM-dd")
    request[.gender] = gender?.rawValue
    var personalAddress: [APIServiceConstant.Key: Any] = [:]
    personalAddress[.address] = address ?? NSNull()
    personalAddress[.postalCode] = postalCode ?? NSNull()
    request[.personalAddress] = personalAddress
    request[.preferredCenterID] = customer.preferredCenterID
    PPAPIService.User.updateProfile(request: request).call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          let users = User.getUsers(userIDs: [customerID], type: .customer, inMOC: moc)
          User.parseUserFromData(result.data, users: users, type: .customer, inMOC: moc)
        }, completion: { (_) in
          self.view?.hideLoading(section: .updateProfile)
          self.view?.successUpdate()
        })
      case .failure(let error):
        self.view?.hideLoading(section: .updateProfile)
        self.view?.showError(message: error.localizedDescription)
      }
    }
  }
}
