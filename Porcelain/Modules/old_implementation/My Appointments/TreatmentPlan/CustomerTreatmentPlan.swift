//
//  CustomerTreatmentPlan.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 19/01/2019.
//  Copyright © 2019 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import SwiftyJSON

class CustomerTreatmentPlan {
  var afterNumberOfDays: Int = 0
  var endDate: Date?
  var id: String?
  var sessionsLeft: Int?
  var startDate: Date?
  var suggestedDates: [String] = []
  var treatmentID: String?
  var treatmentName: String?
  var showBookNow: Bool = false
  
  static func from(json: JSON) -> CustomerTreatmentPlan {
    let plan = CustomerTreatmentPlan()
    plan.afterNumberOfDays = json[PorcelainAPIConstant.Key.afterNumberOfDays].intValue
//    plan.endDate = json[PorcelainAPIConstant.Key.endDate].string?.toDate(format: defaultResponseDateFormat)
    plan.id = json[PorcelainAPIConstant.Key.id].string
    plan.sessionsLeft = json[PorcelainAPIConstant.Key.sessionLeft].int
//    plan.startDate = json[PorcelainAPIConstant.Key.startDate].string?.toDate(format: defaultResponseDateFormat)
    plan.treatmentID = json[PorcelainAPIConstant.Key.treatmentID].string
    plan.treatmentName = json[PorcelainAPIConstant.Key.treatmentName].string
    plan.showBookNow = json[PorcelainAPIConstant.Key.bookNow].boolValue
    return plan
  }
}
