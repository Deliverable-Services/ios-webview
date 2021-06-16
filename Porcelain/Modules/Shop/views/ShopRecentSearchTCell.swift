//
//  ShopRecentSearchTCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 03/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class ShopRecentSearchTCell: UITableViewCell {
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .regular(size: 14.0))
      titleLabel.textColor = .bluishGrey
    }
  }
  
  public var title: String? {
    didSet {
      titleLabel.text = title
    }
  }
}

// MARK: - CellProtocol
extension ShopRecentSearchTCell: CellProtocol {
}
