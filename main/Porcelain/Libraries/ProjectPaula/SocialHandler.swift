//
//  SocialHandler.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 24/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import FacebookCore
import FacebookLogin
import GoogleSignIn
import Firebase
import FirebaseAuth
import R4pidKit
import SwiftyJSON
import Social

public enum SocialUserType {
  case facebook(data: JSON)
  case google(data: JSON)
}

public struct SocialUserData {
  public var id: String?
  public var firstname: String?
  public var lastname: String?
  public var email: String?
  public var picture: String?
  public var phoneNumber: String?
  public var authToken: String?
  
  public init?(type: SocialUserType) {
    switch type {
    case .facebook(let data):
      guard let id = data.id.string else { return nil }
      self.id = id
      firstname = data.firstName.string
      lastname = data.lastName.string
      email = data.email.string
      picture = data.picture.data.url.string
      phoneNumber = data.mobilePhone.string
    case .google(let data):
      guard !data.isEmpty else { return nil }
      firstname = data.givenName.string
      lastname = data.familyName.string
      email = data.email.string
      picture = data.picture.string
      phoneNumber = data.phoneNumber.string
    }
  }
  
  public init(user: GIDGoogleUser) {
    id = user.userID
    firstname = user.profile.givenName
    lastname = user.profile.familyName
    email = user.profile.email
    picture = user.profile.imageURL(withDimension: 200)?.absoluteString
    phoneNumber = nil
  }
}

public struct SocialLoginError: Error {
  let erroMessage: String
  init(erroMessage: String) {
    self.erroMessage = erroMessage
  }
  public var localizedDescription: String {
    return erroMessage
  }
}

public typealias SocialLoginResult = Result<SocialUserData, SocialLoginError>
public typealias SocialLoginCompletion = (SocialLoginResult) -> Void

public final class SocialHandler: NSObject {
  public static let shared = SocialHandler()
  
  private lazy var fbLoginManager = LoginManager()
  private lazy var googleLoginManager = GIDLoginManager()
  
  private var gidSignIn: GIDSignIn? {
    return GIDSignIn.sharedInstance()
  }
  
  private override init() {
    super.init()
  }
  
  public func configureOnLaunch(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
    ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    gidSignIn?.clientID = FirebaseApp.app()?.options.clientID
    googleLoginManager.logout { (_) in
    }
  }
  
  public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    let fbFlag = ApplicationDelegate.shared.application(app, open: url, options: options)
    let googleFlag = gidSignIn?.handle(url) ?? false
    return fbFlag || googleFlag
  }
}

extension SocialHandler {
  public enum ShareItem {
    case image(_ image: UIImage)
    case url(_ url: String)
    case message(_ message: String)
  }
  
  public final class ShareActivity: UIActivity {
    let _activityTitle: String
    let _activityImage: UIImage?
    var items: [ShareItem]?
    
    init(title: String, image: UIImage?) {
      _activityTitle = title
      _activityImage = image
      super.init()
    }
    
    
    public override var activityTitle: String? {
      return _activityTitle
    }
    
    public override var activityImage: UIImage? {
      return _activityImage
    }
    
    public override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
      return true
    }
    
    public override func prepare(withActivityItems activityItems: [Any]) {
      items = activityItems.compactMap { (obj) -> ShareItem? in
        if let image = obj as? UIImage {
          return .image(image)
        } else if let url = obj as? URL {
          return .url(url.absoluteString)
        } else if let message = obj as? String {
          return .message(message)
        } else {
          return nil
        }
      }
    }

