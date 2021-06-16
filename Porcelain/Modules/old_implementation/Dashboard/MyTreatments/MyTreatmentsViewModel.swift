//
//  MyTreatmentsViewModel.swift
//  Porcelain
//
//  Created by Justine Rangel on 14/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation

public struct MyTreatmentsItemViewModel: MyTreatmentsItemViewModelProtocol {
  public var title: String
  
  public var imageURL: String?
  
  public var description: String?
  
  public var frequencyDescription: String?
  
  public var tipsDescription: String?
}

public protocol MyTreatmentsView: class {
  func scrollToIndex(_ index: Int)
}

public protocol MyTreatmentsViewModelProtocol: MyTreatmentsSegmentedViewModelProtocol {
  var treatments: [MyTreatmentsItemViewModel] { get }
  
  func attachView(_ view: MyTreatmentsView)
}

public class MyTreatmentsViewModel: MyTreatmentsViewModelProtocol {
  fileprivate weak var view: MyTreatmentsView?
  
  init(treatments: [MyTreatmentsItemViewModel], selectedItemIndex: Int? = nil) {
    self.selectedItemIndex = selectedItemIndex ?? 0
    self.treatments = treatments
    self.previewImagesURL = treatments.map({ $0.imageURL })
  }
  
  public var selectedItemIndex: Int? {
    didSet {
      guard let selectedItemIndex = selectedItemIndex else { return }
      view?.scrollToIndex(selectedItemIndex)
    }
  }
  
  public var treatments: [MyTreatmentsItemViewModel] = []
  
  public var previewImagesURL: [String?] = []
}

extension MyTreatmentsViewModel {
  public func attachView(_ view: MyTreatmentsView) {
    self.view = view
  }
}
