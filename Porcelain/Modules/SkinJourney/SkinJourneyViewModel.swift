//
//  SkinJourneyViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 2/6/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit

public protocol SkinJourneyView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func showError(message: String?)
}

public protocol SkinJourneyViewModelProtocol: class {
  func attachView(_ view: SkinJourneyView)
  func initialize()
}

public final class SkinJourneyViewModel: SkinJourneyViewModelProtocol {
  public func attachView(_ view: SkinJourneyView) {
  }
  
  public func initialize() {
  }
}

extension SkinJourneyViewModel {
  
}
