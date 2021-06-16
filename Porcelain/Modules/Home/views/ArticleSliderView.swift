//
//  ArticleSliderView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 24/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Kingfisher
import R4pidKit

public struct ArticleSliderData {
  var title: String
  var recipe: CoreDataRecipe
  var visiblePublishDate: Bool
}

public final class ArticleSliderView: UIView, ActivityIndicatorProtocol, EmptyNotificationActionIndicatorProtocol {
  public var emptyNotificationActionView: EmptyNotificationActionView? {
    didSet {
      emptyNotificationActionView?.backgroundColor = .white
    }
  }
  
  public var activityIndicatorView: UIActivityIndicatorView? {
    didSet {
      activityIndicatorView?.color = .lightNavy
      activityIndicatorView?.backgroundColor = .clear
    }
  }
  
  @IBOutlet private weak var view: UIView!
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .idealSans(style: .book(size: 14.0))
      titleLabel.textColor = .gunmetal
    }
  }

  @IBOutlet private weak var collectionView: UICollectionView! {
    didSet {
      collectionView.registerWithNib(ArticleSliderItemCell.self)
      collectionView.dataSource = self
      collectionView.delegate = self
    }
  }
  
  public var didSelectArticle: ((Article)  -> Void)?
  
  public var isLoading: Bool = false  {
    didSet {
      view.isHidden = isLoading
      if isLoading {
        showActivityOnView(self)
      } else  {
        hideActivity()
      }
    }
  }
  
  public var emptyNotificationActionData: EmptyNotificationActionData? {
    didSet {
      if let emptyNotificationActionData = emptyNotificationActionData  {
        showEmptyNotificationActionOnView(self, type: .margin(data: emptyNotificationActionData))
      } else {
        hideEmptyNotificationAction()
      }
    }
  }
  
  public var emptyNotificationActionDidTapped: VoidCompletion?
  
  private lazy var frcHandler = FetchResultsControllerHandler<Article>(type: .collectionView(collectionView))
  
  public var data: ArticleSliderData? {
    didSet {
      titleLabel.text = data?.title
      if let recipe = data?.recipe {
        frcHandler.reload(recipe: recipe)
      } else {
        collectionView.reloadData()
      }
    }
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    loadNib(ArticleSliderView.self)
    addSubview(view)
    view.addContainerBoundsResizingMask()
  }
  
  public func emptyNotificationActionTapped(data: EmptyNotificationActionData) {
    emptyNotificationActionDidTapped?()
  }
}

// MARK: - UICollectionViewDataSource
extension ArticleSliderView: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return frcHandler.numberOfObjectsInSection(section)
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let articleSliderItemCell = collectionView.dequeueReusableCell(ArticleSliderItemCell.self, atIndexPath: indexPath)
    articleSliderItemCell.article = frcHandler.object(at: indexPath)
    articleSliderItemCell.visiblePublishDate = data?.visiblePublishDate ?? false
    return articleSliderItemCell
  }
}

// MARK: - UICollectionViewDelegate
extension ArticleSliderView: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    didSelectArticle?(frcHandler.object(at: indexPath))
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ArticleSliderView: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: max(0.0, collectionView.bounds.width - 95.0), height: ArticleSliderItemCell.defaultSize.height)
  }
}

private struct ArticleAttrDescriptionAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double?
  var alignment: NSTextAlignment?
  var lineBreakMode: NSLineBreakMode? {
    return .byTruncatingTail
  }
  var minimumLineHeight: CGFloat? {
    return 18.0
  }
  var font: UIFont?  {
    return .idealSans(style: .light(size: 12.0))
  }
  var color: UIColor? {
    return .bluishGrey
  }
}

public final class ArticleSliderItemCell: UICollectionViewCell, Shadowable {
  public var shadowLayer: CAShapeLayer!
  
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var dateBGView: UIView! {
    didSet {
      dateBGView.backgroundColor = .fadedPink
    }
  }
  @IBOutlet private weak var dateLabel: UILabel! {
    didSet {
      dateLabel.font = .openSans(style: .semiBold(size: 9.0))
      dateLabel.textColor = .white
    }
  }
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .idealSans(style: .book(size: 12.0))
      titleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var descriptionLabel: UILabel!
  
  public var article: Article? {
    didSet {
      if let url = URL(string: article?.img ?? "") {
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: ImageResource(downloadURL: url))
      }
      titleLabel.text = article?.title?.uppercased()
      dateLabel.text = article?.datePublish?.toString(WithFormat: "dd MMM yyyy")
      descriptionLabel.attributedText = article?.description_?.attributed.add(.appearance(ArticleAttrDescriptionAppearance()))
    }
  }
  
  public var visiblePublishDate: Bool = true {
    didSet {
      dateBGView.isHidden = !visiblePublishDate
    }
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    addShadow(appearance: .default)
  }
  
  public override func prepareForReuse() {
    super.prepareForReuse()
    
    imageView.kf.cancelDownloadTask()
    imageView.image = nil
  }
}

// MARK: - CellProtocol
extension ArticleSliderItemCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 234.0)
  }
}
