//
//  ProfileItemCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 17/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public struct ProfileItemData {
  public var title: String?
  public var subtitle: String?
  public var isCallOutShown: Bool = false
}

public final class ProfileItemCell: UITableViewCell {
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .idealSans(style: .light(size: 14.0))
      titleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var subtitleLabel: UILabel! {
    didSet {
      subtitleLabel.font = .openSans(style: .regular(size: 11.0))
      subtitleLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var calloutImageView: UIImageView! {
    didSet {
      calloutImageView.image = UIImage.icChevronRight.maskWithColor(.gunmetal)
    }
  }
  
  public var data: ProfileItemData? {
    didSet {
      titleLabel.text = data?.title
      subtitleLabel.text = data?.subtitle
      calloutImageView.isHidden = !(data?.isCallOutShown ?? false)
    }
  }
}

// MARK: - CellProtocol
extension ProfileItemCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 72.0)
  }
}
