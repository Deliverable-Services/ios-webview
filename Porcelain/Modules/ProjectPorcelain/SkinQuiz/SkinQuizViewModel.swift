//
//  SkinQuizViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 11/21/19.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit
import SwiftyJSON

public enum SkinQuizQuestionDisplayStyle: String {
  case singleColumn = "SINGLE_COL"
  case doubleColumn = "DOUBLE_COL"
  case singleRadioColumn
  case singleCheckboxColumn
}

public struct SkinQuizData {
  public var name: String?
  public var code: String?
  public var questions: [SkinQuizQuestionData]?
  
  public init?(data: JSON) {
    guard let code = data.code.string else { return nil }
    name = data.name.string
    self.code = code
    questions = data.questionSet.array?.compactMap({ SkinQuizQuestionData(data: $0) }).sorted(by: { $0.position < $1.position })
  }
}

public struct SkinQuizQuestionData {
  public var id: String
  public var title: String?
  public var description: String?
  public var position: Int
  public var maxSelections: Int
  public var displayStyle: SkinQuizQuestionDisplayStyle
  public var answers: [SkinQuizAnwerData]?
  
  public init?(data: JSON) {
    guard let id = data.id.numberString else { return nil }
    self.id = id
    title = data.title.string
    description = data.description.string
    position = data.position.intValue
    maxSelections = data.maximumSelections.intValue
    answers = data.answerSet.array?.compactMap({ SkinQuizAnwerData(data: $0) }).sorted(by: { $0.id < $1.id })
    let isOdd = !(answers?.contains(where: { $0.image?.emptyToNil != nil }) ?? true)
    if isOdd {
      if maxSelections > 1 {
        displayStyle = .singleCheckboxColumn
      } else {
        displayStyle = .singleRadioColumn
      }
    } else {
      displayStyle = SkinQuizQuestionDisplayStyle(rawValue: data.mobileDisplayStyle.stringValue) ?? .singleColumn
    }
  }
}

public struct SkinQuizAnwerData {
  public var id: String
  public var questionID: String?
  public var title: String?
  public var description: String?
  public var image: String?
  
  public init?(data: JSON) {
    guard let id = data.id.numberString else { return nil }
    self.id = id
    questionID = data.questionID.numberString
    title = data.title.string
    description = data.description.string
    image = data.image.string
  }
  
  public static func parseSavedAnswers(data: JSON) -> [SkinQuizAnwerData]? {
    return data.answers.array?.compactMap({ SkinQuizAnwerData(data: $0) })
  }
}

public protocol SkinQuizView: class {
  func reload()
  func updateNavigation()
  func navigateToQuestion()
  func showLoading()
  func hideLoading()
  func showError(message: String?)
  func showQuizResults()
}

public protocol SkinQuizViewModelProtocol: SkinQuizQuestionAnswersModelDelegate {
  var skinQuiz: SkinQuizData? { get }
  
  var firstLoadQuestionID: String? { get set }
  var numberOfPages: Int { get }
  var currentPage: Int { get set }
  var displayPage: Int { get }
  var isPrevEnabled: Bool { get }
  var isNextEnabled: Bool { get }
  var isSkinQuizDone: Bool { get }
  
  
  func attachView(_ view: SkinQuizView)
  func initialize()
  func prevTapped()
  func nextTapped()
  func retakeTapped()
}

public final class SkinQuizViewModel: SkinQuizViewModelProtocol {
  private weak var view: SkinQuizView?
  
  public var skinQuiz: SkinQuizData? {
    didSet {
      numberOfPages = skinQuiz?.questions?.count ?? 0
    }
  }
  public var firstLoadQuestionID: String?
  public var skinQuizAnswers: [SkinQuizAnwerData] = []
  public var numberOfPages: Int = 0 {
    didSet {
      if numberOfPages > 0 {
        if currentPage < 0 {
          currentPage = 0
        } else if currentPage >= numberOfPages {
          currentPage = numberOfPages - 1
        }
      } else {
        currentPage = -1
      }
    }
  }
  public var currentPage: Int = 0
  public var displayPage: Int {
    return currentPage + 1
  }
  public var isPrevEnabled: Bool {
    return currentPage > 0
  }
  public var isNextEnabled: Bool {
    guard let questions = skinQuiz?.questions, !questions.isEmpty else { return false }
    let question = questions[currentPage]
    return skinQuizAnswers.filter({ $0.questionID == question.id }).count > 0
  }
  public var isSkinQuizDone: Bool = false
}

extension SkinQuizViewModel {
  public func attachView(_ view: SkinQuizView) {
    self.view = view
  }
  
