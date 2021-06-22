//
//  R4pidDefaults.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 20/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation

public struct R4pidDefaultskey: CustomStringConvertible, Equatable {
  var value: String
  
  public init(value: String) {
    self.value = value
  }
  
  public var description: String {
    return value
  }
  
  public static func == (lhs: R4pidDefaultskey, rhs: R4pidDefaultskey) -> Bool {
    return lhs.description == rhs.description
  }
}

public final class R4pidDefaults {
  public static let shared = R4pidDefaults()
  
  private var myValue: Any?
  private init() {
  }
  
  public convenience init(value: Any?) {
    self.init()
    myValue = value
  }
  
  public var value: Any? {
    return myValue
  }
  
  public var string: String? {
    if let str = (value as? String) ?? number?.stringValue {
      return str
    } else {
      return nil
    }
  }
  
  public var stringValue: String {
    if let string = string {
      return string
    } else {
      return ""
    }
  }
  
  public var number: NSNumber? {
    if let value = value {
      return value as? NSNumber
    } else {
      return nil
    }
  }
  
  public var numberValue: NSNumber {
    if let number = number {
      return number
    } else {
      return stringValue.toNumber()
    }
  }
  
  public var bool: Bool? {
    return number?.boolValue
  }
  
  public var boolValue: Bool {
    return numberValue.boolValue
  }
  
  public var int: Int? {
    return number?.intValue
  }
  
  public var intValue: Int {
    return numberValue.intValue
  }
  
  public subscript(_ key: R4pidDefaultskey) -> R4pidDefaults? {
    get {
      return R4pidDefaults(value: UserDefaults.standard.value(forKey: key.description))
    }
    set {
      UserDefaults.standard.set(newValue?.value, forKey: key.description)
    }
  }
}
