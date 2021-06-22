//
//  User+CoreDataClass.swift
//  Porcelain
//
//  Created by Justine Rangel on 19/06/2018.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON
import R4pidKit

public typealias Employee = User
public typealias Therapist = User
public typealias Customer = User

public enum UserType: String {
  case employee
  case therapist
  case customer
}

extension JSON {
  public func getUserID(type: UserType? = nil) -> String? {
    guard let type = type else {
      return (zID.string ?? therapistID.string ?? employeeID.string ?? id.number?.stringValue ?? id.string)?.lowercased()
    }
    switch type {
    case .customer:
      return (zID.string ?? id.number?.stringValue ?? id.string)?.lowercased()
    case .therapist:
      return (therapistID.string ?? employeeID.string ?? id.number?.stringValue ?? id.string)?.lowercased()
    case .employee:
      return (employeeID.string ?? id.number?.stringValue ?? id.string)?.lowercased()
    }
  }
}

@objc(User)
public class User: NSManagedObject {
  public static func getUsers(userIDs: [String]? = nil, type: UserType, inMOC: NSManagedObjectContext = .main) -> [User] {
    var predicates: [CoreDataRecipe.Predicate] = [.isEqual(key: "type", value: type.rawValue)]
    if let userIDs  = userIDs, !userIDs.isEmpty {
      if userIDs.count == 1, let userID = userIDs.first {
        predicates.append(.isEqual(key: "id", value: userID))
      } else  {
        predicates.append(.isEqualIn(key: "id", values: userIDs))
      }
    }
    return CoreDataUtil.list(User.self, predicate: .compoundAnd(predicates: predicates), inMOC: inMOC)
  }
  
  public static func getUser(id: String, type: UserType, inMOC: NSManagedObjectContext = .main) -> User? {
    return getUsers(userIDs: [id], type: type, inMOC: inMOC).first
  }
  
  public func updateFromData(_ data: JSON, type: UserType) {
    self.id = data.getUserID(type: type)
    self.zID = data.zID.string
    self.avatar = data.avatar.string ?? self.avatar
    self.employeeID = data.employeeID.string ?? self.employeeID
    self.firstName = data.firstName.string ?? self.firstName
    self.middleName = data.middleName.string ?? self.middleName
    self.lastName = data.lastName.string ?? self.lastName
    self.birthDate = data.birthDate.toDate(format: .ymdDateFormat) ?? self.birthDate
    self.gender = data.gender.number?.stringValue ?? self.gender
    self.identificationNumber = data.identificationNumber.string ?? self.identificationNumber
    self.maritalStatus = data.maritalStatus.string ?? self.maritalStatus
    self.membership = data.membership.string ?? self.membership
    self.country = data.country.string ?? self.country
    self.anniversaryDate = data.anniversaryDate.toDate(format: .ymdDateFormat)
    self.nationality = data.nationality.string ?? self.nationality
    self.email = data.email.string ?? self.email
    self.phoneCode = data.phoneCode.string ?? self.phoneCode
    self.phone = data.phone.string ?? self.phone
    self.homePhone = data.homePhone.string ?? self.homePhone
    self.preferredCenterID = data.preferredCenterID.string ?? self.preferredCenterID
    self.preferredBranch = data.preferredBranch.string ?? self.preferredBranch
    self.preferredTherapistID = data.preferredTherapistID.string ?? self.preferredTherapistID
    self.preferredTherapistName = data.preferredTherapistName.string ?? self.preferredTherapistName
    self.preferredAssistantTherapistID = data.preferredAssistantTherapistID.string ?? self.preferredAssistantTherapistID
    self.preferredAssistantTherapistName = data.preferredAssistantTherapistName.string ?? self.preferredAssistantTherapistName
    self.referralSourceID = data.referralSourceID.string ?? self.referralSourceID
    self.referredGuestID = data.referredGuestID.string ?? self.referredGuestID
    self.optInPhoneCalls = data.optInPhoneCalls.boolValue
    self.optMarketingEmail = data.optMarketingEmail.boolValue
    self.optMarketingSMS = data.optMarketingSMS.boolValue
    self.optEmail = data.optEmail.boolValue
    self.optSMS = data.optSMS.boolValue
    self.optNewsLetter = data.optNewsLetter.boolValue
    self.optPushNotif = data.optPushNotif.boolValue
    self.optTransactionalEmail = data.optTransactionalEmail.boolValue
    self.optTransactionalSMS = data.optTransactionalSMS.boolValue
    self.workPhone = data.workPhone.string ?? self.workPhone
    self.profession = data.profession.string ?? self.profession
    self.company = data.company.string ?? self.company
    self.facebookLinked = data.facebookLinked.bool ?? self.facebookLinked
    self.googleLinked = data.googleLinked.bool ?? self.googleLinked
    self.personalAddressRaw = data.personalAddress.rawString() ?? self.personalAddressRaw
    self.workAddressRaw = data.workAddress.rawString() ?? self.workAddressRaw
    self.hasCredential = data.hasCredential.bool ?? self.hasCredential
    self.hasPhoneVerified = data.hasPhoneVerified.bool ?? self.hasPhoneVerified
    self.centerIDs = data.centerID.string ?? self.centerIDs
    self.shortName = data.shortName.string ?? self.shortName
    self.nickName = data.nickName.string ?? self.nickName
    self.displayName = data.displayName.string ?? self.displayName
    self.jobTitle = data.jobTitle.string ?? self.jobTitle
    self.username = data.username.string ?? self.username
    self.wcDateCreated = data.wcDateCreated.toDate(format: .ymdhmsDateFormat) ?? self.wcDateCreated
    self.zenotiDateCreated = data.zenotiDateCreated.toDate(format: .ymdDateFormat) ?? self.zenotiDateCreated
    self.regComplete = data.regComplete.bool ?? self.regComplete
    self.accessToken = data.accessToken.string ?? self.accessToken
    self.dateUpdated = data.updatedAt.toDate(format: .ymdhmsDateFormat) ?? self.dateUpdated
    self.dateCreated = data.createdAt.toDate(format: .ymdhmsDateFormat) ?? self.dateCreated
  }
}

