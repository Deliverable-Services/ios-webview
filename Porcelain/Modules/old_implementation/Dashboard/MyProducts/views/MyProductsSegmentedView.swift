//
//  MyProductsSegmentedView.swift
//  Porcelain
//
//  Created by Justine Rangel on 20/11/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit

public protocol MyProductsSegmentedViewModelProtocol: class {
  var selectedItemIndex: Int? { get set }
  var previewImagesURL: [String?] { get set }
}

public class MyProductsSegmentedView: UIView, Shadowable {
  public var shadowLayer: CAShapeLayer!
  
  @IBOutlet fileprivate weak var previewCollectionView: UICollectionView!
  
  fileprivate var viewModel: MyProductsSegmentedViewModelProtocol!
  
  public func configure(viewModel: MyProductsSegmentedViewModelProtocol) {
    self.viewModel = viewModel
    previewCollectionView.reloadData()
    DispatchQueue.main.async {
      self.updateSelectedIndex()
    }
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    addShadow()
  }
  
  public func updateSelectedIndex() {
    guard let selectedItemIndex = viewModel.selectedItemIndex else { return }
    previewCollectionView.selectItem(at: IndexPath(row: selectedItemIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    previewCollectionView.dataSource = self
    previewCollectionView.delegate = self
  }
}

// MARK: - UICollectionViewDataSource
extension MyProductsSegmentedView: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.previewImagesURL.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let myProductsSegmentedPreviewCell = collectionView.dequeueReusableCell(MyProductsSegmentedPreviewCell.self, atIndexPath: indexPath)
    myProductsSegmentedPreviewCell.imageURL = viewModel.previewImagesURL[indexPath.row]
    return myProductsSegmentedPreviewCell
  }
}

// MARK: - UICollectionViewDataSource
extension MyProductsSegmentedView: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    viewModel.selectedItemIndex = indexPath.row
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MyProductsSegmentedView: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return MyProductsSegmentedPreviewCell.defaultSize
  }
}

public class MyProductsSegmentedPreviewCell: UICollectionViewCell {
  @IBOutlet private weak var previewImageVIew: UIImageView!
  public var imageURL: String? {
    didSet {
      guard let imageURL = imageURL else {
        previewImageVIew.image = #imageLiteral(resourceName: "sample-porcelein")
        return
      }
      previewImageVIew.image = UIImage(data: try! Data(contentsOf: URL(string: imageURL)!))
    }
  }
  
  public override var isSelected: Bool {
    didSet {
      backgroundColor = isSelected ? UIColor.Porcelain.blueGrey: .white
    }
  }
}

extension MyProductsSegmentedPreviewCell: CellConfigurable {
  public static var defaultSize: CGSize {
    return CGSize(width: 48.0, height: 48.0)
  }
}
