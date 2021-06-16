//
//  LoginViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 22/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import R4pidKit
import os.log
import PhoneNumberKit
import Kingfisher

public enum AuthenticationStep {
  case root
  case otp
  case userRegistration
}

public enum AuthenticationIssueAction {
  case retriveExistingAccount(message: String?)
  case showSupport(message: String?, email: String)
}

public protocol LoginView: class {
  func reload()
  func navigateToAuthStep(_ step: AuthenticationStep)
  func loginSuccess()
  func showLoading()
  func hideLoading()
  func showError(message: String?)
  func showOTPSuccess(message: String?, completion: @escaping VoidCompletion)
  func showAuthenticateIssueAction(_ action: AuthenticationIssueAction)
}

extension String {
  public var maskedPhone: String? {
    let phoneNumber = try? PhoneNumberKit().parse(self)
    if let phoneNumber = phoneNumber {
      let phoneCode = "+\(phoneNumber.countryCode)"
      var phone = "\(phoneNumber.nationalNumber)"
      let lenght = phone.count - 3
      for indx in 0...(lenght - 1) {
        if let range = Range(NSRange(location: indx, length: 1), in: phone) {
          phone.replaceSubrange(range, with: "*")
        }
      }
      return "\(phoneCode)\(phone)"
    } else {
      return phoneNumber?.numberString
    }
  }
}

public struct FistNameErrorConfig: InputValidatorErrorConfigProtocol {
  public var empty: InputValidatorError? = .empty(message: "First name is empty.")
  public var tooLong: InputValidatorError?
  public var tooShort: InputValidatorError?
  public var notInRange: InputValidatorError? = .notInRange(message: "Please enter first name with 2 or more characters but less than 99 characters.")
  public var invalid: InputValidatorError = .notInRange(message: "Please enter first name with 2 or more characters but less than 99 characters.")
}

public struct LastNameErrorConfig: InputValidatorErrorConfigProtocol {
  public var empty: InputValidatorError? = .empty(message: "Last name is empty.")
  public var tooLong: InputValidatorError?
  public var tooShort: InputValidatorError?
  public var notInRange: InputValidatorError? = .notInRange(message: "Please enter last name with 2 or more characters but less than 99 characters.")
  public var invalid: InputValidatorError = .notInRange(message: "Please enter last name with 2 or more characters but less than 99 characters.")
}

public struct EmailErrorConfig: InputValidatorErrorConfigProtocol {
  public var empty: InputValidatorError? = .empty(message: "Email is empty.")
  public var tooLong: InputValidatorError?
  public var tooShort: InputValidatorError?
  public var notInRange: InputValidatorError?
  public var invalid: InputValidatorError = .invalid(message: "Please enter a valid email address.")
}

public protocol LoginViewModelProtocol: WelcomeAuthMobileViewModelProtocol, OTPAuthMobieViewModelProtocol, UserRegistrationViewModelProtocol {
  var picture: String? { get }
  var facebookAuthToken: String? { get }
  var linkingFacebookAuthToken: String? { get }
  var googleID: String? { get }
  var linkingGoogleID: String? { get }
  
  func attachView(_ view: LoginView)
  func initialize()
  func sendMobileOTP()
  func reset()
}

public final class LoginViewModel: LoginViewModelProtocol {
  private weak var view: LoginView?
  
  private lazy var phoneNumberKit = PhoneNumberKit()
  public var picture: String?
  public var facebookAuthToken: String?
  public var linkingFacebookAuthToken: String?
  public var googleID: String?
  public var linkingGoogleID: String?
  public var userRegistrationType: UserRegistrationType = .signUp
  public var firstname: String?
  public var lastname: String?
  public var email: String?
  public var isEmailVerified: Bool = false
  public var country: CountryData?
  public var phone: String?
  public var linkingPhone: String?
  public var isMobileVerified: Bool = false
  public var isMobileEditable: Bool = true
}

extension LoginViewModel {
  public func attachView(_ view: LoginView) {
    self.view = view
  }
  
  public func initialize() {
    view?.reload()
  }
  
