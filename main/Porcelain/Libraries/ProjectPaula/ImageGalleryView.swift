//
//  ImageGalleryView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 11/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class ImageGalleryView: UIView {
  @IBOutlet private weak var view: UIView!
  @IBOutlet private weak var collectionView: UICollectionView! {
    didSet {
      collectionView.registerWithClass(ImageGalleryCell.self)
      collectionView.dataSource = self
      collectionView.delegate = self
    }
  }
  @IBOutlet private weak var pageControl: UIPageControl! {
    didSet {
      pageControl.pageIndicatorTintColor = .whiteThree
      pageControl.currentPageIndicatorTintColor = .gunmetal
    }
  }
  
  public var galleryImages: [String]? {
    didSet {
      pageControl.numberOfPages = galleryImages?.count ?? 0
      collectionView.reloadData()
    }
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    collectionView.collectionViewLayout.invalidateLayout()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    loadNib(ImageGalleryView.self)
    addSubview(view)
    view.addContainerBoundsResizingMask()
  }
}

// MARK: - UICollectionViewDataSource
extension ImageGalleryView: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return galleryImages?.count ?? 0
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let imageGalleryCell = collectionView.dequeueReusableCell(ImageGalleryCell.self, atIndexPath: indexPath)
    imageGalleryCell.galleryImage = galleryImages?[indexPath.row]
    return imageGalleryCell
  }
}

// MARK: - UICollectionViewDelegate
extension ImageGalleryView: UICollectionViewDelegate {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard pageControl.tag == 0 else { return }
    var pageFloat = scrollView.contentOffset.x/collectionView.bounds.width
    pageFloat.round(.toNearestOrAwayFromZero)
    let page = Int(pageFloat)
    guard pageControl.currentPage != page else { return }
    pageControl.currentPage = page
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ImageGalleryView: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return collectionView.bounds.size
  }
}

public final class ImageGalleryCell: UICollectionViewCell {
  private lazy var imageView: LoadingImageView = {
    let imageView = LoadingImageView()
    addSubview(imageView)
    imageView.contentMode = .scaleAspectFit
    imageView.cornerRadius = 1.0
    imageView.addSideConstraintsWithContainer()
    return imageView
  }()
  
  public var galleryImage: String? {
    didSet {
      imageView.url = galleryImage
    }
  }
  
  public override func prepareForReuse() {
    super.prepareForReuse()
    
    imageView.image = nil
  }
}

// MARK: - CellProtocol
extension ImageGalleryCell: CellProtocol {
}
