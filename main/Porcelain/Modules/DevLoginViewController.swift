//
//  DevLoginViewController.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 31/08/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import KRProgressHUD
import SwiftyJSON
import CountryPickerView

class DevLoginViewController: UIViewController {
  @IBOutlet weak var devTitleLabel: UILabel! {
    didSet {
      if AppConfiguration.isProduction {
        devTitleLabel.text = "DEV BUILD (LIVE)"
      } else {
        devTitleLabel.text = "DEV BUILD"
      }
    }
  }
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var mobilePrefixLabel: UILabel?
  
  fileprivate lazy var networkRequest: PorcelainNetworkRequest = {
    let request = PorcelainNetworkRequest()
    request.delegate = self
    return request
  }()
  
  @IBOutlet weak var textFieldContainerView: UIView! {
    didSet {
      self.textFieldContainerView.layer.borderWidth = 1.0
      self.textFieldContainerView.layer.borderColor = UIColor.Porcelain.whiteFour.cgColor
    }
  }
  
  @IBOutlet weak var versionLabel: UILabel! {
    didSet {
      self.versionLabel.text = "Version \(AppConstant.VersionInfo.version) (\(AppConstant.VersionInfo.build))"
    }
  }
  
  
  var countryPicker: CountryPickerView! {
    didSet {
      countryPicker.textColor = UIColor.white
      countryPicker.font = UIFont.Porcelain.openSans()
//      countryPicker.flagSpacingInView = 1.0
    }
  }
  
  @IBAction func loginButtonClicked(sender: UIButton) {
    if let text = self.textField.text {
      if segmentedControl.selectedSegmentIndex == 0 {
        self.networkRequest.getUserID(text)
      } else {
        AppUserDefaults.userID = text
        self.loginCustomer()
      }
    }
  }
  
  @IBAction func segmentDidChangeValue(sender: UISegmentedControl) {
    self.textField.text = ""
    self.mobilePrefixLabel?.isHidden = (sender.selectedSegmentIndex == 0) ? false : true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .blue
    countryPicker = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
    textField.leftView = countryPicker
    textField.leftViewMode = .always
    
    if AppConfiguration.useDummyLoginCredentials {
      textField.text = Dummy.Login.mobile
    }
  }
  
  func loginCustomer() {
    setDummyUser()
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Dev Login Customer"), object: nil, userInfo: nil)
  }
  
  func setDummyUser() {
    let userAccountPredicate: CoreDataRecipe.Predicate = .compoundAnd(predicates: [.isEqual(key: "id", value: AppUserDefaults.userID), .isEqual(key: "isUserAccount", value: true)])
    if CoreDataUtil.get(User.self, predicate: userAccountPredicate) == nil {//create if user not existing
      let yugimotoUser = CoreDataUtil.createEntity(User.self)
      yugimotoUser.id = AppUserDefaults.userID
      yugimotoUser.firstname = "Pull to refresh"
      yugimotoUser.lastname = "account"
      yugimotoUser.isUserAccount = true
      CoreDataUtil.save()
    }
    
    CoreDataUtil.performBackgroundTask({ (moc) in
      let user = CoreDataUtil.createEntity(User.self, inMOC: moc)
      user.id = AppUserDefaults.userID
    })
  }
}

extension DevLoginViewController: PorcelainNetworkRequestDelegateProtocol {
  func requestWillStart(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction) {
    KRProgressHUD.showHUD()
  }
  
  func requestSuccessful(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction, result: Any?) {
    KRProgressHUD.hideHUD()
    guard let result = result else {
      showErrorLoggingIn()
      return
    }
    guard let array = JSON(result).array, array.count > 0 else {
      showErrorLoggingIn()
      return
    }
    guard let response = array[0].dictionary?["data"]?.dictionary else {
      showErrorLoggingIn()
      return
    }
    
    AppUserDefaults.userID = response["custID"]?.string
    AppUserDefaults.firstName = response[PorcelainAPIConstant.Key.firstName]?.string
    AppUserDefaults.lastName = response[PorcelainAPIConstant.Key.lastName]?.string
    AppUserDefaults.email = response["emailAddress"]?.string
    AppUserDefaults.mobileNumber = response["phone"]?.string
    appDelegate.freshChatRegisterIfPossible()
    appDelegate.updateDeviceToken()
    loginCustomer()
    
  }
  
  func requestDidFail(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction, error: Error?, statusCode: Int?, errorMessage: String?) {
    KRProgressHUD.hideHUD()
  }
  
  func showErrorLoggingIn() {
    self.displayAlert(title: "Error", message: "Enter correct mobile number or user id", handler: nil)
  }
}
