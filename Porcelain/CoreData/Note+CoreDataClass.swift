//
//  Note+CoreDataClass.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 09/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON
import R4pidKit

@objc(Note)
public class Note: NSManagedObject {
  public static func getNotes(noteIDs: [String]? = nil, appointmentID: String, inMOC: NSManagedObjectContext = .main) -> [Note] {
    var predicates: [CoreDataRecipe.Predicate] = [.isEqual(key: "appointment.id", value: appointmentID)]
    if let noteIDs = noteIDs, !noteIDs.isEmpty {
      if noteIDs.count == 1, let noteID = noteIDs.first {
        predicates.append(.isEqual(key: "id", value: noteID))
      } else  {
        predicates.append(.isEqualIn(key: "id", values: noteIDs))
      }
    }
    return CoreDataUtil.list(Note.self, predicate: .compoundAnd(predicates: predicates), inMOC: inMOC)
  }
  
  public static func getNote(id: String, appointmentID: String, inMOC: NSManagedObjectContext = .main) -> Note? {
    return getNotes(noteIDs: [id], appointmentID: appointmentID, inMOC: inMOC).first
  }
  
  public func updateFromData(_ data: JSON) {
    self.id = data.noteID.string ?? data.id.number?.stringValue
    self.userID = data.userID.string ?? self.userID
    self.note = data.note.string ?? self.note
    self.isPrivate = data.isPrivate.bool ?? self.isPrivate
  }
}

// MARK: - Appointment notes
extension Note {
  @discardableResult
  public static func parseNoteFromData(_ data: JSON, appointment: Appointment, inMOC: NSManagedObjectContext = .main) -> Note? {
    let note = CoreDataUtil.createEntity(Note.self, fromEntity: appointment.note, inMOC: inMOC)
    note.updateFromData(data)
    note.appointment = appointment
    return note
  }
}