  public func sendMobileOTP() {
    do {
      let phoneNumber = try phoneNumberKit.parse(linkingPhone ?? [country?.phoneCode, phone].compactMap({ $0 }).joined())
      view?.showLoading()
      isMobileVerified = false
      PPAPIService.Authentication.sendOTP(phone: phoneNumber.numberString.prependPlusIfNeeded()).call { (response) in
        switch response {
        case .success(let result):
          self.view?.hideLoading()
          var message = result.message
          if let linkingPhone = self.linkingPhone, let maskedPhone = linkingPhone.maskedPhone {
            message = message?.replacingOccurrences(of: linkingPhone, with: maskedPhone)
          }
          self.view?.showOTPSuccess(message: message) { [weak self] in
            guard let `self` = self else { return }
            self.view?.navigateToAuthStep(.otp)
          }
        case .failure(let error):
          self.view?.hideLoading()
          self.view?.showError(message: error.localizedDescription)
        }
      }
    } catch {
      if error is PhoneNumberError {
        view?.showError(message: "Please enter a valid mobile number.")
      } else {
        view?.showError(message: error.localizedDescription)
      }
    }
  }
  
  public func reset() {
    picture = nil
    facebookAuthToken = nil
    linkingFacebookAuthToken = nil
    googleID = nil
    linkingGoogleID = nil
    firstname = nil
    lastname = nil
    email = nil
    isEmailVerified = false
    phone = nil
    linkingPhone = nil
    isMobileVerified = false
    isMobileEditable = true
  }
}

extension LoginViewModel {
  public func authMobileContinue() {
    facebookAuthToken = nil
    linkingFacebookAuthToken = nil
    googleID = nil
    linkingGoogleID = nil
    linkingPhone = nil
    do {
      let phoneNumber = try phoneNumberKit.parse(linkingPhone ?? [country?.phoneCode, phone].compactMap({ $0 }).joined())
      isMobileVerified = false
      if (AppConfiguration.debugLoginWithPhone && !AppConfiguration.isProduction) || AppConfiguration.appleTestPhone == phone {
        view?.showLoading()
        PPAPIService.Authentication.signInDebug(phone: phoneNumber.numberString.prependPlusIfNeeded()).call { (response) in
          switch response {
          case .success(let result):
            self.view?.hideLoading()
            self.saveUserAndLogin(data: result.data)
          case .failure(let error):
            self.view?.hideLoading()
            if error.failureCode.rawCode == 400 {
              self.isMobileEditable = false
              self.view?.navigateToAuthStep(.userRegistration)
            } else {
              self.view?.showError(message: error.localizedDescription)
            }
          }
        }
      } else {
        view?.showLoading()
        PPAPIService.Authentication.signInSendOTP(phone: phoneNumber.numberString.prependPlusIfNeeded()).call { (response) in
          switch response {
          case .success(let result):
            self.view?.hideLoading()
            self.view?.showOTPSuccess(message: result.message) { [weak self] in
              guard let `self` = self else { return }
              self.view?.navigateToAuthStep(.otp)
              
            }
          case .failure(let error):
            self.view?.hideLoading()
            if error.failureCode.rawCode == 400 {
              self.isMobileEditable = false
              self.view?.navigateToAuthStep(.userRegistration)
            } else {
              self.view?.showError(message: error.localizedDescription)
            }
          }
        }
      }
    } catch {
      if error is PhoneNumberError {
        view?.showError(message: "Please enter a valid mobile number.")
      } else {
        view?.showError(message: error.localizedDescription)
      }
    }
  }
  
  public func authenticateWithFB() {
    view?.showLoading()
    isEmailVerified = false
    SocialHandler.shared.loginFB { (result) in
      switch result {
      case .success(let socialUser):
        self.view?.hideLoading()
        self.googleID = nil
        self.facebookAuthToken = socialUser.authToken
        self.picture = socialUser.picture
        self.firstname = socialUser.firstname
        self.lastname = socialUser.lastname
        self.email = socialUser.email
        self.isEmailVerified = socialUser.email?.emptyToNil != nil
        let phoneNumber = try? self.phoneNumberKit.parse(socialUser.phoneNumber ?? "")
        if let countryCode = phoneNumber?.countryCode {
          SelectCountryService.getCountry(query: .phoneCode(value: concatenate(countryCode))) { (country) in
            self.country = country
          }
        }
        if let nationalNumber = phoneNumber?.nationalNumber {
          self.phone = "\(nationalNumber)".emptyToNil
        } else {
          self.phone = nil
        }
        self.trySocialLogin()
      case .failure(let error):
        self.view?.hideLoading()
        self.isEmailVerified = false
        if error.localizedDescription != "Ignore" {
          self.view?.showError(message: error.localizedDescription)
        }
      }
    }
  }
  
