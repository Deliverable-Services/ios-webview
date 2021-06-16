//
//  OTPViewController.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 02/07/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import KRProgressHUD
import SwiftyJSON
import Crashlytics
import Firebase
import R4pidKit

class OTPViewController: UIViewController {
  typealias CompletionHandlerBlock = (Bool) -> Void
  var completionHandler: CompletionHandlerBlock?
  
  var countryCode: String!
  var mobileNumber: String!
  
  fileprivate lazy var networkRequest: PorcelainNetworkRequest = {
    let request = PorcelainNetworkRequest()
    request.delegate = self
    return request
  }()
  
  @IBOutlet var textFieldCollection: [UITextField]!
  @IBOutlet var otpDescLabel: UILabel!
  
  @IBAction func resendCodeButtonClicked(sender: UIButton) {
    self.networkRequest.signInMobile(countryCode, mobileNumber: mobileNumber, deviceToken: AppUserDefaults.deviceToken ?? "no device token")
  }
  
  @IBAction func changePhoneNumberButtonClicked(sender: UIButton) {
    self.navigationController?.popViewController(animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let count = mobileNumber.count
    otpDescLabel.text = "One Time Password (OTP) has been sent to your mobile \(String(repeating: "*", count: count-4)) \(mobileNumber.suffix(4))"
    for textField in self.textFieldCollection {
      textField.layer.borderColor = UIColor.Porcelain.whiteFour.cgColor
      textField.layer.borderWidth = 1.0
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.isNavigationBarHidden = true
  }
  
  func getOTP() -> String {
    var otp = ""
    for textField in self.textFieldCollection {
      otp.append(textField.text ?? " ")
    }
    return otp
  }
  
  @IBAction func endEditing(textField: UITextField) {
    print("TEXT_\(String(describing: textField.text))_TEXT")
    if textField.text?.isEmpty ?? false {
      let prevTag = textField.tag - 1
      guard prevTag > 0 else {
        return
      }
      
      let prevTextField = textFieldCollection[prevTag]
      prevTextField.becomeFirstResponder()
    } else {
      let nextTag = textField.tag + 1
      guard nextTag < textFieldCollection.count else {
        self.networkRequest.signInVerifyOTP(self.getOTP(), countryCode: countryCode, mobileNumber: mobileNumber, firstName: AppUserDefaults.firstName ?? "", lastName: AppUserDefaults.lastName ?? "" )
        return
      }
      
      let nextTextField = textFieldCollection[nextTag]
      nextTextField.becomeFirstResponder()
    }
  }
}

extension OTPViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let text = textField.text else { return true }
    let newLength = text.count + string.count - range.length
    return newLength <= 1
  }
}
/****************************************************************/

extension OTPViewController: PorcelainNetworkRequestDelegateProtocol {
  func requestWillStart(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction) {
    KRProgressHUD.showHUD()
    self.textFieldCollection.last?.resignFirstResponder()
  }
  
  func requestDidFail(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction,
                      error: Error?, statusCode: Int?, errorMessage: String?) {
    KRProgressHUD.hideHUD()
    print("Failed: ", error ?? "")
    print(statusCode.debugDescription)
    guard let action = action as? SignInRequestAction else { return }
    switch action {
    case .signInVerifyOTP:
      self.displayAlert(title: "Error", message: errorMessage ?? "There was an error processing your request. Make sure you entered correct OTP.", handler: nil)
    default: break
    }
  }
  
  func requestSuccessful(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction, result: Any?) {
    KRProgressHUD.hideHUD()
    guard let action = action as? SignInRequestAction else { return }
    
    
    switch action {
    case .signInVerifyOTP:
      guard let result = result else { return }
      guard let array = JSON(result).array, array.count > 0 else { return }
      guard let response = array[0].dictionary?["data"]?.array?[0].dictionary else { return }
      
      self.saveProfile(response)
      self.completionHandler?(true)
      
    default: break
    }
  }

  private func saveProfile(_ response: [String: JSON]?) {
    DispatchQueue.main.async() {
      AppUserDefaults.customer?.id = response?["id"]?.string
      AppUserDefaults.email = response?["emailAddress"]?.string
      AppUserDefaults.firstName = response?[PorcelainAPIConstant.Key.firstName]?.string
      AppUserDefaults.lastName = response?[PorcelainAPIConstant.Key.lastName]?.string
      AppUserDefaults.mobileNumber = response?["contactInfo"]?.string
//      AppUserDefaults.mobileNumber = response?["contactInfo"]?.string
      
      // Log user in Crashlytics
      Crashlytics.sharedInstance().setUserIdentifier(AppUserDefaults.customer?.id ?? "")
      Crashlytics.sharedInstance().setObjectValue(AppUserDefaults.mobileNumber, forKey: PorcelainAPIConstant.Key.mobileNumber)
      // Firebase set set user id
      Analytics.setUserID(AppUserDefaults.customer?.id)
      
      CoreDataUtil.performBackgroundTask({ (moc) in
//        CoreDataUtil.truncateEntity(User.self, inMOC: moc)
        CoreDataUtil.truncateEntity(User.self, inMOC: moc)
//        CoreDataUtil.truncateEntity(User.self, inMOC: moc)
      }) { (_) in //do main thread here
        appDelegate.updateDeviceToken()
      }
    }
  }
}
