//
//  ProductsSectionTCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 30/08/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public struct ProductsSectionData {
  public var categoryID: String
  public var categoryName: String
}

public final class ProductsSectionTCell: UITableViewCell {
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .idealSans(style: .book(size: 16.0))
      titleLabel.textColor = .gunmetal
    }
  }
  
  @IBOutlet private weak var collectionView: UICollectionView! {
    didSet {
      collectionView.registerWithNib(ProductsCCell.self)
      collectionView.dataSource = self
      collectionView.delegate = self
    }
  }
  @IBOutlet private weak var collectionHeightConstraint: NSLayoutConstraint! {
    didSet {
      collectionHeightConstraint.constant = ProductsCCell.defaultSize.height
    }
  }
  
  private lazy var frcHandler = FetchResultsControllerHandler<Product>(type: .collectionView(collectionView))
  
  public var data: ProductsSectionData? {
    didSet {
      if let data = data {
        titleLabel.text = data.categoryName
        var recipe = CoreDataRecipe()
        recipe.sorts = [
          .custom(key: "id", isAscending: true)]
        let predicates: [CoreDataRecipe.Predicate] = [
          .isEqual(key: "isActive", value: true),
          .contains(key: "categoryIDs", value: "<\(data.categoryID)>")]
        recipe.predicate = CoreDataRecipe.Predicate.compoundAnd(predicates: predicates).rawValue
        frcHandler.reload(recipe: recipe)
      } else {
        titleLabel.text = nil
        collectionView.reloadData()
      }
    }
  }
  
  public var didSelectProduct: ((Product) -> Void)?
  
  public override func prepareForReuse() {
    super.prepareForReuse()
    
    collectionView.setContentOffset(.zero, animated: false)
  }
}

// MARK: - CellProtocol
extension ProductsSectionTCell: CellProtocol {
}

// MARK: - UICollectionViewDataSource
extension ProductsSectionTCell: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return frcHandler.numberOfObjectsInSection(section)
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let productsCCell = collectionView.dequeueReusableCell(ProductsCCell.self, atIndexPath: indexPath)
    productsCCell.product = frcHandler.object(at: indexPath)
    return productsCCell
  }
}

// MARK: - UICollectionViewDelegate
extension ProductsSectionTCell: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    didSelectProduct?(frcHandler.object(at: indexPath))
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProductsSectionTCell: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return ProductsCCell.defaultSize
  }
}
