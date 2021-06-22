//
//  AppUserDefaults.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 27/05/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import R4pidKit

extension R4pidDefaultskey {
  fileprivate static let isProduction = R4pidDefaultskey(value: "233FE4OPZ8C45CF1F6419CD6E9FD342780741B73")
  fileprivate static let deviceToken =  R4pidDefaultskey(value: "580C8870A88D986251D8F427229E4929739F4A53")
  fileprivate static let customerID =  R4pidDefaultskey(value: "9EF8254D9456FC233FE419C80741B737CA5D400F")
  fileprivate static let oneTimeLogout = R4pidDefaultskey(value: "EC040B03D7ADF98769D763F0C8C48A4686DAD715")
  fileprivate static let oneTimeMainWalkthrough = R4pidDefaultskey(value: "6251D8FE3D6E9F0FD342723D987CA444B580459D")
  fileprivate static let oneTimeBookAppointmentWalkthrough = R4pidDefaultskey(value: "D986251D8F42723E444B580459D3D6E9F0FD37CA")
  fileprivate static let requests = R4pidDefaultskey(value: "S0LAVMO5ZURX3KBZ5C42BRGC5X1I160AKQEV3BS1")
  fileprivate static let lastPaymentSelection = R4pidDefaultskey(value: "0KUKP2CG9BGX7PKO3OPZ8C45CF1F647E91C4729DF5")
  fileprivate static let allowToShareFeedbackSocial = R4pidDefaultskey(value: "G9BGX7PKO7593CFF4D7A7E908BCA9C1F0F3OPZ8C45CF")
  fileprivate static let apiVersion = R4pidDefaultskey(value: "7FA6B20698F9B77593CFF4D7A766E071849ED32E")
}

public final class AppUserDefaults {
  public static var isProduction: Bool {
    get {
      return R4pidDefaults.shared[.isProduction]?.bool ?? false
    }
    set {
      R4pidDefaults.shared[.isProduction] = .init(value: newValue)
    }
  }
  public static var deviceToken: String? {
    get {
      return R4pidDefaults.shared[.deviceToken]?.string
    }
    set {
      R4pidDefaults.shared[.deviceToken] = .init(value: newValue)
    }
  }
  public static var customerID: String? {
    get {
      return R4pidDefaults.shared[.customerID]?.string
    }
    set {
      R4pidDefaults.shared[.customerID] = .init(value: newValue)
    }
  }
  public static var customer: Customer?  {
    get {
      guard let customerID = customerID else { return nil }
      return User.getUser(id: customerID, type: .customer)
    } set {
      customerID = newValue?.id
    }
  }
  
  // one time logout
  public static var oneTimeLogout: Bool {
    get {
      return R4pidDefaults.shared[.oneTimeLogout]?.bool ?? false
    }
    set {
      R4pidDefaults.shared[.oneTimeLogout] = .init(value: newValue)
    }
  }

  public static var oneTimeMainWalkthrough: Bool {
    get {
      return R4pidDefaults.shared[.oneTimeMainWalkthrough]?.bool ?? false
    }
    set {
      R4pidDefaults.shared[.oneTimeMainWalkthrough] = .init(value: newValue)
    }
  }
  
  public static var oneTimeBookAppointmentWalkthrough: Bool {
    get {
      return R4pidDefaults.shared[.oneTimeBookAppointmentWalkthrough]?.bool ?? false
    }
    set {
      R4pidDefaults.shared[.oneTimeBookAppointmentWalkthrough] = .init(value: newValue)
    }
  }
  
  public static var lastPaymentSelection: Int? {
    get {
      return R4pidDefaults.shared[.lastPaymentSelection]?.int
    }
    set {
      R4pidDefaults.shared[.lastPaymentSelection] = .init(value: newValue)
    }
  }
  
  public static var allowToShareFeedbackSocial: Bool {
    get {
      return R4pidDefaults.shared[.allowToShareFeedbackSocial]?.bool ?? true
    }
    set {
      R4pidDefaults.shared[.allowToShareFeedbackSocial] = .init(value: newValue)
    }
  }
  
  // apiVersion
  public static var apiVersion: String {
    get {
      return R4pidDefaults.shared[.apiVersion]?.string ?? "1.1.0"
    }
    set (newValue){
      R4pidDefaults.shared[.apiVersion] = .init(value: newValue)
    }
  }
}


extension AppUserDefaults  {
  public static var isLoggedIn: Bool  {
    return customer?.id != nil && customer?.accessToken != nil
  }
  
  public static func clearData() {
    customer = nil
    oneTimeLogout = false
    allowToShareFeedbackSocial = true
    AppSocketManager.shared.room = nil
  }
}
