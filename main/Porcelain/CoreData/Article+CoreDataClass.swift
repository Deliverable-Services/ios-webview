//
//  Article+CoreDataClass.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 31/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON
import R4pidKit

public enum ArticleType: String {
  case news
  case prologues
  case promotions
}

@objc(Article)
public class Article: NSManagedObject {
  public static func getArticles(articleIDs: [String]? = nil, aType: ArticleType, inMOC: NSManagedObjectContext = .main) -> [Article] {
    var predicates: [CoreDataRecipe.Predicate] = [.isEqual(key: "aType", value: aType.rawValue)]
    if let articleIDs = articleIDs, !articleIDs.isEmpty {
      if articleIDs.count == 1, let articleID = articleIDs.first {
        predicates.append(.isEqual(key: "id", value: articleID))
      } else  {
        predicates.append(.isEqualIn(key: "id", values: articleIDs))
      }
    }
    return CoreDataUtil.list(Article.self, predicate: .compoundAnd(predicates: predicates), inMOC: inMOC)
  }
  
  public static func getArticle(id: String, aType: ArticleType, inMOC: NSManagedObjectContext = .main) -> Article? {
    return getArticles(articleIDs: [id], aType: aType, inMOC: inMOC).first
  }
  
  public func updateArticleFromData(data: JSON, aType: ArticleType) {
    self.id = data.articleID.number?.stringValue ?? data.id.number?.stringValue
    self.title = data.title.string ?? self.title
    self.description_ = data.description.string ?? self.description_
    self.datePublish = data.datePublish.string?.toDate(format: .ymdDateFormat) ?? self.datePublish
    self.category = data.category.string ?? self.category
    self.aType = aType.rawValue
    self.type = data.type.string ?? self.type
    self.source = data.source.string ?? self.source
    self.img = data.img.string ?? self.img
    self.dateCreated = data.createdAt.string?.toDate(format: .ymdhmsDateFormat) ?? self.dateCreated
    self.dateUpdated = data.updatedAt.string?.toDate(format: .ymdhmsDateFormat) ?? self.dateUpdated
  }
}

extension Article {
  public static func parseArticlesJSONData(_ data: JSON, aType: ArticleType, inMOC: NSManagedObjectContext) {
    let articleArray = data.array ?? []
    let articleIDs = articleArray.compactMap({ $0.articleID.string })
    
    let deprecatedArticles = CoreDataUtil.list(Article.self, predicate: .notEqualIn(key: "id", values: articleIDs), inMOC: inMOC)
    CoreDataUtil.deleteEntities(deprecatedArticles, inMOC: inMOC)
    
    let articles = getArticles(articleIDs: articleIDs, aType: aType, inMOC: inMOC)
    articleArray.enumerated().forEach { (indx, data) in
      let article = parseArticleJSONData(data, articles: articles, atype: aType, inMOC: inMOC)
      article?.sortIndex = (indx as NSNumber).int32Value
    }
  }

  @discardableResult
  public static func parseArticleJSONData(_ data: JSON, articles: [Article], atype: ArticleType, inMOC: NSManagedObjectContext) -> Article? {
    guard let articleID = data.articleID.number?.stringValue ?? data.id.number?.stringValue else { return nil }
    let currentArticle = articles.first(where: { $0.id == articleID })
    let article = CoreDataUtil.createEntity(Article.self, fromEntity: currentArticle, inMOC: inMOC)
    article.updateArticleFromData(data: data, aType: atype)
    return article
  }
}
