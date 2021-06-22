//
//  MyProductsUsageTableView.swift
//  Porcelain
//
//  Created by Justine Rangel on 25/03/2019.
//  Copyright © 2019 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit

public class MyProductsUsageTableView: UITableView {
  public var height: CGFloat {
    return CGFloat(contents.count) * rowHeight
  }
  
  public var contents: [ProductConsumption] = [] {
    didSet {
      reloadData()
    }
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    registerWithNib(MyProductsUsageCell.self)
    rowHeight = MyProductsUsageCell.defaultSize.height
    alwaysBounceVertical = false
    dataSource = self
  }
}

// MARK: - UITableViewDataSource
extension MyProductsUsageTableView: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return contents.count
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let myProductsUsageCell = tableView.dequeueReusableCell(MyProductsUsageCell.self, atIndexPath: indexPath)
    myProductsUsageCell.consumption = contents[indexPath.row]
    return myProductsUsageCell
  }
}

public class MyProductsUsageCell: UITableViewCell {
  @IBOutlet private weak var nameAndPercentageLabel: UILabel!
  @IBOutlet private weak var usageContainerView: DesignableView!
  @IBOutlet private weak var usageWidthConstraint: NSLayoutConstraint!
  
  public var consumption: ProductConsumption? {
    didSet {
      let attributedText = NSMutableAttributedString()
      attributedText.append(NSAttributedString(
        content: concatenate(consumption?.name ?? "", ": "),
        font: UIFont.Porcelain.openSans(13.0, weight: .regular),
        foregroundColor: UIColor.Porcelain.warmGrey,
        paragraphStyle: .makeCustomStyle(
          lineHeight: 20.0,
          characterSpacing: 0.4)))
      attributedText.append(NSAttributedString(
        content: concatenate(Int(consumption?.percentage ?? 0), "%"),
        font: UIFont.Porcelain.openSans(13.0, weight: .semiBold),
        foregroundColor: UIColor.Porcelain.greyishBrown,
        paragraphStyle: .makeCustomStyle(
          lineHeight: 20.0,
          characterSpacing: 0.4)))
      nameAndPercentageLabel.attributedText = attributedText
      usageWidthConstraint.constant = usageContainerView.bounds.width * CGFloat(consumption?.percentage ?? 0.0)/100
    }
  }
}

// MARK: - CellConfigurable
extension MyProductsUsageCell: CellConfigurable {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 54.0)
  }
}

