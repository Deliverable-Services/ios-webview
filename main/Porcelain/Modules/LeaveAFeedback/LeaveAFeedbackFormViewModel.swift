//
//  LeaveAFeedbackFormViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 03/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit
import Kingfisher

public enum FeedbackType {
  case tellUsMore(dataType: FeedbackDataType)
  case reportAnIssue(dataType: FeedbackDataType)
  
  public var navigationTitle: String {
    switch self {
    case .tellUsMore(let dataType):
      switch dataType {
      case .appointment:
        return "Tell Us More"
      case .purchase:
        return "Tell us how you feel!"
      }
    case .reportAnIssue(let dataType):
      switch dataType {
      case .appointment:
        return "Report An Issue"
      case .purchase:
        return "Report An Issue"
      }
    }
  }
  
  public var title: String {
    switch self {
    case .tellUsMore(let dataType):
      switch dataType {
      case .appointment:
        return """
        How did we do? We’d love to hear from you!

        We’re always working to make Porcelain exactly what you need to have healthy skin! Your feedback helps us decide what needs to be done and what improvements should be made to better the experience for all our customers!
        """
      case .purchase:
        return """
        Your feedback means a lot to us. We'd love to hear your thoughts about our products!
        """
      }
    case .reportAnIssue(let dataType):
      switch dataType {
      case .appointment:
        return """
        Please share your experience with us so we can make sure to improve it both for you and other customers in future.

        We can assure you it will make a world of difference.
"""
      case .purchase:
        return "What went wrong?"
      }
    }
  }
  
  public var choices: [String] {
    switch self {
    case .tellUsMore(let dataType):
      switch dataType {
      case .appointment:
        return [
          "Facial Treatment",
          "Staff",
          "Porcelain Products",
          "Overall Experience",
          "Others"]
      case .purchase:
        return [
          "Delivery Process",
          "Product Packaging",
          "Price of Product",
          "Product Information & Details",
          "Effective",
          "Others"]
      }
    case .reportAnIssue(let dataType):
      switch dataType {
      case .appointment:
        return [
          "Customer Service",
          "Facial Treatment",
          "Account Details",
          "Others"]
      case .purchase:
        return [
          "There is something wrong with my order",
          "My order did not arrive",
          "Item(s) is/are missing from my order",
          "I want to replace my order", "Others"]
      }
    }
  }
  
  public var placeholder: String {
    switch self {
    case .tellUsMore:
      return "Enter your feedback here..."
    case .reportAnIssue:
      return "Give us more details..."
    }
  }
  
  public var submitTitle: String {
    switch self {
    case .tellUsMore:
      return "SUBMIT FEEDBACK"
    case .reportAnIssue:
      return "SUBMIT ISSUE"
    }
  }
  
  public var dataType: FeedbackDataType {
    switch self {
    case .tellUsMore(let dataType):
      return dataType
    case .reportAnIssue(let dataType):
      return dataType
    }
  }
}

public protocol LeaveAFeedbackFormView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func showError(message: String?)
  func showSuccess(message: String?)
}

public protocol LeaveAFeedbackFormViewModelProtocol {
  var type: FeedbackType { get }
  var feedback: FeedbackData { get set }
  var attachments: [AttachmentData]? { get set }
  var url: String { get }
  var hasExistingFeedback: Bool { get }
  
  func attachView(_ view: LeaveAFeedbackFormView)
  func initialize()
  func submit()
}

public final class LeaveAFeedbackFormViewModel: LeaveAFeedbackFormViewModelProtocol {
  private weak var view: LeaveAFeedbackFormView?
  
  public var type: FeedbackType
  
  init(type: FeedbackType, feedback: FeedbackData) {
    self.type = type
    self.feedback = feedback
    if !type.choices.contains(feedback.feedback ?? "") {
      self.feedback.feedback = nil
      self.feedback.feedbackDetails = nil
    }
    attachments = feedback.images?.map({ AttachmentData(image: nil, imageURL: $0) })
  }
  public var feedback: FeedbackData
  public var attachments: [AttachmentData]?
  public var url: String {
    return type.dataType.url ?? AppConstant.estoreURL
  }
  public var hasExistingFeedback: Bool {
    return feedback.id != nil
  }
}

