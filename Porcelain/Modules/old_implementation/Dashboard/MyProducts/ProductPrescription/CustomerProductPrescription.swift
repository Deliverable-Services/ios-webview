//
//  ProductPrescription.swift
//  Porcelain Therapist
//
//  Created by Patricia Marie Cesar on 14/12/2018.
//  Copyright © 2018 Augmatics Pte. Ltd. All rights reserved.
//

import Foundation
import SwiftyJSON

var defaultResponseDateFormat = "yyyy-MM-dd HH:mm:ss"
var defaultResponseDateFormatWithTimeZone = "yyyy-MM-dd'T'HH:mm:ss"

class ProductPrescription {
  var afterNumberOfDays: Int = 0
  var frequency: [String]?
  var id: String?
  var numberOfPumps: Int = 0
  var price: String?
  var productID: String?
  var productImageURL: String?
  var productName: String?
  var lastPurchaseDate: Date?
  var quantity: Int = 0
  var size: String?

  static func from(json: JSON) -> ProductPrescription {
    let prescription = ProductPrescription()
    prescription.afterNumberOfDays = json[PorcelainAPIConstant.Key.afterNumberOfDays].intValue
    prescription.frequency = json[PorcelainAPIConstant.Key.frequency].arrayValue.compactMap({ $0.stringValue })
    prescription.id = json[PorcelainAPIConstant.Key.id].string
    prescription.numberOfPumps = json[PorcelainAPIConstant.Key.numberOfPumps].intValue
    prescription.price = json[PorcelainAPIConstant.Key.price].string
    prescription.productID = json[PorcelainAPIConstant.Key.productID].string
    prescription.productImageURL = json[PorcelainAPIConstant.Key.productImageURL].string
    prescription.productName = json[PorcelainAPIConstant.Key.productName].string
    prescription.lastPurchaseDate = json[PorcelainAPIConstant.Key.lastPurchaseDate].string?.toDate(format: defaultResponseDateFormat)
    prescription.quantity = json[PorcelainAPIConstant.Key.quantity].intValue
    prescription.size = json[PorcelainAPIConstant.Key.size].string
    return prescription
  }
}


