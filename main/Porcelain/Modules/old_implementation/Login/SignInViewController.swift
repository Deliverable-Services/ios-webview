//
//  SignInViewController.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 02/07/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import KRProgressHUD
import CountryPickerView
import R4pidKit

class SignInViewController: UIViewController {
  typealias CompletionHandlerBlock = (Bool) -> Void
  var completionHandler: CompletionHandlerBlock?
  
  @IBOutlet weak var testButton: UIButton!
  @IBOutlet weak var devLoginContainerView: UIView! {
    didSet {
      self.devLoginContainerView.isHidden = !AppConfiguration.devLogin
    }
  }
  
  fileprivate lazy var networkRequest: PorcelainNetworkRequest = {
    let request = PorcelainNetworkRequest()
    request.delegate = self
    return request
  }()
  
  @IBOutlet private weak var scrollView: UIScrollView! {
    didSet {
      scrollView.alwaysBounceVertical = false
    }
  }
  @IBOutlet weak var versionLabel: UILabel! {
    didSet {
      self.versionLabel.text = "Version \(AppMainInfo.version ?? "") (\(AppMainInfo.build ?? ""))"
    }
  }
  @IBOutlet weak var mobileNumberContainerView: UIView!
  @IBOutlet weak var firstNameContainerView: UIView!
  @IBOutlet weak var lastNameContainerView: UIView!
  
  @IBOutlet weak var mobileNumberTextField: UITextField! {
    didSet {
      mobileNumberTextField.tintColor = UIColor.white
    }
  }
  @IBOutlet weak var firstNameTextField: UITextField! {
    didSet {
      firstNameTextField.tintColor = UIColor.white
      firstNameTextField.attributedPlaceholder = "First name"
        .withFont(UIFont.Porcelain.openSans(14))
        .withTextColor(UIColor.white)
        .withKern(0.5)
    }
  }
  
  @IBOutlet weak var lastNameTextField: UITextField! {
    didSet {
      lastNameTextField.tintColor = UIColor.white
      lastNameTextField.attributedPlaceholder = "Last name"
        .withFont(UIFont.Porcelain.openSans(14))
        .withTextColor(UIColor.white)
        .withKern(0.5)
    }
  }
  
  var countryPicker: CountryPickerView! {
    didSet {
      countryPicker.textColor = UIColor.white
      countryPicker.font = UIFont.Porcelain.openSans()
      countryPicker.flagSpacingInView = 1.0
    }
  }
  
  @IBAction func nextButtonClicked(_ sender: UIButton) {
    if isInfoValid() {
      self.login()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.observeTapAndDismissKeyboard()
    
    countryPicker = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
    countryPicker.dataSource = self
    
    mobileNumberTextField.leftView = countryPicker
    mobileNumberTextField.leftViewMode = .always
    
    if AppConfiguration.useDummyLoginCredentials {
      self.mobileNumberTextField.text = Dummy.Login.mobile
      self.firstNameTextField.text = Dummy.Login.firstName
      self.lastNameTextField.text = Dummy.Login.lastName
    }
    
    if AppConfiguration.testSlackIntegration {
      self.testButton.isHidden = false
    }
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "Dev Login Customer"), object: nil, queue: nil) { (_) in
      self.dismissViewController()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.isNavigationBarHidden = false
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.isNavigationBarHidden = true
    
    //TESTING
//    CalendarEventUtil.searchEvent(query: "TESTING 2") { (events) in
//      if let event = events.first {
//        CalendarEventUtil.saveOrUpdateEvent(event, eventModel: CalendarEventItem(
//          title: "TESTING 2",
//          startDate: Date().dateByAdding(hours: 1),
//          endDate: Date().dateByAdding(hours: 2),
//          alarms: [.onTime, .oneHourBefore],
//          notes: "Testing updated"), completion: { (eventID) in
//            if eventID != nil {
//              print("saved: ", eventID!)
//            } else {
//              print("not saved")
//            }
//        })
//      }
//    }
//    
//    CalendarEventUtil.searchEvent(query: "TESTING 1") { (events) in
//      events.forEach({ (event) in
//        CalendarEventUtil.deleteEvent(event.eventIdentifier)
//      })
//    }
  }
  
  fileprivate func isInfoValid() -> Bool {
    if (mobileNumberTextField.text?.isEmpty) ?? false {
      displayAlert(title: AppConstant.Text.defaultErrorTitle, message: "Enter mobile number", handler: nil)
      return false
    } else if (firstNameTextField.text?.isEmpty) ?? false {
      displayAlert(title: AppConstant.Text.defaultErrorTitle, message: "Enter first name", handler: nil)
      return false
    } else if (lastNameTextField.text?.isEmpty) ?? false {
      displayAlert(title: AppConstant.Text.defaultErrorTitle, message: "Enter lastName name", handler: nil)
      return false
    } else {
//      AppUserDefaults.firstName = firstNameTextField.text
//      AppUserDefaults.lastName = lastNameTextField.text
      return true
    }
  }
  
  fileprivate func login() {
    self.networkRequest.signInMobile(countryPicker.selectedCountry.phoneCode, mobileNumber: mobileNumberTextField.text ?? "empty mobile number", deviceToken: AppUserDefaults.deviceToken)
    if AppUserDefaults.deviceToken == nil {
      appDelegate.configurePushNotification(launchOptions: nil)
    }
  }
}

