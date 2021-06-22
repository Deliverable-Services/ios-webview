//
//  Product+CoreDataClass.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 19/08/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON
import R4pidKit

@objc(Product)
public class Product: NSManagedObject {
  public static func getProducts(productIDs: [String]? = nil, category: String? = nil, inMOC: NSManagedObjectContext = .main) -> [Product] {
    var predicates: [CoreDataRecipe.Predicate] = []
    if let category = category {
      predicates.append(.isEqual(key: "categoryName", value: category))
    }
    if let productIDs = productIDs, !productIDs.isEmpty {
      if productIDs.count == 1, let productID = productIDs.first {
        predicates.append(.isEqual(key: "id", value: productID))
      } else  {
        predicates.append(.isEqualIn(key: "id", values: productIDs))
      }
    }
    
    return CoreDataUtil.list(Product.self, predicate: .compoundAnd(predicates: predicates), inMOC: inMOC)
  }
  
  public static func getProduct(id: String, category: String? = nil, inMOC: NSManagedObjectContext = .main) -> Product? {
    return getProducts(productIDs: [id], category: category, inMOC: inMOC).first
  }
  
  public func updateFromData(_ data: JSON) {
    id = data.productID.numberString
    name = data.name.string
    url = data.url.string
    desc = data.description.string
    application = data.application.string
    sku = data.sku.string
    price = data.price.doubleValue
    status = data.status.string
    shortDesc = data.shortDescription.string
    shortHeader = data.shortHeader.string
    shortContent = data.shortContent.string
    featured = data.featured.boolValue
    quote = data.quote.string
    size = data.size.string
    averageRating = data.avgRating.doubleValue
    totalReviews = data.totalReviews.int32Value
    review = data.review.string
    inStock = data.inStock.boolValue
    if let categories = data.categories.array {
      categoryIDs = categories.compactMap({ $0.numberString }).map({ "<\($0)>" }).joined()
    }
    categoryID = data.categoryID.numberString ?? categoryID
    imagesRaw = data.images.rawString()
    attributesRaw = data.attributes.rawString()
    regularPrice = data.regularPrice.doubleValue
    salePrice = data.salePrice.doubleValue
    onSale = data.onSale.boolValue
    purchasable = data.purchasable.boolValue
    stockStatus = data.stockStatus.string
  }
  
  @discardableResult
  public static func parseProductFromData(_ data: JSON, products: [Product], category: String, inMOC: NSManagedObjectContext) -> Product? {
    guard let productID = data.productID.numberString else { return nil }
    let currentProduct = products.first(where: { $0.id == productID })
    let product = CoreDataUtil.createEntity(Product.self, fromEntity: currentProduct, inMOC: inMOC)
    product.updateFromData(data)
    product.categoryName = category
    return product
  }
  
  public static func parseProductsFromData(_ data: JSON, category: String, inMOC: NSManagedObjectContext) {
    let productArray = data.array ?? []
    let productIDs = productArray.compactMap({ $0.productID.numberString })
    
    let deprecatedProducts = CoreDataUtil.list(
      Product.self,
      predicate: .compoundAnd(predicates: [
        .isEqual(key: "isActive", value: true),
        .isEqual(key: "categoryName", value: category),
        .notEqualIn(key: "id", values: productIDs)]),
      inMOC: inMOC)
    deprecatedProducts.forEach { (product) in
      product.isActive = false
    }
    
    let products = getProducts(productIDs: productIDs, category: category, inMOC: inMOC)
    productArray.forEach { (data) in
      guard let product = parseProductFromData(data, products: products, category: category, inMOC: inMOC) else { return }
      product.isActive = true
    }
  }
}

// MARK: - Purchased product
extension Product {
  public static func parsePurchasedProductsFromData(_ data: JSON, inMOC: NSManagedObjectContext) {
    let productArray = data.array ?? []
    let productIDs = productArray.compactMap({ $0.productID.numberString })
    
    let products = getProducts(productIDs: productIDs, inMOC: inMOC)
    productArray.forEach { (data) in
      guard let categoryName = data.category.name.string else { return }
      parseProductFromData(data, products: products, category: categoryName, inMOC: inMOC)
    }
  }
}

extension Product {
  public struct Image {
    public var id: String?
    public var url: String
    public var position: Int
    
    public init?(data: JSON) {
      guard let url = data.src.string else { return nil }
      self.id = data.id.numberString
      self.url = url
      position = data.position.intValue
    }
  }
  
  public var images: [Image]? {
    return JSON(parseJSON: imagesRaw ?? "").array?.compactMap({ Image(data: $0) })
  }
}

public struct ProductVariationAttribute {
  private static let blacklist: [String] = []
  
  public var name: String
  public var options: [String]?
  
  public init?(data: JSON) {
    guard let name = data.name.string, !ProductVariationAttribute.blacklist.contains(name) else { return nil }
    self.name = name
    options = data.options.array?.compactMap({ $0.string })
  }
}

extension Product {
  public var attributes: [ProductVariationAttribute]? {
    return JSON(parseJSON: attributesRaw ?? "").array?.compactMap({ ProductVariationAttribute(data: $0) })
  }
}
