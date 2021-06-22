//
//  PPAPIService+Appointment.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 31/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation

private enum APIPath: APIPathProtocol {
  case bookAnAppointment
  case appointment(appointmentID: String)
  
  var rawValue: String {
    switch self {
    case .bookAnAppointment:
      return "/appointment/book"
    case .appointment(let appointmentID):
      return "/appointment/\(appointmentID)"
    }
  }
}

extension PPAPIService.Appointment {
  public static func bookAnAppointment(request: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.bookAnAppointment
    service.method = .post
    service.requestBody = PPAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func getAppointment(appointmentID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.appointment(appointmentID: appointmentID)
    service.method = .get
    service.debugName = #function
    return service
  }
}
