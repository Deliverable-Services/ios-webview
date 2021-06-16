//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by Justine Angelo Rangel on 1/22/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import UserNotifications
import FirebaseMessaging
import SwiftyJSON
import R4pidKit

class NotificationService: UNNotificationServiceExtension {
  
  var contentHandler: ((UNNotificationContent) -> Void)?
  var bestAttemptContent: UNMutableNotificationContent?
  
  override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
    self.contentHandler = contentHandler
    bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
    
    if let bestAttemptContent = bestAttemptContent {
      // Modify the notification content here...
      let imageSTR = JSON(request.content.userInfo).image.stringValue
      if let imageURL = URL(string: imageSTR), let imageData = NSData(contentsOf: imageURL) {
        let identifier = imageURL.deletingPathExtension().appendingPathExtension(imageURL.pathExtension.emptyToNil ??  ".png").lastPathComponent
        if let attachment = NotificationService.create(identifier: identifier, imageData: imageData, options: nil) {
          bestAttemptContent.attachments = [attachment]
        }
      }
      FIRMessagingExtensionHelper().populateNotificationContent(bestAttemptContent, withContentHandler: contentHandler)
    }
  }
  
  override func serviceExtensionTimeWillExpire() {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
      contentHandler(bestAttemptContent)
    }
  }
  
  private static func create(identifier: String, imageData: NSData, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
    let fileManager = FileManager.default
    let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
    let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
    do {
      try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
      let fileURL = tmpSubFolderURL.appendingPathComponent(identifier)
      try imageData.write(to: fileURL)
      let imageAttachment = try UNNotificationAttachment(identifier: identifier, url: fileURL, options: nil)
      return imageAttachment
    } catch {
      print("error " + error.localizedDescription)
    }
    return nil
  }
}
