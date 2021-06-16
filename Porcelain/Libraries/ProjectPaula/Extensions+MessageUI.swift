//
//  Extensions+MessageUI.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 21/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

extension UIViewController {
  public func openMailSender(subject: String? = nil, toEmails: [String], ccEmails: [String]? = nil, messageBody: String? = nil) {
    if MFMailComposeViewController.canSendMail() {
      let mailSenderViewController = MFMailComposeViewController()
      if let subject = subject {
        mailSenderViewController.setSubject(subject)
      }
      mailSenderViewController.setToRecipients(toEmails)
      mailSenderViewController.setCcRecipients(ccEmails)
      mailSenderViewController.setMessageBody(messageBody ?? "", isHTML: false)
      mailSenderViewController.mailComposeDelegate = self
      present(mailSenderViewController, animated: true, completion: nil)
    } else {
      let dialogHandler = DialogHandler()
      dialogHandler.message = "Oops, looks like email sender was not configured."
      dialogHandler.actions = [.confirm(title: "GOT IT!")]
      DialogViewController.load(handler: dialogHandler).show(in: self)
    }
  }
}

// MARK: - MFMailComposeViewControllerDelegate
extension UIViewController: MFMailComposeViewControllerDelegate {
  public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    dismiss(animated: true, completion: nil)
  }
}
