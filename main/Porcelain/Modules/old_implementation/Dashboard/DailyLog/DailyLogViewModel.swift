//
//  DailyLogViewModel.swift
//  Porcelain
//
//  Created by Justine Rangel on 16/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation


public protocol DailyLogView: class {
  func reload()
}

public class DailyLogTrackingViewModel: DailyLogTrackingViewProtocol {
  init(sectionTitle: String, incrementValue: Float, progress: Float, target: Float, isTrackingFulfilled: Bool, trackingFulfillmentDescription: String) {
    self.sectionTitle = sectionTitle
    self.incrementValue = incrementValue
    self.progress = progress
    self.target = target
    self.isTrackingFulfilled = isTrackingFulfilled
    self.trackingFulfillmentDescription = trackingFulfillmentDescription
  }
  
  public var fulfillDidTapped: VoidCompletion?
  
  public var sectionTitle: String
  
  public var incrementValue: Float
  
  public var progress: Float
  
  public var target: Float
  
  public var isTrackingFulfilled: Bool {
    didSet {
      fulfillDidTapped?()
    }
  }
  
  public var trackingFulfillmentDescription: String
}

public protocol DailyLogViewModelProtocol {
  var trackings: [DailyLogTrackingViewModel] { get }
  
  func attachView(_ view: DailyLogView)
}

public class DailyLogViewModel: DailyLogViewModelProtocol {
  init(trackings: [DailyLogTrackingViewModel]) {
    self.trackings = trackings
    
    for tracking in trackings {
      tracking.fulfillDidTapped = { [weak self] in
        guard let `self` = self else { return }
        self.view?.reload()
      }
    }
  }
  
  fileprivate weak var view: DailyLogView?
  
  public var trackings: [DailyLogTrackingViewModel] = []
}

extension DailyLogViewModel {
  public func attachView(_ view: DailyLogView) {
    self.view = view
  }
}
