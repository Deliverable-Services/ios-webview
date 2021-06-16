//
//  EditSkinLogViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 2/6/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit

public protocol EditSkinLogView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func showError(message: String?)
}

public protocol EditSkinLogViewModelProtocol: class {
  func attachView(_ view: EditSkinLogView)
  func initialize()
}

public final class EditSkinLogViewModel: EditSkinLogViewModelProtocol {
  public func attachView(_ view: EditSkinLogView) {
  }
  
  public func initialize() {
  }
}

extension EditSkinLogViewModel {
}
