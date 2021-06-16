//
//  LoadingImageView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 17/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import Kingfisher

@IBDesignable
public final class LoadingImageView: UIImageView, Designable {
  public var cornerRadius: CGFloat = 0.0 {
    didSet {
      updateLayer()
    }
  }
  
  public var borderWidth: CGFloat = 0.0 {
    didSet {
      updateLayer()
    }
  }
  
  public var borderColor: UIColor = .clear {
    didSet {
      updateLayer()
    }
  }
  
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
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    updateLayer()
  }
  
  public override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    
    image = placeholderImage
  }
}
