//
//  ProductViewViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 3/9/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit
import SwiftyJSON

public struct ProductVariation: Equatable {
  public var id: String
  public var productID: String
  public var price: Double
  public var regularPrice: Double
  public var salePrice: Double
  public var onSale: Bool
  public var stockStatus: String?
  public var inStock: Bool
  public var metaData: [String: String]
  
  public init?(data: JSON) {
    guard let id = data.variationID.numberString else { return nil }
    guard let productID = data.productID.numberString else { return nil }
    self.id = id
    self.productID = productID
    price = data.price.doubleValue
    regularPrice = data.regularPrice.doubleValue
    salePrice = data.salePrice.doubleValue
    onSale = data.onSale.boolValue
    stockStatus = data.stockStatus.string
    inStock = data.inStock.boolValue
    var metaData: [String: String] = [:]
    data.attributes.array?.forEach { (attribute) in
      guard let name = attribute.name.string else { return }
      guard let option = attribute.option.string else { return }
      metaData[name] = option
    }
    self.metaData = metaData
  }
  
  public var rawValue: [String: Any] {
    var attributes: [[String: Any]] = []
    metaData.forEach { (dict) in
      attributes.append(["name": dict.key, "option": dict.value])
    }
    return [
      "variation_id": id,
      "product_id": productID,
      "price": price,
      "regular_price": regularPrice,
      "sale_price": salePrice,
      "on_sale": onSale,
      "stock_status": stockStatus ?? "",
      "in_stock": inStock,
      "attributes": attributes]
  }
  
  public static func == (lhs: ProductVariation, rhs: ProductVariation) -> Bool {
    return lhs.id == rhs.id && lhs.metaData == rhs.metaData && lhs.price == rhs.price
  }
}

public enum ProductViewSection: Int {
  case about = 0
  case reviews
}

public protocol ProductViewView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func showError(message: String?)
}

public protocol ProductViewViewModelProtocol: class {
  var product: Product { get }
  var reviewsRecipe: CoreDataRecipe { get }
  var section: ProductViewSection { get set }
  var htmlString: String? { get }
  var availableVariations:  [ProductVariation]? { get }
  var hasError: Bool { get }
  
  func attachView(_ view: ProductViewView)
  func initialize()
  func reload()
}

public final class ProductViewViewModel: ProductViewViewModelProtocol {
  private weak var view: ProductViewView?
  
  public init(product: Product) {
    self.product = product
  }
  
  public var product: Product
  public var reviewsRecipe: CoreDataRecipe {
    var recipe = CoreDataRecipe()
    recipe.sorts = [.custom(key: "dateCreated", isAscending: false)]
    let predicates: [CoreDataRecipe.Predicate] = [
      .isEqual(key: "isActive", value: true),
      .isEqual(key: "productID", value: product.id)]
    recipe.predicate = CoreDataRecipe.Predicate.compoundAnd(predicates: predicates).rawValue
    return recipe
  }
  public var section: ProductViewSection = .about
  public var htmlString: String?
  public var availableVariations: [ProductVariation]?
  public var hasError: Bool = false
}

extension ProductViewViewModel {
  public func attachView(_ view: ProductViewView) {
    self.view = view
  }
  
  public func initialize() {
    view?.reload()
    guard let productID = product.id else { return }
    var errorMessage: String?
    let dispatchGroup = DispatchGroup()
    dispatchGroup.enter()
    PPAPIService.Product.getProductReviews(productID: productID).call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          Review.parseProductReviewsFromData(result.data, productID: productID, inMOC: moc)
        }, completion: { (_) in
          dispatchGroup.leave()
        })
      case .failure(let error):
        dispatchGroup.leave()
        errorMessage = error.localizedDescription
      }
    }
    dispatchGroup.enter()
    PPAPIService.Product.getProductExtraInfo(productID: productID).call { (response) in
      switch response {
      case .success(let result):
        self.hasError = false
        self.availableVariations = result.data.variations.array?.compactMap({ ProductVariation(data: $0) })
        self.htmlString = result.data.htmlDescription.string
        CoreDataUtil.performBackgroundTask({ (moc) in
          let product = Product.getProduct(id: productID, inMOC: moc)
          product?.inStock = result.data.inStock.boolValue
        }, completion: { (_) in
          dispatchGroup.leave()
        })
      case .failure(let error):
        self.hasError = true
        self.availableVariations = nil
        self.htmlString = nil
        dispatchGroup.leave()
        errorMessage = error.localizedDescription
      }
    }
    view?.showLoading()
    dispatchGroup.notify(queue: .main) { [weak self] in
      guard let `self` = self else { return }
      self.view?.hideLoading()
      self.view?.reload()
      if let errorMessage = errorMessage {
        self.view?.showError(message: errorMessage)
      }
    }
  }
  
  public func reload() {
    view?.reload()
  }
}
