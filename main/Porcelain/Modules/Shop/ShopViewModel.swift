//
//  ShopViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 19/08/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit

public enum ShopSection: Int {
  case products = 0
  case treatments
}

public protocol ShopView: class {
  func reload(section: ShopSection)
  func showLoading(section: ShopSection)
  func hideLoading(section: ShopSection)
  func showError(message: String?)
}

public protocol ShopViewModelProtocol: class {
  var productSections: [ProductsSectionData] { get }
  var treatmentSections: [TreatmentsSectionData] { get }
  var emptyNotificationActionData: EmptyNotificationActionData? { get }
  
  func attachView(_ view: ShopView)
  func initialize()
  func initializeProducts()
  func initializeTreatments()
}

public final class ShopViewModel: ShopViewModelProtocol {
  private weak var view: ShopView?
  private var productsAPIService: URLSessionDataTask?
  private var treatmentsAPIService: URLSessionDataTask?
  
  public var productSections: [ProductsSectionData] = []
  public var treatmentSections: [TreatmentsSectionData] = []
  public var emptyNotificationActionData: EmptyNotificationActionData?
}

extension ShopViewModel {
  public func attachView(_ view: ShopView) {
    self.view = view
  }
  
  public func initialize() {
    view?.reload(section: .products)
    view?.reload(section: .treatments)
    initializeProducts()
    initializeTreatments()
  }
  
  public func initializeProducts() {
    productsAPIService?.cancel()
    view?.showLoading(section: .products)
    productsAPIService = PPAPIService.getProducts().call { [weak self] (response) in
      guard let `self` = self else { return }
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          result.data.arrayValue.forEach { (data) in
            guard let category = data.name.string else { return }
            Product.parseProductsFromData(data.products, category: category, inMOC: moc)
          }
        }, completion: { (_) in
          self.productSections = result.data.arrayValue
            .filter({ !$0.products.isEmpty })
            .map({ ProductsSectionData(categoryID: $0.categoryID.stringValue, categoryName: $0.name.stringValue)})
          self.productSections.sort(by: { $0.categoryName < $1.categoryName })
          self.view?.hideLoading(section: .products)
          if !self.productSections.isEmpty {
            self.emptyNotificationActionData = nil
          } else {
            self.emptyNotificationActionData = EmptyNotificationActionData(
              title: "No Products.",
              subtitle: nil,
              action: "RELOAD")
          }
          self.view?.reload(section: .products)
        })
      case .failure(let error):
        guard !(error.failureCode.rawCode == -1 && error.localizedDescription == "cancelled") else { return }
        self.productSections = []
        self.view?.hideLoading(section: .products)
        self.emptyNotificationActionData = EmptyNotificationActionData(
          title: error.localizedDescription,
          subtitle: nil,
          action: "RELOAD")
        self.view?.reload(section: .products)
      }
    }
  }
  
  public func initializeTreatments() {
    treatmentsAPIService?.cancel()
    view?.showLoading(section: .treatments)
    treatmentsAPIService = PPAPIService.Center.getAllServices().call { [weak self] (response) in
      guard let `self` = self else { return }
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          Treatment.parseTreatmentsFromData(result.data, inMOC: moc)
        }, completion: { (_) in
          var categories: [TreatmentsSectionData] = []
          result.data.array?.forEach { (data) in
            guard !categories.contains(where: { $0.categoryID == data.category.categoryID.string }) else { return }
            guard let category = TreatmentsSectionData(data: data.category) else { return }
            categories.append(category)
          }
          self.treatmentSections = categories.sorted(by: { $0.categoryName < $1.categoryName })
          self.view?.hideLoading(section: .treatments)
          if !self.treatmentSections.isEmpty {
            self.emptyNotificationActionData = nil
          } else {
            self.emptyNotificationActionData = EmptyNotificationActionData(
              title: "No Treatments.",
              subtitle: nil,
              action: "RELOAD")
          }
          self.view?.reload(section: .treatments)
        })
      case .failure(let error):
        guard !(error.failureCode.rawCode == -1 && error.localizedDescription == "cancelled") else { return }
        self.treatmentSections = []
        self.view?.hideLoading(section: .treatments)
        self.emptyNotificationActionData = EmptyNotificationActionData(
          title: error.localizedDescription,
          subtitle: nil,
          action: "RELOAD")
        self.view?.reload(section: .treatments)
      }
    }
  }
}