  public func authenticateWithGoogle() {
    view?.showLoading()
    isEmailVerified = false
    SocialHandler.shared.loginGoogle { (result) in
      switch result {
      case .success(let socialUser):
        self.view?.hideLoading()
        self.googleID = socialUser.id
        self.facebookAuthToken = nil
        self.picture = socialUser.picture
        self.firstname = socialUser.firstname
        self.lastname = socialUser.lastname
        self.email = socialUser.email
        self.isEmailVerified = socialUser.email?.emptyToNil != nil
        let phoneNumber = try? self.phoneNumberKit.parse(socialUser.phoneNumber ?? "")
        if let countryCode = phoneNumber?.countryCode {
          SelectCountryService.getCountry(query: .phoneCode(value: concatenate(countryCode))) { (country) in
            self.country = country
          }
        }
        if let nationalNumber = phoneNumber?.nationalNumber {
          self.phone = "\(nationalNumber)".emptyToNil
        } else {
          self.phone = nil
        }
        self.trySocialLogin()
      case .failure(let error):
        self.view?.hideLoading()
        self.isEmailVerified = false
        if error.localizedDescription != "Ignore" {
          self.view?.showError(message: error.localizedDescription)
        }
      }
    }
  }
}

extension LoginViewModel {
  public func otpMobileValidate(otp: String) {
    do {
      let phoneNumber = try phoneNumberKit.parse(linkingPhone ?? [country?.phoneCode, phone].compactMap({ $0 }).joined())
      view?.showLoading()
      PPAPIService.Authentication.signInVerifyOTP(
        phone: phoneNumber.numberString.prependPlusIfNeeded(),
        otp: otp,
        debug: false).call { (response) in
        switch response {
        case .success(let result):
          self.isMobileVerified = true
          if self.isMobileEditable {
            if self.facebookAuthToken != nil || self.googleID != nil {
              self.view?.hideLoading()
              self.userRegistratinContinue()
            } else {
              if result.data.exists() {
                self.view?.hideLoading()
                self.saveUserAndLogin(data: result.data)
              } else {
                self.view?.hideLoading()
                self.view?.navigateToAuthStep(.userRegistration)
              }
            }
          } else {
            self.view?.hideLoading()
            self.userRegistratinContinue()
          }
        case .failure(let error):
          self.isMobileVerified = false
          self.view?.hideLoading()
          self.view?.showError(message: error.localizedDescription)
        }
      }
    } catch {
      if error is PhoneNumberError {
        view?.showError(message: "Please enter a valid mobile number.")
      } else {
        view?.showError(message: error.localizedDescription)
      }
    }
  }
  
  public func otpRequestNewCode(completion: @escaping (APIResponse) -> ()) {
    do {
      let phoneNumber = try phoneNumberKit.parse(linkingPhone ?? [country?.phoneCode, phone].compactMap({ $0 }).joined())
      view?.showLoading()
      isMobileVerified = false
      PPAPIService.Authentication.resendOTP(phone: phoneNumber.numberString.prependPlusIfNeeded()).call { (response) in
        switch response {
        case .success(let result):
          self.view?.hideLoading()
          if let message = result.message {
            self.view?.showError(message: message)
          }
        case .failure(let error):
          self.view?.hideLoading()
          self.view?.showError(message: error.localizedDescription)
        }
        completion(response)
      }
    } catch {
      if error is PhoneNumberError {
        view?.showError(message: "Please enter a valid mobile number.")
      } else {
        view?.showError(message: error.localizedDescription)
      }
    }
  }
}

extension LoginViewModel {
  public func userRegistratinContinue() {
    do {
      try InputValidator.validate(text: firstname, validationRegex: .range(min: 2, max: 99)).validate(errorConfig: FistNameErrorConfig())
      try InputValidator.validate(text: lastname, validationRegex: .range(min: 2, max: 99)).validate(errorConfig: LastNameErrorConfig())
      try InputValidator.validate(text: email, validationRegex: .email).validate(errorConfig: EmailErrorConfig())
      let phoneNumber = try phoneNumberKit.parse([country?.phoneCode, phone].compactMap({ $0 }).joined(separator: ""))
      preSignupValidate(email: email!, phone: phoneNumber.numberString.prependPlusIfNeeded()) {
        if self.isMobileVerified {
          self.view?.showLoading()
          var request: [APIServiceConstant.Key: Any] = [:]
          request[.firstName] = self.firstname
          request[.lastName] = self.lastname
          request[.email] = self.email
          request[.phone] = phoneNumber.numberString.prependPlusIfNeeded()
          request[.gender] = 3
          request[.facebookToken] = self.facebookAuthToken
          request[.googleID] = self.googleID
          PPAPIService.Authentication.signUp(request: request).call { (response) in
            switch response {
            case .success(let result):
              self.saveUserAndLogin(data: result.data)
              self.view?.hideLoading()
            case .failure(let error):
              self.view?.hideLoading()
              self.view?.showError(message: error.localizedDescription)
            }
          }
        } else {
          self.sendMobileOTP()
        }
      }
    } catch {
      if error is PhoneNumberError {
        view?.showError(message: "Please enter a valid mobile number.")
      } else {
        view?.showError(message: error.localizedDescription)
      }
    }
  }
}

