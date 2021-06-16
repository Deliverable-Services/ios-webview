//
//  Appointment+CoreDataClass.swift
//  Porcelain
//
//  Created by Jean on 7/4/18.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON
import R4pidKit

public enum AppointmentStatus: Int32 {
  case noShow = -2
  case cancelled = -1
  case current = 0
  case closed
  case checkin
  case confirm = 4
  case `break` = 10
  case notSpecified = 11
  case available = 20
}

public enum AppointmentState: String {
  case requested // requested by user, displayed at pending appointments
  case reserved  // approved by porcelain, displayed at upcoming appointments
  case confirmed // approved by user and porcelain, displayed at upcoming appointments
  case cancelled // cancelled
  case rejected  // rejected
  case done
}

public enum AppointmentType: String {
  case upcoming
  case pending
  case past
}

@objc(Appointment)
public class Appointment: NSManagedObject {
  public static func getAppointments(appointmentIDs: [String]? = nil, customerID: String, inMOC: NSManagedObjectContext = .main) -> [Appointment] {
    var predicates: [CoreDataRecipe.Predicate] = [.isEqual(key: "customer.id", value: customerID)]
    if let appointmentIDs = appointmentIDs, !appointmentIDs.isEmpty {
      if appointmentIDs.count == 1, let appointmentID = appointmentIDs.first {
        predicates.append(.isEqual(key: "id", value: appointmentID))
      } else  {
        predicates.append(.isEqualIn(key: "id", values: appointmentIDs))
      }
    }
    return CoreDataUtil.list(Appointment.self, predicate: .compoundAnd(predicates: predicates), inMOC: inMOC)
  }
  
  public static func getAppointment(id: String, customerID: String, inMOC: NSManagedObjectContext = .main) -> Appointment? {
    return getAppointments(appointmentIDs: [id], customerID: customerID, inMOC: inMOC).first
  }
  
  public func updateFromData(_ data: JSON) {
    self.id = data.appointmentID.string ?? data.id.number?.stringValue
    self.userID = data.userID.string ?? self.userID
    self.reservationID = data.reservationID.string ?? self.reservationID
    self.centerID = data.centerID.string ?? self.centerID
    self.therapistID = data.therapistID.string ?? self.therapistID
    self.invoiceID = data.invoiceID.string ?? self.invoiceID
    self.dateStart = data.startDate.toDate(format: .ymdhmsDateFormat) ?? self.dateStart
    self.dateEnd = data.endDate.toDate(format: .ymdhmsDateFormat) ?? self.dateEnd
    self.monthYear = data.startDate.toDate(format: .ymdhmsDateFormat)?.startOfMonth() ?? self.monthYear
    self.status = data.status.int32 ?? self.status
    self.state = data.state.string ?? self.state
    self.source = data.source.string ?? self.source
    self.dateBooked = data.bookedAt.toDate(format: .ymdhmsDateFormat) ?? self.dateBooked
    self.dateApproved = data.approvedAt.toDate(format: .ymdhmsDateFormat) ?? self.dateApproved
    self.sessionsLeft = data.sessionLeft.int32 ?? self.sessionsLeft
  }
}

extension Appointment {
  public static func parseAppointmentsFromData(_ data: JSON, customer: Customer, type: AppointmentType, inMOC: NSManagedObjectContext = .main) {
    let appointmentArray = data.array ?? []
    let appointmentIDs = appointmentArray.compactMap({ $0.appointmentID.string })
    let therapistIDs = appointmentArray.compactMap({ $0.therapist.employeeID.string })
    
    let therapists = User.getUsers(userIDs: therapistIDs, type: .therapist, inMOC: inMOC)
    
    let deprecatedAppointments = CoreDataUtil.list(
      Appointment.self,
      predicate: .compoundAnd(predicates: [
        .isEqual(key: "type", value: type.rawValue),
        .isEqual(key: "customer.id", value: customer.id!),
        .notEqualIn(key: "id", values: appointmentIDs)]),
      inMOC: inMOC)
    CoreDataUtil.deleteEntities(deprecatedAppointments, inMOC: inMOC)
    
    let appointments = getAppointments(appointmentIDs: appointmentIDs, customerID: customer.id!, inMOC: inMOC)
    appointmentArray.forEach { (data) in
      guard let appointment = parseAppointmentFromData(data, customer: customer, appointments: appointments, inMOC: inMOC) else { return }
      appointment.type = type.rawValue
      if let therapist = User.parseUserFromData(data.therapist, users: therapists, type: .therapist, inMOC: inMOC) {
        appointment.therapist = therapist
      }
      if let centerID = data.center.centerID.string {
        let centers = Center.getCenters(centerIDs: [centerID], inMOC: inMOC)
        Center.parseCenterFromData(data.center, centers: centers, inMOC: inMOC)
      }
      if let centerID = data.centerID.string {
        var storedServiceIDs: [String] = []
        if let serviceID = data.service.serviceID.string {//treatment
          let services = Service.getServices(serviceIDs: [serviceID], type: .treatment, centerID: centerID, inMOC: inMOC)
          Service.parseServiceFromData(data.service, type: .treatment, services: services, inMOC: inMOC)
          storedServiceIDs.append(serviceID)
        }
        if let addons = data.addons.array?.map({ $0.service }), !addons.isEmpty {
          let serviceIDs = addons.compactMap({ $0.serviceID.string })
          let services = Service.getServices(serviceIDs: serviceIDs, type: .addon, centerID: centerID, inMOC: inMOC)
          addons.forEach { (data) in
            Service.parseServiceFromData(data, type: .addon, services: services, inMOC: inMOC)
          }
          storedServiceIDs.append(contentsOf: serviceIDs)
        }
        appointment.serviceIDs = storedServiceIDs
      }
      if !data.note.isEmpty {//note
        Note.parseNoteFromData(data.note, appointment: appointment, inMOC: inMOC)
      }
    }
  }
  
  @discardableResult
  public static func parseAppointmentFromData(_ data: JSON, customer: Customer, appointments: [Appointment], inMOC: NSManagedObjectContext = .main) -> Appointment? {
    guard let appointmentID = data.appointmentID.string else { return nil }
    let currentAppointment = appointments.first(where: { $0.id == appointmentID })
    let appointment = CoreDataUtil.createEntity(Appointment.self, fromEntity: currentAppointment, inMOC: inMOC)
    appointment.updateFromData(data)
    appointment.customer = customer
    return appointment
  }
}

extension Appointment {
  public var appointmentStatus: AppointmentStatus? {
    return AppointmentStatus(rawValue: status)
  }
  
  public var appointmentState: AppointmentState? {
    return AppointmentState(rawValue: state ?? "")
  }
  
  public var services: [Service]? {
    guard let serviceIDs = serviceIDs, let centerID = centerID, !serviceIDs.isEmpty else { return nil }
    return Service.getServices(serviceIDs: serviceIDs, type: nil, centerID: centerID)
  }
  
  public var treatment: Service? {
    return services?.first(where: { $0.type == ServiceType.treatment.rawValue })
  }
  
  public var addons: [Service]? {
    return services?.filter({ $0.type == ServiceType.addon.rawValue })
  }
}