/****************************************************************/

extension SignInViewController: PorcelainNetworkRequestDelegateProtocol {
  func requestWillStart(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction) {
    KRProgressHUD.showHUD()
  }
  
  func requestDidFail(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction,
                      error: Error?, statusCode: Int?, errorMessage: String?) {
    KRProgressHUD.hideHUD()
    
    print(statusCode.debugDescription)
    guard let action = action as? SignInRequestAction else { return }
    switch action {
    case .signInMobile:
      self.displayAlert(title: "Error Signing In", message: errorMessage ?? (error?.localizedDescription ?? AppConstant.Text.defaultErrorMessage), handler: nil)
    default: break
    }
  }
  
  func requestSuccessful(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction, result: Any?) {
    KRProgressHUD.hideHUD()
    
    guard let action = action as? SignInRequestAction else { return }
    switch action {
    case .signInMobile:
      let otpViewController = UIStoryboard.get(.logIn).instantiateViewController(withIdentifier: OTPViewController.identifier) as! OTPViewController
      otpViewController.countryCode = countryPicker.selectedCountry.phoneCode
      otpViewController.mobileNumber = mobileNumberTextField.text!
      self.navigationController?.pushViewController(otpViewController, animated: true)
      otpViewController.completionHandler = { success in
        self.completionHandler?(success)
      }
    default: break
    }
  }
}

let limitLength = 13
extension SignInViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let text = textField.text else { return true }
    let newLength = text.count + string.count - range.length
    return newLength <= limitLength
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.login()
    return true
  }
}

/****************************************************************/

private enum StoryboardIdentifier: String {
  case toTerms = "SignInToTermsAndConditions"
  case toMain = "SignInToMain"
}

extension SignInViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = StoryboardIdentifier(rawValue: segue.identifier ?? "") else {
      return
    }
    
    var destinationVC: UIViewController? = segue.destination
    if let navigationVC = segue.destination as? UINavigationController {
      destinationVC = navigationVC.childViewControllers.first
    }
    
    switch identifier {
    case .toTerms:
      let vc = destinationVC as? WebViewController
      vc?.url = URL(string: "https://shopporcelain.com/term-of-use/")
    case .toMain:
      break
    }
  }
}


import SlackKit

extension SignInViewController {
  @IBAction func testSlackKit() {
    let token = "xoxp-324445085298-323790980992-396129750166-18745196f662b5d1ae3bc334b7056189"
    
    let slackkit = SlackKit()
    slackkit.addWebAPIAccessWithToken(token)
    
    let customerName = "Isaac Lim"
    let number = "+65 9064786604"
    let email = "isaac.lim@augmatics.tech"
    
    let zenotiProfile = "0a224542-401d-440e-b3e9-88cfdcc3d385"
    let userID = "22071"
    let customerNameLink = "https://porcelain.zenoti.com/Guests/MergeGuest.aspx?UserId=\(zenotiProfile)"
    
    let actionName = "Notify account synced"
    let actionCallbackID = "notify_account_synced"
    
    let buttonText = "NOTIFY USER"
    let confirmTitle = "Notify User"
    let confirmMessage = "Are you sure you have synced \(customerName)'s account?"
    
    let preText = "Request to sync zenoti account"
    let footerText = "Porcelain iOS app version \(AppMainInfo.version ?? "") (\(AppMainInfo.build ?? ""))"
    let footerIcon = "https://i.imgur.com/jswUTic.png"
    let timeStamp = Int(Date().timeIntervalSince1970)
    
    let linkAccountAttachment = Attachment(
      fallback: "Notify user account sync error",
      title: customerName,
      callbackID: actionCallbackID,
      type: nil,
      colorHex: "#528090",
      pretext: preText,
      authorName: number,
      titleLink: customerNameLink,
      text: email,
      actions: [Action(
        name: actionName,
        text: buttonText,
        type: "button",
        style: .primary,
        value: userID,
        confirm: Action.Confirm(
          text: confirmMessage,
          title: confirmTitle,
          okText: "Yes",
          dismissText: "No"),
        options: [Action.Option(text: "footer", value: footerText)])],
      footer: footerText,
      footerIcon: footerIcon,
      ts: timeStamp)
    
    let iconURL = "https://i.imgur.com/qlKWtcw.png"
    
    slackkit.webAPI?.sendMessage(
      channel: "test",
      text: "",
//      escapeCharacters: false,
      username: nil,
      asUser: nil,
      parse: nil,
      linkNames: nil,
      attachments: [linkAccountAttachment],
      iconURL: iconURL,
      success: { a in
        
    }, failure: { (error) in
      print(error)
    })
  }
}

extension SignInViewController: CountryPickerViewDataSource {
  func sectionTitleForPreferredCountries(in countryPickerView: CountryPickerView) -> String? {
    return "Default country"
  }
  
  func showOnlyPreferredSection(in countryPickerView: CountryPickerView) -> Bool {
    return false
  }
  
  func navigationTitle(in countryPickerView: CountryPickerView) -> String? {
    return "Select a Country"
  }
  
  func searchBarPosition(in countryPickerView: CountryPickerView) -> SearchBarPosition {
    return .tableViewHeader
  }
  
  func showPhoneCodeInList(in countryPickerView: CountryPickerView) -> Bool {
    return true
  }
  
}