extension User {
  public static func parseUsersFromData(_ data: JSON, type: UserType, inMOC: NSManagedObjectContext) {
    guard let userArray = data.array else { return }
    let userIDs = userArray.compactMap { (data) -> String? in
      switch type {
      case .customer:
        return data.zID.string ?? data.id.string
      case .therapist:
        return data.therapistID.string ?? data.employeeID.string ?? data.id.string
      case .employee:
        return data.employeeID.string ?? data.id.string
      }
    }
    let users = getUsers(userIDs: userIDs, type: type, inMOC: inMOC)
    userArray.forEach { (data) in
      parseUserFromData(data, users: users, type: type, inMOC: inMOC)
    }
  }
  
  @discardableResult
  public static func  parseUserFromData(_ data: JSON, users: [User], type: UserType, inMOC: NSManagedObjectContext) -> User? {
    guard let userID = data.getUserID(type: type) else { return nil }
    let currentUser = users.first(where: { $0.id == userID })
    let user = CoreDataUtil.createEntity(User.self, fromEntity: currentUser, inMOC: inMOC)
    user.updateFromData(data, type: type)
    user.type = type.rawValue
    return user
  }
}

//Address Type
//0 - personal
//1 - billing
//2 - work
extension Customer {
  public struct Address {
    public var address: String?
    public var country: String?
    public var state: String?
    public var postalCode: String?
    public var type: String?
    public var email: String?
    public var primary: Int
    
    init?(data: JSON) {
      guard data.id.intValue > 0 else { return nil }
      address = data.address.string
      country = data.country.string
      state = data.state.string
      postalCode = data.postalCode.numberString
      type = data.type.string
      email = data.email.string
      primary = data.primary.int ?? 0
    }
  }
  
  public var personalAddress: Address? {
    return Address(data: JSON(parseJSON: personalAddressRaw ?? ""))
  }
  
  public var workAddress: Address? {
    return Address(data: JSON(parseJSON: workAddressRaw ?? ""))
  }
}

extension Customer {
  public var genderType: GenderType? {
    return GenderType(rawValue: gender?.toNumber().intValue ?? -1)
  }
  
  public var fullName: String {
    var names: [String] = []
    if let firstName = firstName {
      names.append(firstName)
    }
    if let lastName = lastName {
      names.append(lastName)
    }
    return names.joined(separator: " ")
  }
  
  public var preferredCenter: Center? {
    guard let preferredCenterID = preferredCenterID else { return nil }
    return Center.getCenter(id: preferredCenterID)
  }
}
