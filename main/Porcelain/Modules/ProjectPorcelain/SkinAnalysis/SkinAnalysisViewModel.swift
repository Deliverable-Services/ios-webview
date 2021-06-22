//
//  SkinAnalysisViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 12/12/19.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit
import SwiftyJSON

public enum SAStatViewByType: String {
  case yearly
  case monthly
}

public struct SkinTypeData {
  public var title: String
  public var description: String?
  public var image: String?
  
  public init?(data: JSON) {
    guard let title = data.title.string else { return nil }
    self.title = title
    description = data.description.string
    image = data.image.string
  }
}

public struct SkinAnalysisData {
  public var congestionLevel: Int
  public var hydrationLevel: Int
  public var beforeImages: [String]?
  public var afterImages: [String]?
  public var areas: JSON
  
  public init?(data: JSON) {
    guard data.id.numberString != nil else { return nil }
    congestionLevel = data.congestionLevel.intValue
    hydrationLevel = data.hydrationLevel.intValue
    beforeImages = data.beforeImages.array?.compactMap({ $0.string })
    afterImages = data.afterImages.array?.compactMap({ $0.string })
    areas = data.areas
  }
}

public struct SkinAnalysisStatsData {
  public var filterBy: String?
  public var month: String?
  public var year: String?
  public var periods: JSON
  
  public init?(data: JSON) {
    guard !data.periods.isEmpty else { return nil }
    filterBy = data.filterBy.string
    month = data.month.string
    year = data.year.string
    periods = data.periods
  }
}

public protocol SkinAnalysisView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func showError(message: String?)
}

public protocol SkinAnalysisViewModelProtocol: class {
  var skinTypes: [SkinTypeData]? { get }
  var filter: String { get set }
  var skinAnalysis: SkinAnalysisData? { get }
  var viewBy: SAStatViewByType { get set }
  var skinAnalysisStats: SkinAnalysisStatsData? { get }
  
  func attachView(_ view: SkinAnalysisView)
  func initialize()
  func reloadAnalysis(completion: VoidCompletion?)
  func reloadAnalysisStats(completion: VoidCompletion?)
  func compare()
}

public final class SkinAnalysisViewModel: SkinAnalysisViewModelProtocol {
  private weak var view: SkinAnalysisView?

  public var skinTypes: [SkinTypeData]?
  public var filter: String = "" {
    didSet {
      reloadAnalysis()
      reloadAnalysisStats()
    }
  }
  public var skinAnalysis: SkinAnalysisData?
  public var viewBy: SAStatViewByType = .monthly {
    didSet {
      reloadAnalysisStats()
    }
  }
  public var skinAnalysisStats: SkinAnalysisStatsData?
}

extension SkinAnalysisViewModel {
  public func attachView(_ view: SkinAnalysisView) {
    self.view = view
  }
  
  public func initialize() {
    skinTypes = JSON(parseJSON: AppUserDefaults.customer?.skinTypeRaw ?? "").array?.compactMap({ SkinTypeData(data: $0) })
    let dispatchGroup = DispatchGroup()
    dispatchGroup.enter()
    PPAPIService.User.getMySkinType().call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customerID = AppUserDefaults.customerID else { return }
          guard let customer = Customer.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
          customer.skinTypeRaw = result.data.rawString()
        }, completion: { (_) in
          self.skinTypes = JSON(parseJSON: AppUserDefaults.customer?.skinTypeRaw ?? "").array?.compactMap({ SkinTypeData(data: $0) })
          dispatchGroup.leave()
        })
      case .failure(let error):
        dispatchGroup.leave()
        self.view?.showError(message: error.localizedDescription)
      }
    }
    dispatchGroup.enter()
    reloadAnalysis {
      dispatchGroup.leave()
    }
    dispatchGroup.enter()
    reloadAnalysisStats {
      dispatchGroup.leave()
    }
    view?.reload()
    view?.showLoading()
    dispatchGroup.notify(queue: .main) { [weak self] in
      guard let `self` = self else { return }
      self.view?.hideLoading()
      self.view?.reload()
    }
  }
  
  public func reloadAnalysis(completion: VoidCompletion? = nil) {
    if completion == nil {
      appDelegate.showLoading()
    }
    skinAnalysis = SkinAnalysisData(data: JSON(parseJSON: AppUserDefaults.customer?.skinAnalysisRaw ?? ""))
    var request: [APIServiceConstant.Key: Any] = [:]
    request[.filterBy] = filter.emptyToNil ?? NSNull()
    PPAPIService.User.getMySkinAnalysis(request: request).call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customerID = AppUserDefaults.customerID else { return }
          guard let customer = Customer.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
          customer.skinAnalysisRaw = result.data.rawString()
        }, completion: { (_) in
          self.skinAnalysis = SkinAnalysisData(data: JSON(parseJSON: AppUserDefaults.customer?.skinAnalysisRaw ?? ""))
          if let completion = completion {
            completion()
          } else {
            appDelegate.hideLoading()
            self.view?.reload()
          }
        })
      case .failure(let error):
        if let completion = completion {
          completion()
        } else {
          appDelegate.hideLoading()
        }
        self.view?.showError(message: error.localizedDescription)
      }
    }
  }
  
  public func reloadAnalysisStats(completion: VoidCompletion? = nil) {
    if completion == nil {
      appDelegate.showLoading()
    }
    skinAnalysisStats = SkinAnalysisStatsData(data: JSON(parseJSON: AppUserDefaults.customer?.skinAnalysisStatsRaw ?? ""))
    var request: [APIServiceConstant.Key: Any] = [:]
    request[.filterBy] = filter.emptyToNil ?? NSNull()
    request[.viewBy] = viewBy.rawValue
    PPAPIService.User.getMySkinAnalysisStatistics(request: request).call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customerID = AppUserDefaults.customerID else { return }
          guard let customer = Customer.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
          customer.skinAnalysisStatsRaw = result.data.rawString()
        }, completion: { (_) in
          self.skinAnalysisStats = SkinAnalysisStatsData(data: JSON(parseJSON: AppUserDefaults.customer?.skinAnalysisStatsRaw ?? ""))
          if let completion = completion {
            completion()
          } else {
            appDelegate.hideLoading()
            self.view?.reload()
          }
        })
      case .failure(let error):
        if let completion = completion {
          completion()
        } else {
          appDelegate.hideLoading()
        }
        self.view?.showError(message: error.localizedDescription)
      }
    }
  }
  
  public func compare() {
  }
}
