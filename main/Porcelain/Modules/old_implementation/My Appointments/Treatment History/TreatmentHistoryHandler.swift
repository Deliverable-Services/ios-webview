//
//  TreatmentHistoryHandler.swift
//  Porcelain
//
//  Created by Jean on 7/3/18.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import SwiftyJSON

enum TreatmentHistoryAction {
  case getTreatmentHistory
}

protocol TreatmentHistoryHandlerProtocol: class {
  var delegate: TreatmentHistoryHandlerDelegate? { get }
}

protocol TreatmentHistoryHandlerDelegate: class {
  func treatmentHistoryHandlerWillStart(_ handler: TreatmentHistoryHandler, action: TreatmentHistoryAction)
  func treatmentHistoryHandlerDidFail(_ handler: TreatmentHistoryHandler, action: TreatmentHistoryAction, error: Error?)
  func treatmentHistoryHandlerSuccessful(_ handler: TreatmentHistoryHandler, action: TreatmentHistoryAction,
                                  response: JSON)
}

class TreatmentHistoryHandler: TreatmentHistoryHandlerProtocol {
  weak var delegate: TreatmentHistoryHandlerDelegate?
  
  fileprivate lazy var networkRequest: PorcelainNetworkRequest = {
    let request = PorcelainNetworkRequest()
    request.delegate = self
    return request
  }()
  
  func getTreatmentHistory() {
    let userId = AppUserDefaults.customer?.id ?? ""
    self.networkRequest.getTreatmentHistory(userId)
  }
}

extension TreatmentHistoryHandler: PorcelainNetworkRequestDelegateProtocol {
  func requestWillStart(_ dataSource: PorcelainNetworkRequest,
                        action: PorcelainNetworkRequestAction) {
    self.delegate?.treatmentHistoryHandlerWillStart(self, action: .getTreatmentHistory)
  }
  
  func requestDidFail(_ dataSource: PorcelainNetworkRequest,
                      action: PorcelainNetworkRequestAction,
                      error: Error?, statusCode: Int?,
                      errorMessage: String?) {
    print("Failed: ", error ?? "")
    print(statusCode.debugDescription)
    guard let action = action as? TreatmentHistoryRequestAction else { return }
    switch action {
    case .getTreatmentHistory:
      self.delegate?.treatmentHistoryHandlerDidFail(self, action: .getTreatmentHistory, error: error)
    }
  }
  
  func requestSuccessful(_ dataSource: PorcelainNetworkRequest,
                         action: PorcelainNetworkRequestAction, result: Any?) {
    guard let action = action as? TreatmentHistoryRequestAction else { return }
    
    switch action {
    case .getTreatmentHistory:
      let json = JSON(result ?? "")
      self.delegate?.treatmentHistoryHandlerSuccessful(self, action: .getTreatmentHistory, response: json)
    }
  }
}