extension LoginViewModel {
  private func trySocialLogin() {
    view?.showLoading()
    var request: [APIServiceConstant.Key: Any] = [:]
    request[.facebookToken] = facebookAuthToken
    request[.googleID] = googleID
    request[.email] = email
    PPAPIService.Authentication.signInSocial(request: request).call { (response) in
      switch response {
      case .success(let result):
        self.view?.hideLoading()
        switch result.successCode {
        case .nonAuthoritativeInfo:
          self.view?.navigateToAuthStep(.userRegistration)
        case .success211:
          self.view?.navigateToAuthStep(.userRegistration)
        case .success209:
          if let email = result.data.email.string {
            self.view?.showAuthenticateIssueAction(.showSupport(message: result.message, email: email))
          } else {
            self.view?.showError(message: "Error 209, email is missing.")
          }
        case .success210:
          if let phoneCode = result.data.phoneCode.numberString, let phone = result.data.phone.numberString {
            self.linkingFacebookAuthToken = self.facebookAuthToken
            self.linkingGoogleID = self.googleID
            self.facebookAuthToken = nil
            self.googleID = nil
            self.linkingPhone = "+\(phoneCode)\(phone)"
            self.view?.showAuthenticateIssueAction(.retriveExistingAccount(message: result.message))
          } else {
            self.view?.showError(message: "Error 210, phone code or phone is missing.")
          }
        default:
          self.saveUserAndLogin(data: result.data)
        }
      case .failure(let error):
        if error.failureCode.rawCode == 422 {//not existing
          self.view?.hideLoading()
          self.view?.navigateToAuthStep(.userRegistration)
        } else {
          self.view?.hideLoading()
          self.view?.showError(message: error.localizedDescription)
        }
      }
    }
  }
  
  private func preSignupValidate(email: String, phone: String, completion: @escaping VoidCompletion) {
    view?.showLoading()
    PPAPIService.Authentication.signUpValidate(email: email, phone: phone).call { (response) in
      switch response {
      case .success(_):
        self.view?.hideLoading()
        completion()
      case .failure(let error):
        self.view?.hideLoading()
        self.view?.showError(message: error.localizedDescription)
      }
    }
  }
  
  private func saveUserAndLogin(data: JSON) {
    guard let userID = data.getUserID(type: .customer) else {
      view?.showError(message: "User object not found.")
      return
    }
    CoreDataUtil.performBackgroundTask({ (moc) in
      let users = User.getUsers(userIDs: [userID], type: .customer, inMOC: moc)
      User.parseUserFromData(data, users: users, type: .customer, inMOC: moc)
    }, completion: { (_) in
      if let customer = User.getUser(id: userID, type: .customer) {
        APIServiceConstant.accessToken = customer.accessToken
        AppUserDefaults.customer  = customer
        appDelegate.updateFCMTokenIfNeeded()
        appDelegate.configurePreload()
        self.uploadNewAvatarIfNeeded()
        self.linkSocialIfNeeded()
        self.view?.loginSuccess()
      } else  {
        self.view?.showError(message: "User object not saved.")
      }
      appDelegate.configureFirebaseIndentityIfNeeded()
    })
  }
  
  private func uploadNewAvatarIfNeeded() {
    guard let customer = AppUserDefaults.customer, let customerID = customer.id, customer.avatar?.contains("default.png") ?? true else { return }
    if let url = URL(string: self.picture ?? "") {
      ImageDownloader.default.downloadImage(with: url) { result in
        switch result {
        case .success(let value):
          guard let uploadPart = UploadPart(filename: "avatar.png", data: value.image.data) else { return }
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
              })
            case .failure: break
            }
          }
        case .failure(let error):
          osLogComposeError(error.localizedDescription, log: .network)
        }
      }
    }
  }
  
  private func linkSocialIfNeeded() {
    var request: [APIServiceConstant.Key: Any] = [:]
    if let linkingFacebookAuthToken = linkingFacebookAuthToken {
      request[.facebookToken] = linkingFacebookAuthToken
    }
    if let linkingGoogleID = linkingGoogleID {
      request[.googleID] = linkingGoogleID
    }
    guard !request.isEmpty else { return }
    PPAPIService.User.socialLink(request: request).call { (_) in
    }
  }
}

extension String {
  public func prependPlusIfNeeded() -> String {
    guard !contains("+") else { return self }
    return "+".appending(self)
  }
}
