//
//  Review+CoreDataClass.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 11/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON
import R4pidKit

@objc(Review)
public class Review: NSManagedObject {
  public static func getProductReviews(reviewIDs: [String]? = nil, productID: String, inMOC: NSManagedObjectContext = .main) -> [Review] {
    var predicates: [CoreDataRecipe.Predicate] = [.isEqual(key: "productID", value: productID)]
    if let reviewIDs = reviewIDs, !reviewIDs.isEmpty {
      if reviewIDs.count == 1, let reviewID = reviewIDs.first {
        predicates.append(.isEqual(key: "id", value: reviewID))
      } else  {
        predicates.append(.isEqualIn(key: "id", values: reviewIDs))
      }
    }
    return CoreDataUtil.list(Review.self, predicate: .compoundAnd(predicates: predicates), inMOC: inMOC)
  }
  
  public static func getProductReview(id: String, productID: String, inMOC: NSManagedObjectContext = .main) -> Review? {
    return getProductReviews(reviewIDs: [id], productID: productID, inMOC: inMOC).first
  }
  
  public func updateDataFrom(_ data: JSON) {
    id = data.id.numberString
    wcID = data.wcID.numberString
    status = data.status.string
    reviewer = data.reviewer.string
    review = data.review.string
    rate = data.rate.int32Value
    verified = data.verified.boolValue
    productID = data.productID.numberString
    dateCreated = data.createdAt.toDate(format: .ymdhmsDateFormat)
  }
}

extension Review {
  public static func parseProductReviewsFromData(_ data: JSON, productID: String, inMOC: NSManagedObjectContext) {
    let reviewArray = data.array ?? []
    let reviewIDs = reviewArray.compactMap({ $0.id.numberString })
    
    let deprecatedReviews = CoreDataUtil.list(
      Review.self,
      predicate: .compoundAnd(predicates: [
        .isEqual(key: "isActive", value: true),
        .isEqual(key: "productID", value: productID),
        .notEqualIn(key: "id", values: reviewIDs)]),
      inMOC: inMOC)
    deprecatedReviews.forEach { (review) in
      review.isActive = false
    }
    
    let reviews = getProductReviews(reviewIDs: reviewIDs, productID: productID, inMOC: inMOC)
    reviewArray.forEach { (data) in
      guard let review = parseProductReviewFromData(data, reviews: reviews, inMOC: inMOC) else { return }
      review.isActive = true
    }
  }
  
  @discardableResult
  public static func parseProductReviewFromData(_ data: JSON, reviews: [Review], inMOC: NSManagedObjectContext) -> Review? {
    guard let reviewID = data.id.numberString else { return nil }
    let currentReview = reviews.first(where: { $0.id == reviewID })
    let review = CoreDataUtil.createEntity(Review.self, fromEntity: currentReview, inMOC: inMOC)
    review.updateDataFrom(data)
    return review
  }
}

extension Review {
  public var product: Product? {
    guard let productID = productID else { return nil }
    return Product.getProduct(id: productID)
  }
}
