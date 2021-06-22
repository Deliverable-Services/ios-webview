//
//  PorcelainEnumeratedTableView.swift
//  Porcelain
//
//  Created by Justine Rangel on 06/07/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class PorcelainEnumeratedTableView: ResizingContentTableView {
  public var iconColor: UIColor = .lightNavy
  public var iconText: MaterialDesignIcon? = .check {
    didSet {
      if iconText != nil {
        iconImage = nil
      }
    }
  }
  public var iconImage: UIImage? = .icPorcelainBullet {
    didSet {
      if iconImage != nil {
        iconText = nil
      }
    }
  }
  public var fontColor: UIColor = .bluishGrey
  public var font: UIFont = .openSans(style: .regular(size: 13.0))
  public var contents: [String] = [] {
    didSet {
      reloadData()
    }
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    setAutomaticDimension()
    registerWithNib(PorcelainEnumeratedCell.self)
    separatorStyle = .none
    isScrollEnabled = false
    dataSource = self
  }
}

// MARK: - UITableViewDataSource
extension PorcelainEnumeratedTableView: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return contents.count
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let porcelainEnumeratedCell = tableView.dequeueReusableCell(PorcelainEnumeratedCell.self, atIndexPath: indexPath)
    porcelainEnumeratedCell.iconColor = iconColor
    porcelainEnumeratedCell.iconText = iconText
    porcelainEnumeratedCell.iconImage = iconImage
    porcelainEnumeratedCell.titleFontColor = fontColor
    porcelainEnumeratedCell.titleFont = font
    porcelainEnumeratedCell.title = contents[indexPath.row]
    return porcelainEnumeratedCell
  }
}

public final class PorcelainEnumeratedCell: UITableViewCell {
  @IBOutlet private weak var iconImageView: UIImageView!
  @IBOutlet private weak var materialIconLabel: UILabel!
  @IBOutlet private weak var titleLabel: DesignableLabel! {
    didSet {
      titleLabel.font = .openSans(style: .regular(size: 13.0))
      titleLabel.textColor = .bluishGrey
    }
  }
  
  public var iconColor: UIColor = .lightNavy
  public var iconText: MaterialDesignIcon? {
    didSet {
      materialIconLabel.isHidden = iconText == nil
      materialIconLabel.textColor = iconColor
      materialIconLabel.text = iconText?.rawValue
    }
  }
  public var iconImage: UIImage? {
    didSet {
      iconImageView.isHidden = iconImage == nil
      iconImageView.image = iconImage?.maskWithColor(iconColor)
    }
  }
  public var titleFontColor: UIColor = .bluishGrey
  public var titleFont: UIFont = .openSans(style: .regular(size: 13.0))
  public var title: String? {
    didSet {
      titleLabel.text = title
    }
  }
}

// MARK: - CellProtocol
extension PorcelainEnumeratedCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 25.0)
  }
}

