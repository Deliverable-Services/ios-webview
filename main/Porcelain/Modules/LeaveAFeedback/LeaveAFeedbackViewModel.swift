//
//  LeaveAFeedbackViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 31/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit
import SwiftyJSON

public struct FeedbackData {
  public var id: String?
  public var rating: Double?
  public var feedback: String?
  public var feedbackDetails: String?
  public var images: [String]?
  
  public init() {
    id = "default"
  }
  
  public init?(data: JSON) {
    guard let id = data.id.numberString else { return nil }
    self.id = id
    rating = data.rate.number?.doubleValue
    feedback = data.feedbackType.string
    feedbackDetails = data.details.string
    images = data.images.array?.compactMap({ $0.string })
  }
}

public enum FeedbackDataType {
  case appointment(_ value: Appointment)
  case purchase(_ value: Purchase)
  
  public var url: String? {
    switch self {
    case .appointment(let appointment):
      r4pidLog(appointment)
      return nil
    case .purchase(let purchase):
      return purchase.purchasedItems?.first?.product?.url
    }
  }
  
  public var title: String {
    switch self {
    case .appointment:
      return "RATE SESSION"
    case .purchase:
      return "LEAVE A FEEDBACK"
    }
  }
}

public protocol LeaveAFeedbackView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func showError(message: String?)
}

public protocol LeaveAFeedbackViewModelProtocol: class {
  var type: FeedbackDataType { get }
  var feedback: FeedbackData { get set }
  
  func attachView(_ view: LeaveAFeedbackView)
  func initialize()
}

public final class LeaveAFeedbackViewModel: LeaveAFeedbackViewModelProtocol {
  private weak var view: LeaveAFeedbackView?
  
  public var type: FeedbackDataType
  
  init(type: FeedbackDataType) {
    self.type = type
  }
  
  public var feedback: FeedbackData = .init()
}

extension LeaveAFeedbackViewModel {
  public func attachView(_ view: LeaveAFeedbackView) {
    self.view = view
  }
  
  public func initialize() {
    view?.reload()
    switch type {
    case .appointment(let appointment):
      guard let appointmentID = appointment.id else {
        view?.showError(message: "Appointment id does not exists.")
        return
      }
      view?.showLoading()
      PPAPIService.User.getMyAppointmentFeedback(appointmentID: appointmentID).call { (response) in
        switch response {
        case .success(let result):
          self.view?.hideLoading()
          if let feedback = FeedbackData(data: result.data) {
            self.feedback = feedback
          } else {
            self.feedback.id = nil
          }
          self.view?.reload()
        case .failure(let error):
          self.view?.hideLoading()
          self.view?.showError(message: error.localizedDescription)
        }
      }
    case .purchase(let purchase):
      guard let wcOrderID = purchase.wcOrderID else {
        view?.showError(message: "WC order id does not exists.")
        return
      }
      view?.showLoading()
      PPAPIService.User.getMyPurchaseFeedback(wcOrderID: wcOrderID).call { (response) in
        switch response {
        case .success(let result):
          self.view?.hideLoading()
          if let feedback = FeedbackData(data: result.data) {
            self.feedback = feedback
          } else {
            self.feedback.id = nil
          }
          self.view?.reload()
        case .failure(let error):
          self.view?.hideLoading()
          self.view?.showError(message: error.localizedDescription)
        }
      }
    }
  }
}
