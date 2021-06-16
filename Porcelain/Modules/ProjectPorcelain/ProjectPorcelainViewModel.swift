//
//  ProjectPorcelainViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 27/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit
import SwiftyJSON

public enum ProjectPorcelainSection {
  case weather
  case banner
  case skinQuiz
}

public protocol ProjectPorcelainView: class {
  func reload()
  func showLoading(section: ProjectPorcelainSection)
  func hideLoading(section: ProjectPorcelainSection)
  func showError(message: String?)
  func updateNotificationBadge()
}

public protocol ProjectPorcelainViewModelProtocol: WeatherInformationViewModelProtocol, TimedSliderViewModelProtocol {
  var notificationBadge: String? { get }
  var skinQuizAnswers: [SkinQuizAnwerData] { get }
  var skinQuizSkinProfileAnswers: [SkinQuizAnwerData] { get }
  var skinQuizSkinConcernsAnswers: [SkinQuizAnwerData] { get }
  var isSkinQuizDone: Bool { get }
  
  func attachView(_ view: ProjectPorcelainView)
  func initialize()
  func reloadNotifications()
  func reloadSkinQuiz()
}

public final class ProjectPorcelainViewModel: ProjectPorcelainViewModelProtocol {
  private weak var view: ProjectPorcelainView?
  
  public var notificationBadge: String?
  
  public var skinQuizAnswers: [SkinQuizAnwerData]  = []
  
  public var skinQuizSkinProfileAnswers: [SkinQuizAnwerData] {
    return skinQuizAnswers.filter({ $0.questionID == "1" }).sorted(by: { $0.id < $1.id })
  }
  
  public var skinQuizSkinConcernsAnswers: [SkinQuizAnwerData] {
    return skinQuizAnswers.filter({ $0.questionID == "3" }).sorted(by: { $0.id < $1.id })
  }
  public var isSkinQuizDone: Bool = false
  
  private var weatherRequest: URLSessionDataTask?
  
  public var weatherInformationData: WeatherInformationData?
  
  public var timedSliderScrollTiming: TimeInterval? {
    return 10
  }
  
  public var timedSliderContents: [TimedSliderDataProtocol] = []
}

extension ProjectPorcelainViewModel {
  public func attachView(_ view: ProjectPorcelainView) {
    self.view = view
  }
  
  public func initialize() {
    reloadSkinQuizAnswer()
    reloadBanner()
    reloadNotifications()
    view?.reload()
  }
  
  public func reloadSkinQuiz() {
    let skinQuizAnswerJSON = JSON(parseJSON: AppUserDefaults.customer?.skinQuizAnswerRaw ?? "")
    skinQuizAnswers = SkinQuizAnwerData.parseSavedAnswers(data: skinQuizAnswerJSON) ?? []
    isSkinQuizDone = skinQuizAnswerJSON.isDone.boolValue
    view?.hideLoading(section: .skinQuiz)
  }
  
  private func reloadSkinQuizAnswer() {
    let skinQuizAnswerJSON = JSON(parseJSON: AppUserDefaults.customer?.skinQuizAnswerRaw ?? "")
    skinQuizAnswers = SkinQuizAnwerData.parseSavedAnswers(data: skinQuizAnswerJSON) ?? []
    isSkinQuizDone = skinQuizAnswerJSON.isDone.boolValue
    view?.showLoading(section: .skinQuiz)
    PPAPIService.User.getMySkinQuizAnswers().call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customerID = AppUserDefaults.customerID else { return }
          guard let customer = Customer.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
          customer.skinQuizAnswerRaw = result.data.rawString()
        }, completion: { (_) in
          let skinQuizAnswerJSON = JSON(parseJSON: AppUserDefaults.customer?.skinQuizAnswerRaw ?? "")
          self.skinQuizAnswers = SkinQuizAnwerData.parseSavedAnswers(data: skinQuizAnswerJSON) ?? []
          self.isSkinQuizDone = skinQuizAnswerJSON.isDone.boolValue
          self.view?.hideLoading(section: .skinQuiz)
        })
      case .failure:
        self.view?.hideLoading(section: .skinQuiz)
      }
    }
  }
  
  public func reloadNotifications() {
    updateNotificationBadge()
    guard AppUserDefaults.isLoggedIn else { return }
    PPAPIService.User.getMyNotifications().call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customerID = AppUserDefaults.customerID else { return }
          guard let customer = User.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
          AppNotification.parseNotificationsFromData(result.data, customer: customer, inMOC: moc)
        }, completion: { (_) in
          self.updateNotificationBadge()
        })
      case .failure: break
      }
    }
  }
}

extension ProjectPorcelainViewModel {
  public func reloadWeather(latitude: Double, longitude: Double) {
     weatherRequest?.cancel()
     view?.showLoading(section: .weather)
     weatherRequest = PPAPIService.getWeather(latitude: concatenate(latitude), longitude: concatenate(longitude)).call { [weak self] (response) in
       guard let `self` = self else { return }
       switch response {
       case .success(let result):
         self.weatherInformationData = WeatherInformationData(data: result.data)
         self.view?.hideLoading(section: .weather)
       case .failure(let error):
         r4pidLog(error.localizedDescription)
         self.view?.hideLoading(section: .weather)
       }
     }
   }
  
  private func reloadBanner() {
    BannerDefaults.updateSessionTimestampIfNeeded()
    view?.showLoading(section: .banner)
    PPAPIService.getBanners(
      type: "DASHBOARD",
      temperature: weatherInformationData?.temperature,
      humidity: weatherInformationData?.humidPercent,
      lastSessionTimestamp: BannerDefaults.lastSessionTimestamp?.toString).call { (response) in
      switch response {
      case .success(let result):
        self.timedSliderContents = BannerData.loadBanner(data: result.data)
        self.view?.hideLoading(section: .banner)
      case .failure:
        self.view?.hideLoading(section: .banner)
      }
    }
  }
  
  private func updateNotificationBadge() {
    var count = 0
    if let customerID = AppUserDefaults.customerID {
      count = CoreDataUtil.count(
        AppNotification.self,
        predicate: .compoundAnd(predicates: [
          .isEqual(key: "customer.id", value: customerID),
          .isEqual(key: "isRead", value: false)]))
    }
    self.notificationBadge = count > 0 ? "\(count)": nil
    self.view?.updateNotificationBadge()
  }
}
