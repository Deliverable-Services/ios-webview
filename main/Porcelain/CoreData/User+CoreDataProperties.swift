//
//  User+CoreDataProperties.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 3/16/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var accessToken: String?
    @NSManaged public var accountBalance: Double
    @NSManaged public var anniversaryDate: Date?
    @NSManaged public var avatar: String?
    @NSManaged public var birthDate: Date?
    @NSManaged public var centerIDs: String?
    @NSManaged public var company: String?
    @NSManaged public var country: String?
    @NSManaged public var dateCreated: Date?
    @NSManaged public var dateUpdated: Date?
    @NSManaged public var displayName: String?
    @NSManaged public var email: String?
    @NSManaged public var employeeID: String?
    @NSManaged public var facebookLinked: Bool
    @NSManaged public var firstName: String?
    @NSManaged public var gender: String?
    @NSManaged public var googleLinked: Bool
    @NSManaged public var hasCredential: Bool
    @NSManaged public var hasPhoneVerified: Bool
    @NSManaged public var homePhone: String?
    @NSManaged public var id: String?
    @NSManaged public var identificationNumber: String?
    @NSManaged public var isSynced: Bool
    @NSManaged public var jobTitle: String?
    @NSManaged public var lastName: String?
    @NSManaged public var maritalStatus: String?
    @NSManaged public var membership: String?
    @NSManaged public var middleName: String?
    @NSManaged public var nationality: String?
    @NSManaged public var nickName: String?
    @NSManaged public var optEmail: Bool
    @NSManaged public var optInPhoneCalls: Bool
    @NSManaged public var optMarketingEmail: Bool
    @NSManaged public var optMarketingSMS: Bool
    @NSManaged public var optNewsLetter: Bool
    @NSManaged public var optPushNotif: Bool
    @NSManaged public var optSMS: Bool
    @NSManaged public var optTransactionalEmail: Bool
    @NSManaged public var optTransactionalSMS: Bool
    @NSManaged public var personalAddressRaw: String?
    @NSManaged public var phone: String?
    @NSManaged public var phoneCode: String?
    @NSManaged public var postalCode: String?
    @NSManaged public var preferredAssistantTherapistID: String?
    @NSManaged public var preferredAssistantTherapistName: String?
    @NSManaged public var preferredBranch: String?
    @NSManaged public var preferredCenterID: String?
    @NSManaged public var preferredOutlet: String?
    @NSManaged public var preferredTherapistID: String?
    @NSManaged public var preferredTherapistName: String?
    @NSManaged public var profession: String?
    @NSManaged public var referralSourceID: String?
    @NSManaged public var referredGuestID: String?
    @NSManaged public var regComplete: Bool
    @NSManaged public var shortName: String?
    @NSManaged public var skinAnalysisRaw: String?
    @NSManaged public var skinAnalysisStatsRaw: String?
    @NSManaged public var skinQuizAnswerRaw: String?
    @NSManaged public var skinQuizRaw: String?
    @NSManaged public var skinQuizResultURL: String?
    @NSManaged public var skinTypeRaw: String?
    @NSManaged public var stripeCustomerID: String?
    @NSManaged public var type: String?
    @NSManaged public var unpaidClasses: Int32
    @NSManaged public var username: String?
    @NSManaged public var wcDateCreated: Date?
    @NSManaged public var workAddressRaw: String?
    @NSManaged public var workPhone: String?
    @NSManaged public var zenotiDateCreated: Date?
    @NSManaged public var zID: String?
    @NSManaged public var cards: NSSet?
    @NSManaged public var customerAppointments: NSSet?
    @NSManaged public var notifications: NSSet?
    @NSManaged public var prescriptions: NSSet?
    @NSManaged public var shippingAddresses: NSSet?
    @NSManaged public var therapistAppointments: NSSet?
    @NSManaged public var treatmentPlan: TreatmentPlan?

}

// MARK: Generated accessors for cards
extension User {

    @objc(addCardsObject:)
    @NSManaged public func addToCards(_ value: Card)

    @objc(removeCardsObject:)
    @NSManaged public func removeFromCards(_ value: Card)

    @objc(addCards:)
    @NSManaged public func addToCards(_ values: NSSet)

    @objc(removeCards:)
    @NSManaged public func removeFromCards(_ values: NSSet)

}

// MARK: Generated accessors for customerAppointments
extension User {

    @objc(addCustomerAppointmentsObject:)
    @NSManaged public func addToCustomerAppointments(_ value: Appointment)

    @objc(removeCustomerAppointmentsObject:)
    @NSManaged public func removeFromCustomerAppointments(_ value: Appointment)

    @objc(addCustomerAppointments:)
    @NSManaged public func addToCustomerAppointments(_ values: NSSet)

    @objc(removeCustomerAppointments:)
    @NSManaged public func removeFromCustomerAppointments(_ values: NSSet)

}

// MARK: Generated accessors for notifications
extension User {

    @objc(addNotificationsObject:)
    @NSManaged public func addToNotifications(_ value: AppNotification)

    @objc(removeNotificationsObject:)
    @NSManaged public func removeFromNotifications(_ value: AppNotification)

    @objc(addNotifications:)
    @NSManaged public func addToNotifications(_ values: NSSet)

    @objc(removeNotifications:)
    @NSManaged public func removeFromNotifications(_ values: NSSet)

}

// MARK: Generated accessors for prescriptions
extension User {

    @objc(addPrescriptionsObject:)
    @NSManaged public func addToPrescriptions(_ value: Prescription)

    @objc(removePrescriptionsObject:)
    @NSManaged public func removeFromPrescriptions(_ value: Prescription)

    @objc(addPrescriptions:)
    @NSManaged public func addToPrescriptions(_ values: NSSet)

    @objc(removePrescriptions:)
    @NSManaged public func removeFromPrescriptions(_ values: NSSet)

}

// MARK: Generated accessors for shippingAddresses
extension User {

    @objc(addShippingAddressesObject:)
    @NSManaged public func addToShippingAddresses(_ value: ShippingAddress)

    @objc(removeShippingAddressesObject:)
    @NSManaged public func removeFromShippingAddresses(_ value: ShippingAddress)

    @objc(addShippingAddresses:)
    @NSManaged public func addToShippingAddresses(_ values: NSSet)

    @objc(removeShippingAddresses:)
    @NSManaged public func removeFromShippingAddresses(_ values: NSSet)

}

// MARK: Generated accessors for therapistAppointments
extension User {

    @objc(addTherapistAppointmentsObject:)
    @NSManaged public func addToTherapistAppointments(_ value: Appointment)

    @objc(removeTherapistAppointmentsObject:)
    @NSManaged public func removeFromTherapistAppointments(_ value: Appointment)

    @objc(addTherapistAppointments:)
    @NSManaged public func addToTherapistAppointments(_ values: NSSet)

    @objc(removeTherapistAppointments:)
    @NSManaged public func removeFromTherapistAppointments(_ values: NSSet)

}
