//
//  PorcelainTest+SignIn.swift
//  PorcelainTests
//
//  Created by Patricia Marie Cesar on 25/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import XCTest
@testable import Porcelain
import SlackKit

extension PorcelainTests {
  func testSlackKit() {
    let exp = expectation(description: "Status code: 200")
    
    let slackkit = SlackKit()
    slackkit.addWebAPIAccessWithToken("xoxp-324445085298-323790980992-396129750166-18745196f662b5d1ae3bc334b7056189")
    
    let customerName = "Patricia Marie Cesar"

    let linkAccountAttachment = Attachment(fallback: "No fallback",
                                title: "+65 9064786604",
                                callbackID: "test_action_name_pat",
                                type: nil,
                                colorHex: "#528090",
                                pretext: "Request to sync porcelain account",
                                authorName: customerName,
                                authorLink: nil,
                                authorIcon: nil,
                                //titleLink: "tel://",
      text: "Email: patrizcesar@gmail.com",
      fields: nil,
      actions: [Action(name: "Test action name (pat)", text: "TEST", type: "button", style: ActionStyle.primary, value: "SYNCED", confirm: Action.Confirm(text: "Are you sure you have synced \(customerName)'s account?", title: "Mark as done", okText: "Yes", dismissText: "No"), options: nil, dataSource: nil)],
      imageURL: nil,
      thumbURL: nil,
      footer: "Porcelain iOS app version \(AppConstant.VersionInfo.version) (\(AppConstant.VersionInfo.build))",
      footerIcon: "https://i.imgur.com/jswUTic.png",
      ts: Int(Date().timeIntervalSince1970),
      markdownFields: nil)
//
//    let attachment = Attachment(fallback: "",
//                                title: "+65 9064786604",
//                                callbackID: "test_action_name_pat",
//                                type: nil,
//                                colorHex: "#528090",
//                                pretext: "Request to sync porcelain account",
//                                authorName: customerName,
//                                authorLink: nil,
//                                authorIcon: nil,
//                                //titleLink: "tel://",
//      text: "Email: patrizcesar@gmail.com",
//      fields: nil,
//      actions: nil /*[Action(name: "Mark as done", text: "Mark as done", type: "button", style: ActionStyle.primary, value: "SYNCED", confirm: Action.Confirm(text: "Are you sure you have synced \(customerName)'s account?", title: "Mark as done", okText: "Yes", dismissText: "No"), options: nil, dataSource: nil)]*/,
//      imageURL: nil,
//      thumbURL: nil,
//      footer: "Porcelain iOS app version \(AppConstant.VersionInfo.version) (\(AppConstant.VersionInfo.build))",
//      footerIcon: "https://i.imgur.com/jswUTic.png",
//      ts: Int(Date().timeIntervalSince1970),
//      markdownFields: nil)
    
    
    slackkit.webAPI?.sendMessage(channel: "testprivate",
                                 text: "",
                                 escapeCharacters: false,
                                 username: nil,
                                 asUser: nil,
                                 parse: nil,
                                 linkNames: nil,
                                 attachments: [linkAccountAttachment],
                                 unfurlLinks: nil,
                                 unfurlMedia: nil,
                                 iconURL: "https://i.imgur.com/qlKWtcw.png",
                                 iconEmoji: nil,
                                 success: { _ in
                                  
      exp.fulfill()
    }, failure: { (error) in
      XCTFail(error.localizedDescription)
    })
    
    waitForExpectations(timeout: 15, handler: nil)
  }
}
