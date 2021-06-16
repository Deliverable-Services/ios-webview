//
//  LoadingContainerView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 09/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class LoadingContainerView: UIView, ActivityIndicatorProtocol {
  public var activityIndicatorView: UIActivityIndicatorView? {
    didSet {
      activityIndicatorView?.color = .gunmetal
      activityIndicatorView?.backgroundColor = .clear
    }
  }
  
  public var isLoading: Bool = false {
    didSet {
      if isLoading {
        showActivityOnView(self)
      } else  {
        hideActivity()
      }
    }
  }
}
