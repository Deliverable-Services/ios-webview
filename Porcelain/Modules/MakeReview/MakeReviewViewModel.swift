//
//  ReviewViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 13/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit

public enum MakeReviewType {
  case productReview(product: Product)
  case customerProductReview(product: CustomerProduct)
}

public protocol MakeReviewView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func updateSubmit(enabled: Bool)
  func showError(message: String?)
  func showSuccess(message: String?)
}

public protocol MakeReviewViewModelProtocol {
  var type: MakeReviewType { get }
  var rating: Double? { get set }
  var name: String? { get set }
  var email: String? { get set }
  var review: String? { get set }
  
  func initialize()
  func attachView(_ view: MakeReviewView)
  func submit()
}

public final class MakeReviewViewModel: MakeReviewViewModelProtocol {
  private weak var view: MakeReviewView?
  
  public init(type: MakeReviewType) {
    self.type = type
  }
  
  public var type: MakeReviewType
  
  public var rating: Double? {
    didSet {
      guard oldValue != rating else { return }
      validate()
    }
  }
  public var name: String? {
    didSet {
      guard oldValue != name else { return }
      validate()
    }
  }
  public var email: String? {
    didSet {
      guard oldValue != email else { return }
      validate()
    }
  }
  public var review: String? {
    didSet {
      guard oldValue != review else { return }
      validate()
    }
  }
}

extension MakeReviewViewModel {
  public func attachView(_ view: MakeReviewView) {
    self.view = view
  }
  
  public func initialize() {
    let customer = AppUserDefaults.customer
    name = [customer?.firstName, customer?.lastName].compactMap({ $0 }).joined(separator: " ")
    email = customer?.email
    view?.reload()
    validate()
  }
  
  public func submit() {
    guard let name = name else { return }
    guard let email = email else { return }
    guard let review = review else { return }
    guard let rating = rating else { return }
    switch type {
    case .productReview(let product):
      let productID = product.id!
      var request: [APIServiceConstant.Key: Any] = [:]
      request[.review] = review
      request[.reviewer] = name
      request[.email] = email
      request[.rating] = Int(rating)
      view?.showLoading()
      PPAPIService.Product.createProductReview(productID: productID, request: request).call { (response) in
        switch response {
        case .success(let result):
          CoreDataUtil.performBackgroundTask({ (moc) in
            guard let reviewID = result.data.id.numberString else { return }
            let reviews = Review.getProductReviews(reviewIDs: [reviewID], productID: productID, inMOC: moc)
            Review.parseProductReviewFromData(result.data, reviews: reviews, inMOC: moc)
          }, completion: { (_) in
            self.view?.hideLoading()
            self.view?.showSuccess(message: "Thank you for reviewing")
          })
        case .failure(let error):
          self.view?.hideLoading()
          self.view?.showError(message: error.localizedDescription)
        }
      }
    case .customerProductReview(let product):
      let productID = product.id!
      var request: [APIServiceConstant.Key: Any] = [:]
      request[.review] = review
      request[.reviewer] = name
      request[.email] = email
      request[.rating] = Int(rating)
      view?.showLoading()
      PPAPIService.Product.createProductReview(productID: productID, request: request).call { (response) in
        switch response {
        case .success(let result):
          CoreDataUtil.performBackgroundTask({ (moc) in
            guard let reviewID = result.data.id.numberString else { return }
            let reviews = Review.getProductReviews(reviewIDs: [reviewID], productID: productID, inMOC: moc)
            Review.parseProductReviewFromData(result.data, reviews: reviews, inMOC: moc)
          }, completion: { (_) in
            self.view?.hideLoading()
            self.view?.showSuccess(message: "Thank you for reviewing")
          })
        case .failure(let error):
          self.view?.hideLoading()
          self.view?.showError(message: error.localizedDescription)
        }
      }
    }
  }
}

extension MakeReviewViewModel {
  private func validate() {
    var isSubmitEnabled = true
    if name?.isEmpty ?? true {
      isSubmitEnabled = false
    }
    if email?.isEmpty ?? true {
      isSubmitEnabled = false
    }
    if review?.isEmpty ?? true {
      isSubmitEnabled = false
    }
    if (rating ?? 0.0) == 0 {
      isSubmitEnabled = false
    }
    view?.updateSubmit(enabled: isSubmitEnabled)
  }
}
