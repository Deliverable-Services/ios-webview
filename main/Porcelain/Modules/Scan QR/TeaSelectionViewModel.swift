//
//  TeaSelectionViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 01/10/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit
import SwiftyJSON

public struct TeaItemData {
  public var id: String
  public var name: String?
  public var description: String?
  
  init?(data: JSON) {
    guard let id = data.id.numberString else { return nil }
    self.id = id
    name = data.name.string
    description = data.desc.string
  }
}

public struct BeautyTipsData {
  public struct Tip {
    public var title: String?
    public var description: String?
    
    public init?(data: JSON) {
      guard let desc = data.desc.string else { return nil }
      title = data.title.string
      description = desc
    }
  }
  public var heading: String?
  public var tips: [Tip]
  
  public init?(data: JSON) {
    guard let tips = data.tips.array?.compactMap({ Tip(data: $0) }), !tips.isEmpty else { return nil }
    heading = data.heading.string
    self.tips = tips
  }
}

public protocol TeaSelectionView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func showError(message: String)
}

public protocol TeaSelectionViewModelProtocol: class {
  var teas: [TeaItemData] { get }
  var beautyTips: BeautyTipsData? { get }
  
  func attachView(_ view: TeaSelectionView)
  func initialize()
}

public final class TeaSelectionViewModel: TeaSelectionViewModelProtocol {
  private weak var view: TeaSelectionView?
  
  public var teas: [TeaItemData] = []
  public var beautyTips: BeautyTipsData?
}

extension TeaSelectionViewModel {
  public func attachView(_ view: TeaSelectionView) {
    self.view = view
  }
  
  public func initialize() {
    view?.showLoading()
    PPAPIService.Mirror.getMirror().call { (response) in
      switch response {
      case .success(let result):
        self.view?.hideLoading()
        self.teas = result.data.teas.arrayValue.compactMap({ TeaItemData(data: $0) })
        self.beautyTips = BeautyTipsData(data: result.data["beautyTips"])
        self.view?.reload()
      case .failure(let error):
        self.view?.hideLoading()
        self.view?.showError(message: error.localizedDescription)
      }
    }
  }
}