  public func initialize() {
    skinQuiz = SkinQuizData(data: JSON(parseJSON: AppUserDefaults.customer?.skinQuizRaw ?? ""))
    let skinQuizAnswerJSON = JSON(parseJSON: AppUserDefaults.customer?.skinQuizAnswerRaw ?? "")
    skinQuizAnswers = SkinQuizAnwerData.parseSavedAnswers(data: skinQuizAnswerJSON) ?? []
    isSkinQuizDone = skinQuizAnswerJSON.isDone.boolValue
    let dispatchGroup = DispatchGroup()
    dispatchGroup.enter()
    PPAPIService.User.getMySkinQuiz().call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customerID = AppUserDefaults.customerID else { return }
          guard let customer = Customer.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
          customer.skinQuizRaw = result.data.rawString()
        }, completion: { (_) in
          dispatchGroup.leave()
        })
      case .failure(let error):
        dispatchGroup.leave()
        self.view?.showError(message: error.localizedDescription)
      }
    }
    dispatchGroup.enter()
    PPAPIService.User.getMySkinQuizAnswers().call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customerID = AppUserDefaults.customerID else { return }
          guard let customer = Customer.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
          customer.skinQuizAnswerRaw = result.data.rawString()
        }, completion: { (_) in
          dispatchGroup.leave()
        })
      case .failure:
        dispatchGroup.leave()
      }
    }
    view?.reload()
    view?.showLoading()
    dispatchGroup.notify(queue: .main) { [weak self] in
      guard let `self` = self else { return }
      self.skinQuiz = SkinQuizData(data: JSON(parseJSON: AppUserDefaults.customer?.skinQuizRaw ?? ""))
      let skinQuizAnswerJSON = JSON(parseJSON: AppUserDefaults.customer?.skinQuizAnswerRaw ?? "")
      self.skinQuizAnswers = SkinQuizAnwerData.parseSavedAnswers(data: skinQuizAnswerJSON) ?? []
      self.isSkinQuizDone = skinQuizAnswerJSON.isDone.boolValue
      self.view?.hideLoading()
      self.view?.reload()
      if self.isSkinQuizDone, AppUserDefaults.customer?.skinQuizResultURL ==  nil {
        self.compute(sendEmail: false)
      }
    }
  }
  
  public func prevTapped() {
    guard isPrevEnabled else { return }
    currentPage -= 1
    view?.navigateToQuestion()
  }
  
  public func nextTapped() {
    guard isNextEnabled else {
      view?.showError(message: "Please select a choice to continue.")
      return
    }
    if displayPage >= numberOfPages {
      compute(sendEmail: true)
//      if isSubmitEnabled {
//        compute()
//      } else {
//        view?.showError(message: "Questions must be filled out completety to continue")
//      }
    } else {
      currentPage += 1
      view?.navigateToQuestion()
    }
  }
  
  public func saveAnswers() {
    view?.updateNavigation()
    var request: [[String: Any]] = []
    skinQuizAnswers.forEach { (answer) in
      var reqAnswer: [String: Any] = [:]
      reqAnswer["id"] = answer.id
      reqAnswer["question_id"] = answer.questionID
      reqAnswer["title"] = answer.title
      reqAnswer["description"] = answer.description
      reqAnswer["image"] = answer.image
      reqAnswer["selected"] = true
      request.append(reqAnswer)
    }
    PPAPIService.User.createMySkinQuizAnswers(request: request).call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customerID = AppUserDefaults.customerID else { return }
          guard let customer = Customer.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
          customer.skinQuizAnswerRaw = result.data.rawString()
        }, completion: { (_) in
        })
      case .failure(let error):
        self.view?.showError(message: error.localizedDescription)
      }
    }
  }
  
  private func compute(sendEmail: Bool) {
    appDelegate.showLoading(message: "Calculating")
    PPAPIService.User.computeMySkinQuiz().call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customerID = AppUserDefaults.customerID else { return }
          guard let customer = Customer.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
          customer.skinQuizResultURL = result.data.redirectURL.string
        }, completion: { (_) in
          self.isSkinQuizDone = true
          if sendEmail {
            self.sendEmailResults()
          }
          appDelegate.hideLoading()
          self.view?.showQuizResults()
        })
      case .failure(let error):
        appDelegate.hideLoading()
        self.view?.showError(message: error.localizedDescription)
      }
    }
  }
  
  private func sendEmailResults() {
    var request: [APIServiceConstant.Key: Any] = [:]
    request[.userID] = AppUserDefaults.customerID
    PPAPIService.User.emailMySkinQuizResult(request: request).call { (_) in
    }
  }
  
  public func retakeTapped() {
    skinQuizAnswers = []
    view?.reload()
  }
}
