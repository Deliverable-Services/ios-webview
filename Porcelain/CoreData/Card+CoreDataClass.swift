//
//  Card+CoreDataClass.swift
//  Porcelain
//
//  Created by Jean on 14/11/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON
import R4pidKit
import Stripe

@objc(Card)
public class Card: NSManagedObject {
  private static var seconds = 0
  public static func getCards(cardIDs: [String]? = nil, customerID: String, inMOC: NSManagedObjectContext = .main) -> [Card] {
    var predicates: [CoreDataRecipe.Predicate] = [.isEqual(key: "customer.id", value: customerID)]
    if let cardIDs = cardIDs, !cardIDs.isEmpty {
      if cardIDs.count == 1, let cardID = cardIDs.first {
        predicates.append(.isEqual(key: "id", value: cardID))
      } else  {
        predicates.append(.isEqualIn(key: "id", values: cardIDs))
      }
    }
    return CoreDataUtil.list(Card.self, predicate: .compoundAnd(predicates: predicates), inMOC: inMOC)
  }
  
  public static func getCard(id: String, customerID: String, inMOC: NSManagedObjectContext = .main) -> Card? {
    return getCards(cardIDs: [id], customerID: customerID, inMOC: inMOC).first
  }
  
  public func updateFromData(_ data: JSON) {
    id = data.id.numberString
    expMonth = data.expMonth.int32 ?? expMonth
    expYear = data.expYear.int32 ?? expYear
    last4 = data.last4.string ?? last4
    brandRaw = data.brand.string ?? brandRaw
    funding = data.funding.string ?? funding
    country = data.country.string ?? country
    cvcCheck = data.cvcCheck.string ?? cvcCheck
    name = data.name.string ?? name
    isDefault = data.isDefault.bool ?? isDefault
    if dateCreated == nil {
      dateCreated = Date().dateByAdding(seconds: Card.seconds)
      Card.seconds += 1
    }
  }
}

extension Card {
  public static func parseCardsFromData(_ data: JSON, customer: Customer, inMOC: NSManagedObjectContext) {
    let cardArray = data.array ?? []
    let cardIDs = cardArray.compactMap({ $0.id.numberString })
    
    let deprecatedCards = CoreDataUtil.list(
      Card.self,
      predicate: .compoundAnd(predicates: [
        .isEqual(key: "customer.id", value: customer.id!),
        .notEqualIn(key: "id", values: cardIDs)]),
      inMOC: inMOC)
    CoreDataUtil.deleteEntities(deprecatedCards, inMOC: inMOC)
    
    let cards = getCards(cardIDs: cardIDs, customerID: customer.id!, inMOC: inMOC)
    cardArray.enumerated().forEach { (indx, data) in
      parseCardFromData(data, customer: customer, cards: cards, inMOC: inMOC)
    }
    Card.seconds = 0//reset
  }
  
  @discardableResult
  public static func parseCardFromData(_ data: JSON, customer: Customer, cards: [Card], inMOC: NSManagedObjectContext) -> Card? {
    guard let cardID = data.id.numberString else { return nil }
    let currentCard = cards.first(where: { $0.id == cardID })
    let card = CoreDataUtil.createEntity(Card.self, fromEntity: currentCard, inMOC: inMOC)
    card.updateFromData(data)
    card.customer = customer
    return card
  }
}

extension Card {
  public enum Brand: String {
    case visa = "Visa"
    case amex = "American Express"
    case masterCard = "MasterCard"
    case discover = "Discover"
    case jcb = "JCB"
    case dinersClub = "Diners Club"
    case unionPay = "UnionPay"
    case unknown = "Unknown"
  }
  
  public var brand: Brand {
    return Brand(rawValue: brandRaw ?? "") ?? .unknown
  }
  
  public var brandImage: UIImage {
    switch brand {
    case .visa:
      return STPImageLibrary.visaCardImage()
    case .amex:
      return STPImageLibrary.amexCardImage()
    case .masterCard:
      return STPImageLibrary.masterCardCardImage()
    case .discover:
      return STPImageLibrary.discoverCardImage()
    case .jcb:
      return STPImageLibrary.jcbCardImage()
    case .dinersClub:
      return STPImageLibrary.dinersClubCardImage()
    case .unionPay:
      return STPImageLibrary.unionPayCardImage()
    case .unknown:
      return STPImageLibrary.unknownCardCardImage()
    }
  }
  
  public static var selectedCard: Card? {
    guard let customerID = AppUserDefaults.customerID else { return nil }
    return CoreDataUtil.get(
      Card.self,
      predicate: .compoundAnd(predicates: [
        .isEqual(key: "customer.id", value: customerID),
        .isEqual(key: "isDefault", value: true)]))
  }
}
