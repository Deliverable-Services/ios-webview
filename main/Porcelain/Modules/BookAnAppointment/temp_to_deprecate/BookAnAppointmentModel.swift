//
//  BookAnAppointmentModel.swift
//  Porcelain
//
//  Created by Justine Rangel on 27/07/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct BAALocationModel {
  var id: String?
  var type: String?
  var address: String?
  var name: String?
  
  init(json: JSON) {
    id = json[PorcelainAPIConstant.Key.id].string
    type = json[PorcelainAPIConstant.Key.type].string
    address = json[PorcelainAPIConstant.Key.address].string
    name = json[PorcelainAPIConstant.Key.name].string
  }
}

public struct BAATreatmentModel {
  var id: String?
  var type: String?
  var name: String?
  
  init(json: JSON) {
    id = json[PorcelainAPIConstant.Key.id].string
    type = json[PorcelainAPIConstant.Key.type].string
    name = json[PorcelainAPIConstant.Key.name].string
  }
}

public struct BAATherapistModel {
  var id: String?
  var name: String?
  var type: String?
  var locations: [BAALocationModel]?
  
  init(json: JSON) {
    id = json[PorcelainAPIConstant.Key.id].string
    type = json[PorcelainAPIConstant.Key.type].string
    name = json[PorcelainAPIConstant.Key.name].string
  }
}

extension BAATherapistModel {
  public static func parseTherapists(_ therapists: Any?, locationID: String? = nil) -> [BAATherapistModel] {
    guard let therapists = therapists else { return [] }
    guard let therapistArray = JSON(therapists)[0].dictionaryValue[PorcelainAPIConstant.Key.data]?.array else { return [] }
    
    var therapistSet: [BAATherapistModel] = []
    
    therapistArray.forEach { (therapist) in
      var newTherapist = BAATherapistModel(json: therapist)
      let locationModel = BAALocationModel(json: therapist[PorcelainAPIConstant.Key.location])
      if locationID == locationModel.id { //if location id is selected include the therapist
        newTherapist.locations = []
        therapistSet.append(newTherapist)
      }
    }
    
    return therapistSet
  }
}
