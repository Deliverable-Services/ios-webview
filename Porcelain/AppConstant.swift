//
//  AppConstant.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 17/05/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation

public typealias VoidCompletion = () -> ()
public typealias BoolCompletion = (Bool) -> ()
public typealias IntCompletion = (Int) -> ()
public typealias StringCompletion = (String) -> ()
public typealias DateCompletion = (Date) -> ()

public func concatenate(_ items: Any...) -> String { return items.map({ String(describing: $0)}).joined() }

extension AppConstant {
  public static let companyName = "Porcelain Pte Ltd."
  public static let estoreURL = "https://porcelainskin.com"
  public static let privacyURL = estoreURL.appending("/privacy")
  public static let termOfUseURL = estoreURL.appending("/term-of-use")
  public static let supportEmail = "knockknock@porcelainskin.com"
  public static let currencySymbol = "$"
  public static let facebookURL = "https://www.facebook.com/porcelainskinofficial"
  public static let instagramURL = "http://instagram.com/porcelainskinofficial"
  public static let youtubeURL = "https://www.youtube.com/channel/UCcUWCh4uNIPDwBZP4r7TfDA"
  public static let shippingFee = 4.90
  public static let whatsappPhone = "+65 9721 1008"
  public static let generalCallPhone = "+65 6227 9692"
  
  public static func whatsapp(phone: String) -> String {
    return "https://api.whatsapp.com/send?phone=\(phone)"
  }
}

extension AppConstant.Integration.Slack {
  public static let token = "xoxp-13180332437-13181072007-393506728129-24da20e073abd6d4b46bab97ae609fd6"
  public static let channel = "porcelainapp"
 
  public static let testToken = "xoxp-324445085298-323790980992-396129750166-18745196f662b5d1ae3bc334b7056189"
  public static let testChannel = "test"
}

extension AppConstant.Integration.FreshChat {
  public static let appID = "4a05cd94-2c79-4f9d-a066-8196ee4dcf98"
  public static let appKey = "0c2f26a7-5f5d-43fd-afc6-81d0f21422fe"
}
 
extension AppConstant.Integration.Stripe {
  public static let publishableKey = AppConfiguration.useDevPayment ? "pk_test_ROIoHFCeNbUo96VFmhOeyN9Z": "pk_live_yCG094LTxg3TCX8SrhMQqwiC"
}

extension AppConstant.Integration.ApplePay {
  public static let merchantIdentifier = "merchant.customer.porcelainskin"
  public static let countryCode = "SG"
  public static let currencyCode = "sgd"
}

extension AppConstant.Text {
  public static let defaultErrorTitle = "Oops!"
  public static let defaultErrorMessage = "Oops! Something went wrong. Please try again later."
}
