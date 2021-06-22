//
//  AppConstantVariable.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 17/05/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit

open class AppConstant: NSObject {
  override init() { }
  
  public struct Analytics {
    public struct Tracker { }
    public struct Event { }
  }
  
  public struct Integration {
    public struct Stripe { }
    public struct Slack { }
    public struct FreshChat{}
    public struct ApplePay {}
  }
  
  public struct KeychainAccess { }
  
  public struct Name {
    public struct Screen { }
  }
  
  public struct Text { }
  
  public struct VersionInfo { }
}
