//
//  LoadingImageView.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 11/15/19.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

public final class LoadingImageView: UIImageView {
  public var placeholderImage: UIImage?
  public var url: String? {
    didSet {
      if let url = URL(string: url ?? "") {
        kf.indicatorType = .activity
        kf.setImage(with: ImageResource(downloadURL: url), placeholder: placeholderImage)
      } else {
        image = placeholderImage
      }
    }
  }
  
  public func reset() {
    kf.cancelDownloadTask()
    image = nil
  }
}
