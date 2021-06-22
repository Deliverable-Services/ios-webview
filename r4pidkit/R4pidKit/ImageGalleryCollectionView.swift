//
//  ImageGalleryCollectionView.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 11/15/19.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

public struct ImageGalleryItemAppearance: Designable {
  public var cornerRadius: CGFloat = 0.0
  public var borderWidth: CGFloat = 0.0
  public var borderColor: UIColor = .clear
  
  public init() {
  }
}

public struct ImageGalleryItemData {
  public var url: String?
  public var placeholderImage: UIImage?
  public var appearance: ImageGalleryItemAppearance
  
  public init(url: String, placeholderImage: UIImage? = nil, appearance: ImageGalleryItemAppearance? = nil) {
    self.url = url
    self.placeholderImage = placeholderImage
    self.appearance = appearance ?? ImageGalleryItemAppearance()
  }
}

public typealias ImageGalleryCompletion = (ImageGalleryItemData) -> Void

public struct ImageGalleryAppearance {
  public var cellSize: CGSize = CGSize(width: 56.0, height: 56.0)
}

public final class ImageGalleryCollectionView: UICollectionView {
  public var images: [ImageGalleryItemData]? {
    didSet {
      reloadData()
    }
  }
  
  public var appearance: ImageGalleryAppearance = ImageGalleryAppearance() {
    didSet {
      updateLayout()
      reloadData()
    }
  }
  
  private var cellSize: CGSize = CGSize(width: 56.0, height: 56.0)
  
  public var didSelectItem: ImageGalleryCompletion?
  
  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    commonInit()
  }
  
  public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: layout)
    
    commonInit()
  }
  
  private func commonInit() {
    registerWithClass(ImageGalleryCCell.self)
    updateLayout()
    dataSource = self
    delegate = self
  }
  
  private func updateLayout() {
    cellSize = appearance.cellSize
    if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
      layout.minimumLineSpacing = 3.0
      layout.minimumInteritemSpacing = 3.0
      layout.itemSize = cellSize
    }
  }
}

// MARK: - UICollectionViewDataSource
extension ImageGalleryCollectionView: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return images?.count ?? 0
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let imageGalleryCCell = collectionView.dequeueReusableCell(ImageGalleryCCell.self, atIndexPath: indexPath)
    imageGalleryCCell.data = images?[indexPath.row]
    return imageGalleryCCell
  }
}

//MARK: - UICollectionViewDelegate
extension ImageGalleryCollectionView: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let content = images?[indexPath.row] else { return }
    didSelectItem?(content)
  }
}
 
extension ImageGalleryCollectionView: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return cellSize
  }
}

public final class ImageGalleryCCell: UICollectionViewCell, Designable {
  public var cornerRadius: CGFloat = 0.0
  public var borderWidth: CGFloat = 0.0
  public var borderColor: UIColor = .clear
  
  private lazy var imageView: LoadingImageView = {
    let imageView = LoadingImageView(frame: .zero)
    imageView.contentMode = .scaleAspectFill
    addSubview(imageView)
    imageView.addContainerBoundsResizingMask()
    return imageView
  }()
  
  public var data: ImageGalleryItemData? {
    didSet {
      guard let data = data else { return }
      imageView.placeholderImage = data.placeholderImage
      imageView.url = data.url
      cornerRadius = data.appearance.cornerRadius
      borderWidth = data.appearance.borderWidth
      borderColor = data.appearance.borderColor
      updateLayer()
    }
  }
  
  public override var isSelected: Bool {
    didSet {
      alpha = isSelected ? 0.8: 1.0
    }
  }
  
  public override func prepareForReuse() {
    super.prepareForReuse()
    
    imageView.image = nil
  }
}

//MARK: - CellProtocol
extension ImageGalleryCCell: CellProtocol {
}
