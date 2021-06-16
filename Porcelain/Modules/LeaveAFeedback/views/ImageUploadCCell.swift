//
//  ImageUploadCCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 03/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class ImageUploadCCell: UICollectionViewCell, DashBorderable {
  public var dashBorderLayer: CAShapeLayer!
  
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .regular(size: 11.0))
      titleLabel.textColor = .bluishGrey
    }
  }
  
  public var type: Type = .uploadTitle("") {
    didSet {
      switch type {
      case .uploadTitle(let title):
        titleLabel.font = .openSans(style: .regular(size: 11.0))
        titleLabel.text = title
      case .upload(let current, let total):
        titleLabel.font = .openSans(style: .regular(size: 13.0))
        titleLabel.text = "\(current)/\(total)"
      }
    }
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    addDashBorder(appearance: .default)
  }
}

extension ImageUploadCCell {
  public enum `Type` {
    case uploadTitle(_ value: String)
    case upload(current: Int, total: Int)
  }
}

// MARK: - CellProtocol
extension ImageUploadCCell: CellProtocol {
  public static var defaultSize: CGSize {
    fatalError("ImageUploadCCell defaultSize not set")
  }
}
