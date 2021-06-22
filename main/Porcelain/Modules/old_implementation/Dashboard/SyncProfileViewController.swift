//
//  SyncProfileViewController.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 04/07/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import SlackKit
import R4pidKit

enum TableRows: Int {
  case firstName = 0
  case lastName = 1
  case email = 2
  case description = 3
}

class SyncProfileViewController: UIViewController, NavigationProtocol {
  fileprivate var firstName: String = ""
  fileprivate var lastName: String = ""
  fileprivate var email: String = ""
  var requestSubmitted: (()->())?
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBAction func submitButtonClicked(sender: UIButton) {
    if !firstName.isEmpty && !lastName.isEmpty {
      let token =  AppConfiguration.testSlackIntegration ? AppConstant.Integration.Slack.testToken: AppConstant.Integration.Slack.token
      let channel = AppConfiguration.testSlackIntegration ? AppConstant.Integration.Slack.testChannel: AppConstant.Integration.Slack.channel
      
      let slackkit = SlackKit()
      slackkit.addWebAPIAccessWithToken(token)
      
      let customerName = "\(String(describing: firstName)) \(String(describing: lastName))"
      let number = "+65 \(AppUserDefaults.customer?.phone ?? "")"
      
      let customerNameLink = "https://porcelain.zenoti.com/Guests/MergeGuest.aspx?UserId=\(AppUserDefaults.customerID ?? "")"
      
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
          value: AppUserDefaults.customerID ?? "",
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
        channel: channel,
        text: "",
//        escapeCharacters: false,
        username: nil,
        asUser: nil,
        parse: nil,
        linkNames: nil,
        attachments: [linkAccountAttachment],
        iconURL: iconURL,
        success: { a in
          DispatchQueue.main.async {
            self.requestSubmitted?()
            self.displayAlert(title: "Success", message: "Successfully sent your request to Porcelain.", handler: { (_) in
              self.popViewController()
            })
          }
      }, failure: { (error) in
        DispatchQueue.main.async {
          self.displayAlert(title: "Error", message: "Please enter your first name and last name.", handler: nil)
        }
      })
    } else {
      DispatchQueue.main.async {
        self.displayAlert(title: "Error", message: "Please enter your first name and last name.", handler: nil)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "SYNC ACCOUNT REQUEST"
    generateLeftNavigationButton(image: #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysOriginal), selector: #selector(popViewController))
    self.firstName = AppUserDefaults.customer?.firstName ?? ""
    self.lastName = AppUserDefaults.customer?.lastName ?? ""
    self.email = AppUserDefaults.customer?.email ?? ""
  }
}

extension SyncProfileViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 4
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch TableRows(rawValue: indexPath.row)! {
    case .firstName:
      let cell = tableView.dequeueReusableCell(withIdentifier: SyncProfileTextFieldCell.identifier) as! SyncProfileTextFieldCell
      cell.configure(text: firstName, placeholder: "First name")
      cell.textField.text = firstName
      cell.updatedTextFieldBlock = { text in
        self.firstName = text
      }
      return cell
    case .lastName:
      let cell = tableView.dequeueReusableCell(withIdentifier: SyncProfileTextFieldCell.identifier) as! SyncProfileTextFieldCell
      cell.configure(text: lastName, placeholder: "Last name")
      cell.textField.text = lastName
      cell.updatedTextFieldBlock = { text in
        self.lastName = text
      }
      return cell
    case .email:
      let cell = tableView.dequeueReusableCell(withIdentifier: SyncProfileTextFieldCell.identifier) as! SyncProfileTextFieldCell
      cell.configure(text: lastName, placeholder: "Email (optional)")
      cell.textField.text = email
      cell.updatedTextFieldBlock = { text in
        self.email = text
      }
      return cell
    case .description:
      return tableView.dequeueReusableCell(withIdentifier: "SyncDesciptionCell")!
    }
  }
}