extension LeaveAFeedbackFormViewModel {
  public func attachView(_ view: LeaveAFeedbackFormView) {
    self.view = view
  }
  
  public func initialize() {
    view?.reload()
  }
  
  public func submit() {
    var fileRequest: [APIServiceConstant.Key: Any] = [:]
    fileRequest[.feedbackType] = feedback.feedback
    fileRequest[.details] = feedback.feedbackDetails
    fileRequest[.rate] = feedback.rating
    fileRequest[.imagesArr] = attachments?.compactMap({ UploadPart(filename: "feedback\(arc4random()).png", data: $0.image?.data) })
    switch type {
    case .tellUsMore(let dataType):
      switch dataType {
      case .appointment(let appointment):
        let request: PPAPIService
        if hasExistingFeedback {
          request = PPAPIService.User.updateMyAppointmentFeedback(appointmentID: appointment.id!, fileRequest: fileRequest)
        } else {
          request = PPAPIService.User.submitMyAppointmentFeedback(appointmentID: appointment.id!, fileRequest: fileRequest)
        }
        view?.showLoading()
        request.call { (response) in
          switch response {
          case .success(let result):
            if let images = result.data.images.array?.compactMap({ $0.string }) {
              images.forEach { (image) in
                ImageCache.default.removeImage(forKey: image)
              }
            }
            self.view?.hideLoading()
            self.view?.showSuccess(message: result.message)
          case .failure(let error):
            self.view?.hideLoading()
            self.view?.showError(message: error.localizedDescription)
          }
        }
      case .purchase(let purchase):
        let request: PPAPIService
        if hasExistingFeedback {
          request = PPAPIService.User.updateMyPurchaseFeedback(wcOrderID: purchase.wcOrderID!, fileRequest: fileRequest)
        } else {
          request = PPAPIService.User.submitMyPurchaseFeedback(wcOrderID: purchase.wcOrderID!, fileRequest: fileRequest)
        }
        view?.showLoading()
        request.call { (response) in
          switch response {
          case .success(let result):
            if let images = result.data.images.array?.compactMap({ $0.string }) {
              images.forEach { (image) in
                ImageCache.default.removeImage(forKey: image)
              }
            }
            self.view?.hideLoading()
            self.view?.showSuccess(message: result.message)
          case .failure(let error):
            self.view?.hideLoading()
            self.view?.showError(message: error.localizedDescription)
          }
        }
      }
    case .reportAnIssue(let dataType):
      switch dataType {
      case .appointment(let appointment):
        let request: PPAPIService
        if hasExistingFeedback {
          request = PPAPIService.User.updateMyAppointmentFeedback(appointmentID: appointment.id!, fileRequest: fileRequest)
        } else {
          request = PPAPIService.User.submitMyAppointmentFeedback(appointmentID: appointment.id!, fileRequest: fileRequest)
        }
        view?.showLoading()
        request.call { (response) in
          switch response {
          case .success(let result):
            if let images = result.data.images.array?.compactMap({ $0.string }) {
              images.forEach { (image) in
                ImageCache.default.removeImage(forKey: image)
              }
            }
            self.view?.hideLoading()
            self.view?.showSuccess(message: result.message)
          case .failure(let error):
            self.view?.hideLoading()
            self.view?.showError(message: error.localizedDescription)
          }
        }
      case .purchase(let purchase):
        let request: PPAPIService
        if hasExistingFeedback {
          request = PPAPIService.User.updateMyPurchaseFeedback(wcOrderID: purchase.wcOrderID!, fileRequest: fileRequest)
        } else {
          request = PPAPIService.User.submitMyPurchaseFeedback(wcOrderID: purchase.wcOrderID!, fileRequest: fileRequest)
        }
        view?.showLoading()
        request.call { (response) in
          switch response {
          case .success(let result):
            if let images = result.data.images.array?.compactMap({ $0.string }) {
              images.forEach { (image) in
                ImageCache.default.removeImage(forKey: image)
              }
            }
            self.view?.hideLoading()
            self.view?.showSuccess(message: result.message)
          case .failure(let error):
            self.view?.hideLoading()
            self.view?.showError(message: error.localizedDescription)
          }
        }
      }
    }
  }
}
