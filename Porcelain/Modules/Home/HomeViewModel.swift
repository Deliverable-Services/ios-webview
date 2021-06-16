//
//  HomeViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 24/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit
import CoreLocation
import SwiftyJSON

public enum HomeSection {
  case weather
  case banner
  case articles
}

public enum ArticleSection {
  case news
  case prolouge
  case promotions
}

public protocol HomeView: class {
  func reload()
  func updateArticleSection()
  func showLoading(section: HomeSection)
  func hideLoading(section: HomeSection)
  func showError(message: String?)
  func updateNotificationBadge()
}

private struct BannerAttributedTextApperance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double?
  var alignment: NSTextAlignment? = .left
  var lineBreakMode: NSLineBreakMode? = .byTruncatingTail
  var minimumLineHeight: CGFloat?
  var font: UIFont?
  var color: UIColor?
}

public struct BannerData: TimedSliderDataProtocol {
  public var title: String?
  public var message: String?
  public var attributedString: NSAttributedString?
  public var dialogAttrString: NSAttributedString?
  public var readMoreData: Any?
  
  init(data: JSON) {
    title = data.title.string
    message = data.content.string
    attributedString = data.bannerHTMLFormat.string?.clean().htmlAttributedString?.trailingNewlineChopped
    dialogAttrString = data.dialogHTMLFormat.string?.clean().htmlAttributedString?.trailingNewlineChopped
    readMoreData = data
  }
  
  public static func loadBanner(data: JSON) -> [BannerData] {
    return data.arrayValue.map({ BannerData(data: $0) })
  }
}

extension NSAttributedString {
  fileprivate var trailingNewlineChopped: NSAttributedString {
    if self.string.hasSuffix("\n") {
      return attributedSubstring(from: NSRange(location: 0, length: length - 1))
    } else {
      return self
    }
  }
}

public protocol HomeViewModelProtocol: WeatherInformationViewModelProtocol, TimedSliderViewModelProtocol {
  var notificationBadge: String? { get }
  var articleSection: ArticleSection { get }
  var newsArticleData: ArticleSliderData { get }
  var prologueArticleData: ArticleSliderData { get }
  var promotionsArticleData: ArticleSliderData { get }
  
  func attachView(_ view: HomeView)
  func initialize()
  func setArticleSection(_ section: ArticleSection)
  func reloadNotifications()
}

public final class HomeViewModel: HomeViewModelProtocol {
  private weak var view: HomeView?
  
  public var notificationBadge: String?
  
  private var weatherRequest: URLSessionDataTask?
  
  public var weatherInformationData: WeatherInformationData? {
    didSet {
      guard oldValue?.temperature != weatherInformationData?.temperature ||
        oldValue?.humidPercent != weatherInformationData?.humidPercent else { return }
      reloadBanner()
    }
  }
  
  public var timedSliderScrollTiming: TimeInterval? {
    return 10
  }
  
  public var timedSliderContents: [TimedSliderDataProtocol] = []
  
  public var articleSection: ArticleSection = .news {
    didSet {
      view?.updateArticleSection()
    }
  }
  
  private var articleRequest: URLSessionDataTask?
  
  public var newsArticleData: ArticleSliderData {
    var recipe = CoreDataRecipe()
    recipe.sorts = [.sortIndex(isAscending: true)]
    recipe.predicate = CoreDataRecipe.Predicate.isEqual(key: "aType", value: ArticleType.news.rawValue).rawValue
    return ArticleSliderData(title: "Article of the week", recipe: recipe, visiblePublishDate: true)
  }
  
  public var prologueArticleData: ArticleSliderData  {
    var recipe = CoreDataRecipe()
    recipe.sorts = [.sortIndex(isAscending: true)]
    recipe.predicate = CoreDataRecipe.Predicate.isEqual(key: "aType", value: ArticleType.prologues.rawValue).rawValue
    return ArticleSliderData(title: "Latest Posts", recipe: recipe, visiblePublishDate: true)
  }
  
  
  public var promotionsArticleData: ArticleSliderData {
    var recipe = CoreDataRecipe()
    recipe.sorts = [.sortIndex(isAscending: true)]
    recipe.predicate = CoreDataRecipe.Predicate.isEqual(key: "aType", value: ArticleType.promotions.rawValue).rawValue
    return ArticleSliderData(title: "Latest Posts", recipe: recipe, visiblePublishDate: false)
  }
}
extension HomeViewModel {
  public func attachView(_ view: HomeView) {
    self.view = view
  }
  
  public func initialize() {
    view?.reload()
    reloadBanner()
    reloadNotifications()
    setArticleSection(articleSection)
  }
  
  public func setArticleSection(_ section: ArticleSection) {
    articleSection = section
    articleRequest?.cancel()
    let service: PPAPIService
    let articleType: ArticleType
    switch section {
    case .news:
      service = PPAPIService.getNews()
      articleType = .news
    case .prolouge:
      service = PPAPIService.getPrologues()
      articleType = .prologues
    case .promotions:
      service = PPAPIService.getPromotions()
      articleType = .promotions
    }
    view?.showLoading(section: .articles)
    service.call { [weak self] (response) in
      guard let `self` = self else { return }
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          Article.parseArticlesJSONData(result.data, aType: articleType, inMOC: moc)
        }, completion: { (_) in
          self.view?.hideLoading(section: .articles)
        })
      case .failure(let error):
        guard error.failureCode.rawCode != -1  && error.localizedDescription != "cancelled" else { return }
        self.view?.hideLoading(section: .articles)
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

extension HomeViewModel {
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
        guard error.failureCode.rawCode != -1  && error.localizedDescription != "cancelled" else { return }
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
      case .failure(let error):
        guard error.failureCode.rawCode != -1  && error.localizedDescription != "cancelled" else { return }
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

extension R4pidDefaultskey {
  fileprivate static let currentSessionTimestamp = R4pidDefaultskey(value: "E492973C88709538629\(AppUserDefaults.customerID ?? "")")
  fileprivate static let lastSessionTimestamp = R4pidDefaultskey(value: "D986251D8F42580973F3\(AppUserDefaults.customerID ?? "")")
}

public struct BannerDefaults {
  static func updateSessionTimestampIfNeeded() {
    guard AppUserDefaults.isLoggedIn else { return }
    let currentDate = Date()
    if let currentSessionTimestamp = currentSessionTimestamp,
      Date(timeIntervalSince1970: currentSessionTimestamp).toString(WithFormat: "MM-dd-yyyy") != currentDate.toString(WithFormat: "MM-dd-yyyy") {
      self.currentSessionTimestamp = currentDate.timeIntervalSince1970
      lastSessionTimestamp = currentSessionTimestamp
    } else {
      currentSessionTimestamp = currentDate.timeIntervalSince1970
      if lastSessionTimestamp == nil {
        lastSessionTimestamp = currentSessionTimestamp
      }
    }
  }
  
  public static var currentSessionTimestamp: TimeInterval? {
    get {
      return R4pidDefaults.shared[.currentSessionTimestamp]?.number?.doubleValue
    }
    set {
      R4pidDefaults.shared[.currentSessionTimestamp] = .init(value: newValue)
    }
  }
  
  public static var lastSessionTimestamp: TimeInterval? {
    get {
      return R4pidDefaults.shared[.lastSessionTimestamp]?.number?.doubleValue
    }
    set {
      R4pidDefaults.shared[.lastSessionTimestamp] = .init(value: newValue)
    }
  }
}
