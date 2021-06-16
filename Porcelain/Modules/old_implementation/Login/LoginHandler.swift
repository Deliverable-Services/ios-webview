//
//  LoginHandler.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 25/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
//import FacebookLogin
//import FacebookCore
//import GoogleSignIn
import SwiftyJSON

enum LoginAction {
  case connectToFacebook
  case connectToGoogle
  case connectToEmail
}

protocol LoginHandlerProtocol: class {
  var delegate: LoginHandlerDelegate? { get }
}

protocol LoginHandlerDelegate: class {
  func loginHandlerWillStart(_ handler: LoginHandler, action: LoginAction)
  func loginHandlerDidFail(_ handler: LoginHandler, action: LoginAction, error: Error?)
  func loginHandlerSuccessful(_ handler: LoginHandler, action: LoginAction)
}

class LoginHandler: LoginHandlerProtocol {
  weak var delegate: LoginHandlerDelegate?
  private var email: String?
  
  fileprivate lazy var networkRequest: PorcelainNetworkRequest = {
    let request = PorcelainNetworkRequest()
    request.delegate = self
    return request
  }()
  
//  func connectToFacebook() {
//    let loginManager = LoginManager()
//    
//    loginManager.logIn(readPermissions: [.publicProfile, .email, .userBirthday], viewController: self.delegate as? UIViewController) { loginResult in
//      switch loginResult {
//      case .failed(let error):
//        print(error)
//      case .cancelled:
//        print("User cancelled login.")
//      case .success(_, _, let accessToken):
//        self.getUserDetails(token: accessToken)
//      }
//    }
//  }
//  
//  private func getUserDetails(token: AccessToken) {
//    let parameters = ["fields": "id, email, name, first_name, last_name"]
//    let connection = GraphRequestConnection()
//    connection.add(GraphRequest(graphPath: "/me", parameters: parameters, accessToken: token, httpMethod: .GET, apiVersion: .defaultVersion)) { httpResponse, result in
//      switch result {
//      case .success(let response):
//        let userInfo = response.dictionaryValue!
//        self.networkRequest.connectToFacebook(token.authenticationToken,
//                                              emailAddress: userInfo["email"] as! String,
//                                              firstName: userInfo["first_name"] as! String,
//                                              lastName: userInfo["last_name"] as! String)
//        self.email = userInfo["email"] as? String
//      case .failed(let error):
//        print("Graph Request Failed: \(error)")
//      }
//    }
//    connection.start()
//  }
  
//  func connectToGoogle(_ user: GIDGoogleUser) {
//    self.networkRequest.connectToGoogle(user.authentication.idToken,
//                                     emailAddress: user.profile.email,
//                                     firstName: user.profile.givenName,
//                                     lastName: user.profile.familyName)
//    self.email = user.profile.email
//  }
}

extension LoginHandler: PorcelainNetworkRequestDelegateProtocol {
  func requestWillStart(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction) {
    
  }
  
  func requestDidFail(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction,
                      error: Error?, statusCode: Int?, errorMessage: String?) {
    print("Failed: ", error ?? "")
    print(statusCode.debugDescription)
    guard let action = action as? SignInRequestAction else { return }
    switch action {
//    case .connectToFacebook:
//      self.delegate?.loginHandlerDidFail(self, action: .connectToFacebook, error: error)
//    case .connectToGoogle:
//      self.delegate?.loginHandlerDidFail(self, action: .connectToGoogle, error: error)
    case .signInEmail:
      self.delegate?.loginHandlerDidFail(self, action: .connectToEmail, error: error)
    default: break
    }
  }
  
  func requestSuccessful(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction, result: Any?) {
    guard let action = action as? SignInRequestAction else { return }
    
    guard let result = result else { return }
    let json = JSON(result)[0].dictionaryValue
    self.saveUserDetails(userID: json[PorcelainAPIConstant.Key.data]?[PorcelainAPIConstant.Key.id].string)
    switch action {
//    case .connectToFacebook:
//      self.delegate?.loginHandlerSuccessful(self, action: .connectToFacebook)
//    case .connectToGoogle:
//      self.delegate?.loginHandlerSuccessful(self, action: .connectToGoogle)
    case .signInEmail:
      self.delegate?.loginHandlerSuccessful(self, action: .connectToEmail)
    default: break
    }
    print(result)
  }
  
  private func saveUserDetails(userID: String?) {
    AppUserDefaults.email = self.email
    AppUserDefaults.customer?.id = userID
  }
}

