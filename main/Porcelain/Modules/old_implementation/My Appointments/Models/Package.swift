//
//  Package.swift
//  Porcelain
//
//  Created by Jean on 6/30/18.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation

struct CodableTreatment: Codable {
  var id: String
  var name: String
  var sessionsLeft: Int
  
  enum CodingKeys: String, CodingKey {
    case id, name
    case sessionsLeft = "sessionLeft"
  }
}

struct Package: Codable {
  var id: String
  var group: String?
  var treatments: [CodableTreatment]
  var expiryDate: String?
  
  var opened: Bool = false
  
  enum CodingKeys: String, CodingKey {
    case id, group, treatments, expiryDate
  }
}
