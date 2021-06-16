//
//  SocketConstant.swift
//
//  Created by Patricia Cesar
//  Copyright © 2018 Patricia Cesar. All rights reserved.
//

import Foundation
import R4pidKit

open class AppSocketConstant: NSObject {
  override init() { }
  public struct Request { }
  public struct Key { }
}

extension AppSocketConstant.Request {
  public static let scheme = "http"
  public static let host = AppUserDefaults.isProduction ? "13.251.155.148": "13.228.83.66"
  public static let port = 7000
}

extension AppSocketConstant.Key {
  public static let index = "index"
  public static let room = "room"
  public static let userID = "userId"
  public static let type = "type"
  public static let data = "data"
}
