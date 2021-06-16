//
//  CalendarEventUtil.swift
//  Porcelain
//
//  Created by Justine Rangel on 17/09/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import EventKit
import EventKitUI
import R4pidKit

public enum CalendarAlarm {
  case onTime
  case oneHourBefore
  case customOffset(seconds: TimeInterval)
  
  public var rawValue: EKAlarm {
    switch self {
    case .onTime:
      return EKAlarm(relativeOffset: 0)
    case .oneHourBefore:
      return EKAlarm(relativeOffset: -3600)
    case .customOffset(let seconds):
      return EKAlarm(relativeOffset: -seconds)
    }
  }
}

public struct SearchEventItem {
  var startDate: Date
  var endDate: Date
}

public struct CalendarEventItem {
  var title: String
  var startDate: Date
  var endDate: Date
  var alarms: [CalendarAlarm]?
  var notes: String?
}

public protocol CalendarEventProtocol {
  static func saveOrUpdateEvent(_ event: EKEvent?, eventModel: CalendarEventItem, completion: ((String?) -> ())?)
  static func deleteEvent(_ eventIdentifier: String, completion: ((Bool) -> ())?)
  static func searchEvent(queries: [String], completion: @escaping (([EKEvent]) -> ()))
}

public final class CalendarEventUtil: CalendarEventProtocol {
  private static let calendarTitle = "Porcelain Reminder"
  private static let eventStore = EKEventStore()
  
  public static func load() {
    updateAuthorizationIfNeeded { (_) in
    }
  }
  
  ///Save/Update an event reminder completion return event identifier if successful
  public static func saveOrUpdateEvent(_ event: EKEvent? = nil, eventModel: CalendarEventItem, completion: ((String?) -> ())? = nil) {
    updateAuthorizationIfNeeded { (success) in
      if success {
        let _event = event ?? EKEvent(eventStore: eventStore)
        _event.title = eventModel.title
        _event.startDate = eventModel.startDate
        _event.endDate = eventModel.endDate
        if let alarms = eventModel.alarms {
          _event.alarms = alarms.map({ $0.rawValue })
        }
        _event.notes = eventModel.notes
        if let calendar = defaultCalendar {
          _event.calendar = calendar
        }
        do {
          try eventStore.save(_event, span: .thisEvent)
          osLogComposeInfo("save event: ", _event.eventIdentifier, " success", log: .default)
          completion?(_event.eventIdentifier)
        } catch {
          osLogComposeError(error.localizedDescription, log: .default)
          completion?(nil)
        }
      } else {
        appDelegate.showAlert(title: "Oops!", message: "Calender access was denied.")
      }
    }
  }
  
  ///Delete an event using event identifier
  public static func deleteEvent(_ eventIdentifier: String, completion: ((Bool) -> ())? = nil) {
    updateAuthorizationIfNeeded { (success) in
      if success {
        if let event = eventStore.event(withIdentifier: eventIdentifier) {
          do {
            try eventStore.remove(event, span: .thisEvent)
            osLogComposeInfo("delete event: ", eventIdentifier, " success", log: .default)
            completion?(true)
          } catch {
            osLogComposeError(error.localizedDescription, log: .default)
            completion?(false)
          }
        } else {
          osLogComposeInfo("event: ", eventIdentifier, " was not found", log: .default)
          completion?(false)
        }
      } else {
        appDelegate.showAlert(title: "Oops!", message: "Calender access was denied.")
      }
    }
  }
  
  ///Search event using query
  public static func searchEvent(queries: [String], completion: @escaping (([EKEvent]) -> ())) {
    updateAuthorizationIfNeeded { (success) in
      if success {
        guard let calendar = defaultCalendar else {
          completion([])
          return
        }
        let startDate = Date()
        let endDate = startDate.dateByAdding(years: 999)
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
        let events = eventStore.events(matching: predicate).filter { (event) -> Bool in
          var validCount = 0
          queries.forEach { (query) in
            if let notes = event.notes, notes.contains(query) {
              validCount += 1
            }
          }
          return queries.count == validCount
        }
        completion(events)
      } else {
        completion([])
      }
    }
  }
  
  private static var defaultCalendar: EKCalendar? {
    let calendars = eventStore.calendars(for: .event).filter({ $0.allowsContentModifications && $0.title == calendarTitle })
    if let calendar = calendars.first {
      return calendar
    } else {
      let calendar = EKCalendar(for: .event, eventStore: eventStore)
      calendar.title = calendarTitle
      calendar.cgColor = UIColor.lightNavy.cgColor
      calendar.source = eventStore.defaultCalendarForNewEvents?.source
      do {
        try eventStore.saveCalendar(calendar, commit: true)
        return calendar
      } catch {
        osLogComposeError("error saving calendar: ", error.localizedDescription, log: .default)
        return nil
      }
    }
  }
  
  //always call this method when performing action save/delete/search
  private static func updateAuthorizationIfNeeded(completion: @escaping BoolCompletion) {
    switch EKEventStore.authorizationStatus(for: .event) {
    case .authorized:
      DispatchQueue.main.async {
        completion(true)
      }
    case .notDetermined:
      eventStore.requestAccess(to: .event) { (flag, error) in
        if flag {
          DispatchQueue.main.async {
            completion(true)
          }
        } else {
          osLogComposeError(error?.localizedDescription ?? "", log: .default)
        }
      }
    case .denied, .restricted:
      DispatchQueue.main.async {
        completion(false)
      }
    }
  }
}
