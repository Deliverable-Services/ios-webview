//
//  BAScheduleCoreModels.swift
//  Porcelain
//
//  Created by Justine Rangel on 19/10/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct BACalendarScheduleDate {
  var date: Date?
  var locations: [BAScheduleLocation]
}

extension BACalendarScheduleDate {
  public static func parseAvailableSchedules(_ schedules: Any?) -> [BACalendarScheduleDate] {
    guard let schedules = schedules else { return [] }
    guard let scheduleArray = JSON(schedules)[0].dictionaryValue[PorcelainAPIConstant.Key.data]?.array else { return [] }
    return scheduleArray.map { (json) -> BACalendarScheduleDate in
      let dateString = json[PorcelainAPIConstant.Key.date].string
      let date = dateString?.toDate(format: "YYYY-MM-dd")
      var isNow = false
      if let dateString = dateString {
        isNow = dateString == Date().toString(WithFormat: "YYYY-MM-dd")
      }
      let locations = json[PorcelainAPIConstant.Key.locations].arrayValue.map { (json) -> BAScheduleLocation in
        return BAScheduleLocation(json: json, isNow: isNow)
        }.filter({ return !$0.therapists.isEmpty }) //remove location with empty therapits
      return BACalendarScheduleDate(date: date, locations: locations)
      }.filter { (calendarScheduleDates) -> Bool in
        //filter out dates that don't show any therapist/s
        return calendarScheduleDates.locations.contains(where: { !$0.therapists.isEmpty })
      }
  }
}

public struct BAScheduleLocation {
  init(json: JSON, isNow: Bool) {
    id = json[PorcelainAPIConstant.Key.id].string ?? ""
    name = json[PorcelainAPIConstant.Key.name].string ?? ""
    address = json[PorcelainAPIConstant.Key.address].string ?? ""
    therapists = json[PorcelainAPIConstant.Key.therapists].arrayValue.map { (json) -> BAScheduleTherapist in
      return BAScheduleTherapist(json: json, isNow: isNow)
      }.filter({ return !$0.timeSlots.isEmpty }) //remove therapists with empty  timeSlots
  }
  
  init(id: String, name: String, address: String, therapists: [BAScheduleTherapist]) {
    self.id = id
    self.name = name
    self.address = address
    self.therapists = therapists
  }
  
  var id: String
  var name: String
  var address: String
  var therapists: [BAScheduleTherapist]
}

public struct BAScheduleTherapist: Equatable {
  init(json: JSON, isNow: Bool) {
    id = json[PorcelainAPIConstant.Key.id].string ?? ""
    name = json[PorcelainAPIConstant.Key.name].string ?? ""
    let timeNowInt = Date().toString(WithFormat: "HHmm").toNumber().intValue
    timeSlots = json[PorcelainAPIConstant.Key.slots].arrayValue.map { (json) -> BAScheduleTime in
      return BAScheduleTime(json: json)
      }.filter({ (time) -> Bool in
        if isNow {//added if now then compare date from api must be greater that the current time
          let timeInt = time.rawTime.replacingOccurrences(of: ":", with: "").toNumber().intValue
          return timeInt > timeNowInt
        } else {
          return true
        }
      })
  }
  
  init(id: String, name: String, timeSlots: [BAScheduleTime]) {
    self.id = id
    self.name = name
    self.timeSlots = timeSlots
  }
  
  var id: String
  var name: String
  var timeSlots: [BAScheduleTime]
  
  public static func == (lhs: BAScheduleTherapist, rhs: BAScheduleTherapist) -> Bool {
    return lhs.id == rhs.id
  }
}

public struct BAScheduleTime: Equatable {
  init(json: JSON) {
    let rawTime = json[PorcelainAPIConstant.Key.time].string ?? ""
    self.rawTime = rawTime
    let time = rawTime.components(separatedBy: ":")
    let hourInt = time.first?.toNumber().intValue ?? 0
    let minutesInt = time.last?.toNumber().intValue ?? 0
    if hourInt == 12 {
      hour = time.first ?? "00"
      if minutesInt == 0 {
        amPM = "NN"
      } else {
        amPM = "PM"
      }
    } else if hourInt > 12 {
      let difference = hourInt - 12
      hour = concatenate(difference < 10 ? "0": "", difference)
      amPM = "PM"
    } else if hourInt == 0 && minutesInt == 0 {
      hour = time.first ?? "00"
      amPM = "MN"
    } else  {
      hour = time.first ?? "00"
      amPM = "AM"
    }
    minutes = time.last ?? "00"
  }
  
  init(rawTime: String) {
    self.rawTime = rawTime
    let time = rawTime.components(separatedBy: ":")
    let hourInt = time.first?.toNumber().intValue ?? 0
    let minutesInt = time.last?.toNumber().intValue ?? 0
    if hourInt == 12 {
      hour = time.first ?? "00"
      if minutesInt == 0 {
        amPM = "NN"
      } else {
        amPM = "PM"
      }
    } else if hourInt > 12 {
      let difference = hourInt - 12
      hour = concatenate(difference < 10 ? "0": "", difference)
      amPM = "PM"
    } else if hourInt == 0 && minutesInt == 0 {
      hour = time.first ?? "00"
      amPM = "MN"
    } else  {
      hour = time.first ?? "00"
      amPM = "AM"
    }
    minutes = time.last ?? "00"
  }
  
  var rawTime: String
  var amPM: String
  var hour: String
  var minutes: String
  
  public static func == (lhs: BAScheduleTime, rhs: BAScheduleTime) -> Bool {
    return lhs.rawTime == rhs.rawTime
  }
}
