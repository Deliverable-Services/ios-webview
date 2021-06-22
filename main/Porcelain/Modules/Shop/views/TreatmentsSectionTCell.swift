//
//  TreatmentsSectionTCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 22/08/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import SwiftyJSON

public struct TreatmentsSectionData {
  public var categoryID: String
  public var categoryName: String
  
  public init?(data: JSON) {
    guard let categoryID = data.categoryID.string, let name = data.name.string else { return nil }
    self.categoryID = categoryID
    categoryName = name
  }
}

public final class TreatmentsSectionTCell: UITableViewCell {
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .idealSans(style: .book(size: 16.0))
      titleLabel.textColor = .gunmetal
    }
  }
  
  @IBOutlet private weak var collectionView: UICollectionView! {
    didSet {
      collectionView.registerWithNib(TreatmentsCCell.self)
      collectionView.dataSource = self
      collectionView.delegate = self
    }
  }
  
  private lazy var frcHandler = FetchResultsControllerHandler<Treatment>(type: .collectionView(collectionView))
  
  public var data: TreatmentsSectionData? {
    didSet {
      if let data = data {
        titleLabel.text = data.categoryName
        var recipe = CoreDataRecipe()
        recipe.sorts = [
          .custom(key: "name", isAscending: true)]
        let predicates: [CoreDataRecipe.Predicate] = [
          .isEqual(key: "categoryName", value: data.categoryName)]
        recipe.predicate = CoreDataRecipe.Predicate.compoundAnd(predicates: predicates).rawValue
        frcHandler.reload(recipe: recipe)
      } else {
        titleLabel.text = nil
        collectionView.reloadData()
      }
    }
  }
  
  public var didSelectTreatment: ((Treatment) -> Void)?
  
  public override func prepareForReuse() {
    super.prepareForReuse()
    
    collectionView.setContentOffset(.zero, animated: false)
  }
}

// MARK: - CellProtocol
extension TreatmentsSectionTCell: CellProtocol {
}

// MARK: - UICollectionViewDataSource
extension TreatmentsSectionTCell: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return frcHandler.numberOfObjectsInSection(section)
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let treatmentsCCell = collectionView.dequeueReusableCell(TreatmentsCCell.self, atIndexPath: indexPath)
    treatmentsCCell.treatment = frcHandler.object(at: indexPath)
    return treatmentsCCell
  }
}

// MARK: - UICollectionViewDelegate
extension TreatmentsSectionTCell: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    didSelectTreatment?(frcHandler.object(at: indexPath))
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TreatmentsSectionTCell: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: max(0.0, collectionView.bounds.width - 95.0), height: TreatmentsCCell.defaultSize.height)
  }
}
