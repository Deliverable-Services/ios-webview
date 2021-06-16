//
//  SmartMirrorViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 01/10/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit
import SwiftyJSON

public struct SkinTipData {
  public var title: String?
  public var description: String?
  
  init?(data: JSON) {
    title = data.title.string
    description = data.description.string
  }
}

public protocol SmartMirrorView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func showError(message: String?)
}

public protocol SmartMirrorViewModelProtocol: class {
  var teas: [TeaItemData] { get }
  
  func attachView(_ view: SmartMirrorView)
  func initialize()
}

public final class SmartMirrorViewModel: SmartMirrorViewModelProtocol {
  private weak var view: SmartMirrorView?
  
  public var teas: [TeaItemData] = []
}

extension SmartMirrorViewModel {
  public func attachView(_ view: SmartMirrorView) {
    self.view = view
  }
  
  public func initialize() {
    view?.showLoading()
  }
}