    public override func perform() {
      r4pidLog(#function)
    }
    
    public override func activityDidFinish(_ completed: Bool) {
      r4pidLog(#function)
    }
  }
  
  public func showShareActivity(items: [ShareItem]) {
    let items: [Any] = items.compactMap { (item) -> Any? in
      switch item {
      case .image(let value):
        return value
      case .url(let value):
        return URL(string: value)
      case .message(let value):
        return value
      }
    }
    let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
    UIApplication.shared.topViewController()?.present(activityViewController, animated: true) {
    }
  }
}

// MARK: - Facebook
extension SocialHandler {
  public func loginFB(completion: @escaping SocialLoginCompletion) {
    guard let topViewController = UIApplication.shared.topViewController() else {
      completion(.failure(.init(erroMessage: "Missing top view controller.")))
      return
    }
    fbLoginManager.logOut()
    fbLoginManager.logIn(permissions: [.publicProfile, .email], viewController: topViewController) { (result) in
      switch result {
      case .cancelled:
        completion(.failure(.init(erroMessage: "Ignore")))
      case .failed(let error):
        completion(.failure(.init(erroMessage: error.localizedDescription)))
      case .success(let grantedPermissions, let declinedPermissions, let token):
        r4pidLog("grantedPermissions: ", grantedPermissions)
        r4pidLog("declinedPermissions: ", declinedPermissions)
        let myGraphRequest = GraphRequest(graphPath: "/me", parameters: ["fields": "id, name, first_name, last_name, email, picture.width(400), gender"], tokenString: token.tokenString, version: Settings.defaultGraphAPIVersion, httpMethod: .get)
        let connection = GraphRequestConnection()
        connection.add(myGraphRequest, completionHandler: { (connection, values, error) in
          if let error = error {
            completion(.failure(.init(erroMessage: error.localizedDescription)))
          } else if let values = values, var socialUser = SocialUserData(type: .facebook(data: JSON(values))) {
            socialUser.authToken = token.tokenString
            completion(.success(socialUser))
          } else {
            completion(.failure(.init(erroMessage: "User profile not found.")))
          }
        })
        connection.start()
//        let credential = FacebookAuthProvider.credential(withAccessToken: token.authenticationToken)
//        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
//          if let error = error {
//            completion(.failure(.init(erroMessage: error.localizedDescription)))
//          } else {
//            if let profile = authResult?.additionalUserInfo?.profile,
//              var socialUser = SocialUserData(type: .facebook(data: JSON(profile))) {
//              socialUser.authToken = token.authenticationToken
//              completion(.success(socialUser))
//            } else {
//              completion(.failure(.init(erroMessage: "User profile not found.")))
//            }
//          }
//        }
      }
    }
  }
}

// MARK: - Google
extension SocialHandler {
  public func loginGoogle(completion: @escaping SocialLoginCompletion) {
    googleLoginManager.login { (result) in
      switch result {
      case .success(let user):
        let socialUser = SocialUserData(user: user)
        completion(.success(socialUser))
        self.googleLoginManager.logout { (_) in
        }
        //        let credential = GoogleAuthProvider.credential(withIDToken: user.authentication.idToken, accessToken: user.authentication.accessToken)
        //        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
        //          if let error = error {
        //            completion(.failure(.init(erroMessage: error.localizedDescription)))
        //          } else {
        //            if let profile = authResult?.additionalUserInfo?.profile,
        //              var socialUser = SocialUserData(type: .google(data: JSON(profile))) {
        //              socialUser.id = user.userID
        //              completion(.success(socialUser))
        //            } else {
        //              completion(.failure(.init(erroMessage: "User profile not found.")))
        //            }
        //          }
      //        }
      case .failure(let error):
        completion(.failure(.init(erroMessage: error.localizedDescription)))
      }
    }
  }
}

private typealias GIDLoginResult = Result<GIDGoogleUser, SocialLoginError>
private typealias GIDLoginCompletion = (GIDLoginResult) -> Void

private final class GIDLoginManager: NSObject {
  private var completion: GIDLoginCompletion?
  
  public override init() {
    super.init()
    
    GIDSignIn.sharedInstance()?.delegate = self
  }
  
  public func login(completion: @escaping GIDLoginCompletion) {
    guard let topViewController = UIApplication.shared.topViewController() else {
      completion(.failure(.init(erroMessage: "Missing top view controller.")))
      return
    }
    GIDSignIn.sharedInstance()?.presentingViewController = topViewController
    self.completion = completion
    GIDSignIn.sharedInstance()?.signIn()
  }
  
  public func logout(completion: @escaping GIDLoginCompletion) {
    guard let topViewController = UIApplication.shared.topViewController() else {
      completion(.failure(.init(erroMessage: "Missing top view controller.")))
      return
    }
    GIDSignIn.sharedInstance()?.presentingViewController = topViewController
    self.completion = completion
    GIDSignIn.sharedInstance()?.signOut()
  }
}

extension GIDLoginManager: GIDSignInDelegate {
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    if let error = error {
      r4pidLog(error.localizedDescription)
      self.completion?(.failure(.init(erroMessage: "Ignore")))
    } else {
      self.completion?(.success(user))
    }
  }
  
  func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
    // Perform any operations when the user disconnects from app here.
    // ...
    if let error = error {
      self.completion?(.failure(.init(erroMessage: error.localizedDescription)))
    } else {
      self.completion?(.success(user))
    }
  }
}
