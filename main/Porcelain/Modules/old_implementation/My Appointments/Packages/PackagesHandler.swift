//
//  PackagesHandler.swift
//  Porcelain
//
//  Created by Jean on 7/3/18.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import SwiftyJSON

enum PackagesAction {
  case getExistingPackages
}

protocol PackagesHandlerProtocol: class {
  var delegate: PackagesHandlerDelegate? { get }
}

protocol PackagesHandlerDelegate: class {
  func packagesHandlerWillStart(_ handler: PackagesHandler,action: PackagesAction)
  func packagesHandlerDidFail(_ handler: PackagesHandler,action: PackagesAction, error: Error?)
  func packagesHandlerSuccessful(_ handler: PackagesHandler, action: PackagesAction, response: JSON)
}

class PackagesHandler: PackagesHandlerProtocol {
  weak var delegate: PackagesHandlerDelegate?
  
  fileprivate lazy var networkRequest: PorcelainNetworkRequest = {
    let request = PorcelainNetworkRequest()
    request.delegate = self
    return request
  }()
  
  func getExistingPackages() {
    guard let userId = AppUserDefaults.customer?.id
      else { fatalError("No user session") }
    self.networkRequest.getExsitingPackages(userId)
  }
}

extension PackagesHandler: PorcelainNetworkRequestDelegateProtocol {
  func requestWillStart(_ dataSource: PorcelainNetworkRequest,
                        action: PorcelainNetworkRequestAction) {
    self.delegate?.packagesHandlerWillStart(self, action: .getExistingPackages)
  }
  
  func requestDidFail(_ dataSource: PorcelainNetworkRequest,
                      action: PorcelainNetworkRequestAction,
                      error: Error?, statusCode: Int?,
                      errorMessage: String?) {
    print("Failed: ", error ?? "")
    print(statusCode.debugDescription)
    guard let action = action as? PackagesRequestAction else { return }
    switch action {
    case .getExistingPackages:
      self.delegate?.packagesHandlerDidFail(self, action: .getExistingPackages, error: error)
    }
  }
  
  func requestSuccessful(_ dataSource: PorcelainNetworkRequest,
                         action: PorcelainNetworkRequestAction,
                         result: Any?) {
    guard let action = action as? PackagesRequestAction else { return }
    
    switch action {
    case .getExistingPackages:
      let result = JSON(result ?? "")
      self.delegate?.packagesHandlerSuccessful(self, action: .getExistingPackages, response: result)
    }
  }
}
