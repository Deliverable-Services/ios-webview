//
//  Protocols+Entities.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 21/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit

public protocol UserProtocol {
  var user: User? { get }
}

extension UserProtocol {
  public var avatar: String? {
    return user?.avatar
  }
  
  public var fullname: String? {
    return user?.fullName.emptyToNil
  }
  
  public var email: String? {
    return user?.email
  }
  
  public var isFacebookLinked: Bool {
    return user?.facebookLinked ?? false
  }
  
  public var isGoogleLinked: Bool {
    return user?.googleLinked ?? false
  }
  
  public var phoneCode: String? {
    return user?.phoneCode
  }
  
  public var phone: String? {
    return user?.phone
  }
  
  public var preferredCenter: Center? {
    return user?.preferredCenter
  }
  
  public var personalAddress: Customer.Address? {
    return user?.personalAddress
  }
  
  public var workAddress: Customer.Address? {
    return user?.workAddress
  }
  
  public var customerID: String? {
    return user?.zID ?? user?.id
  }
  
  public var identificationNumber: String? {
    return user?.identificationNumber
  }
  
  public var accountBalance: Double {
    return 0.0
  }
  
  public var outstandingBalance: Double? {
    return nil
  }
  
  public var creditCards: [Card]? {
    return user?.cards?.allObjects as? [Card]
  }
  
  public var shippingAddresses: [ShippingAddress]? {
    return CoreDataUtil.list(
      ShippingAddress.self,
      predicate: .compoundAnd(predicates: [
        .isEqual(key: "isActive", value: true),
        .isEqual(key: "customer.id", value: user?.id)]),
      sorts: [.id(isAscending: false)])
  }
}

public protocol ProductProtocol {
  var product: Product? { get }
}

extension ProductProtocol {
  public var productName: String? {
    return product?.name
  }
  
  public var description: String? {
    return product?.desc
  }
  
  public var application: String? {
    return product?.application
  }
  
  public var sku: String? {
    return product?.sku
  }
  
  public var price: Double {
    return product?.price ?? 0.0
  }
  
  public var shortHeader: String? {
    return product?.shortHeader
  }
  
  public var shortDescription: String? {
    return product?.shortDesc
  }
  
  public var shortContent: String? {
    return product?.shortContent
  }
  
  public var quote: String? {
    return product?.quote
  }
  
  public var size: String? {
    return product?.size
  }
  
  public var averageRating: Double {
    return product?.averageRating ?? 0.0
  }
  
  public var totalReviews: Int {
    return Int(product?.totalReviews ?? 0)
  }
  
  public var review: String? {
    return product?.review
  }
  
  public var image: Product.Image? {
    return images?.first
  }
  
  public var images: [Product.Image]? {
    return product?.images
  }
  
  public var attributes: [ProductVariationAttribute]? {
    return product?.attributes
  }
  
  public var regularPrice: Double {
    return product?.regularPrice ?? 0.0
  }
  
  public var salePrice: Double {
    return product?.salePrice ?? 0.0
  }
  
  public var purchasable: Bool {
    return product?.purchasable ?? false
  }
  
  public var onSale: Bool {
    return product?.onSale ?? false
  }
  
  public var inStock: Bool {
    return product?.inStock ?? false
  }
}

public protocol TreatmentProtocol {
  var treatment: Treatment? { get }
}

extension TreatmentProtocol {
  public var treatmentName: String? {
    return treatment?.name
  }
  public var desc: String? {
    return treatment?.desc
  }
  public var benefits: [String]? {
    return treatment?.benefits
  }
  public var duration: String? {
    return treatment?.duration?.appending(" minutes")
  }
  public var centerIDs: [String]? {
    return treatment?.centerIDs
  }
}

public protocol AppointmentProtocol {
  var appointment: Appointment? { get }
}

extension AppointmentProtocol {
  public var startDate: Date? {
    return appointment?.dateStart
  }
  
  public var endDate: Date? {
    return appointment?.dateEnd
  }
  
  public var services: [Service]? {
    return appointment?.services
  }
  
  public var treatment: Service? {
    return appointment?.treatment
  }
  
  public var addons: [Service]? {
    return appointment?.addons
  }
  
  public var therapist: Therapist? {
    return appointment?.therapist
  }
  
  public var center: Center? {
    guard let centerID = appointment?.centerID else { return nil }
    return Center.getCenter(id: centerID)
  }
  
  public var appointmentState: AppointmentState {
    return appointment?.appointmentState ?? .confirmed
  }
  
  public var sessionsLeft: Int {
    return Int(appointment?.sessionsLeft ?? 0)
  }
  
  public var isCancellable: Bool {
    return startDate?.isGreaterThan(Date().dateByAdding(hours: AppConfiguration.appointmentMinCancelHours)) ?? false
  }
  
  public var isConfirmable: Bool {
    guard appointmentState == .reserved else { return false }
    guard let startDate = startDate else { return false }
    return startDate.isGreaterThan(Date().dateByAdding(hours: 24)) && startDate.isLessThan(Date().dateByAdding(hours: 72))
  }
  
  public var appointmentNote: Note? {
    return appointment?.note
  }
}

public protocol PurchaseProtocol {
  var purchase: Purchase? { get }
}

extension PurchaseProtocol {
  public var purchasedItems: [Purchase.Item]? {
    return purchase?.purchasedItems
  }
  
  public var subtotal: Double {
    return purchase?.total ?? 0.0
  }
  
  public var shipping: Double {
    return purchase?.shipping ?? 0.0
  }
  
  public var totalDiscount: Double {
    return purchase?.discount ?? 0.0
  }
  
  public var totalAmount: Double {
    return purchase?.totalAmount ?? 0.0
  }
}

public protocol CardProtocol {
  var card: Card? { get }
}

extension CardProtocol {
  public var brand: Card.Brand {
    return card?.brand ?? .unknown
  }
  
  public var isDefault: Bool {
    return card?.isDefault ?? false
  }
  
  public var last4: String? {
    return card?.last4 ?? ""
  }
  
  public var expMonth: String {
    return NSNumber(value: card?.expMonth ?? 0).stringValue
  }
  
  public var expYear: String {
    return NSNumber(value: card?.expYear ?? 0).stringValue
  }
  
  public var brandImage: UIImage? {
    return card?.brandImage
  }
}

public protocol AppNotificationProtocol {
  var notification: AppNotification? { get }
}

extension AppNotificationProtocol {
  public var notificationTitle: String? {
    return notification?.title
  }
  
  public var notificationMessage: String? {
    return notification?.message
  }
  
  public var isRead: Bool {
    return notification?.isRead ?? false
  }
  
  public var dateSent: Date? {
    return notification?.dateSent
  }
  
  public var dateCreated: Date? {
    return notification?.dateCreated
  }
}

public protocol ShippingAddressProtocol {
  var shippingAddress: ShippingAddress? { get }
}

extension ShippingAddressProtocol {
  public var isDefault: Bool {
    return shippingAddress?.primary ?? false
  }
  
  public var name: String? {
    return shippingAddress?.name
  }
  
  public var phone: String? {
    return shippingAddress?.phone
  }
  
  public var email: String? {
    return shippingAddress?.email
  }
  
  public var fullAddress: String? {
    return [
      shippingAddress?.address,
      shippingAddress?.state,
      shippingAddress?.postalCode,
      shippingAddress?.country].compactMap({ $0 }).joined(separator: ", ").emptyToNil
  }
}
