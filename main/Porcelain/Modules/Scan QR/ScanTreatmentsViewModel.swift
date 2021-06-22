//
//  ScanTreatmentsViewModel.swift
//  Porcelain
//
//  Created by Justine Rangel on 07/01/2019.
//  Copyright © 2019 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct ScanTreatment {
  public var id: String
  public var name: String
  public var startDate: String
  public var endDate: String
  public var benefits: [String]
  public var afterCare: [String]
  public var promotions: [MirrorPromotion]
  
  init(data: JSON) {
    id = data[PorcelainAPIConstant.Key.id].stringValue
    name = data[PorcelainAPIConstant.Key.name].stringValue
    startDate = data[PorcelainAPIConstant.Key.timeStart].stringValue
    endDate = data[PorcelainAPIConstant.Key.timeEnd].stringValue
    let treatment = data["treatment"]
    benefits = treatment[PorcelainAPIConstant.Key.benefits].arrayValue.compactMap({ $0.string })
    afterCare = treatment[PorcelainAPIConstant.Key.afterCare].arrayValue.compactMap({ $0.string?.clean() })
    promotions = []
  }
  
  public func toData() -> [String: Any] {
    let promotionsData = promotions.map({ ["title": $0.title, "description": $0.description] })
    return [
      "treatment": [
        "name": name,
        "benefits": benefits,
        "afterCare": afterCare],
      "promotions": promotionsData]
  }
}

public struct MirrorPromotion {
  public var id: String
  public var title: String
  public var description: String
  public var createdDateTime: String
  
  init(json: JSON) {
    id = json[PorcelainAPIConstant.Key.promoID].stringValue
    title = json[PorcelainAPIConstant.Key.title].stringValue
    description = json[PorcelainAPIConstant.Key.description].stringValue
    createdDateTime = json[PorcelainAPIConstant.Key.createdDateTime].stringValue
  }
}

public protocol ScanTreatmentView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func showError(message: String?)
}

public protocol ScanTreatmentViewModelProtocol: class {
  var resultTreatments: [ScanTreatment] { get set }
  var promotions: [MirrorPromotion] { get set }
  
  func attachView(_ view: ScanTreatmentView)
  func initialize()
}

extension ScanTreatmentViewModelProtocol {
  fileprivate func generateResultTreatments() {
    var tempResultTreatments: [ScanTreatment] = []
    resultTreatments.forEach { (scanTreatment) in
      var newScanTreatment = scanTreatment
      newScanTreatment.promotions = promotions
      tempResultTreatments.append(newScanTreatment)
    }
    resultTreatments = tempResultTreatments
  }
}

public final class ScanTreatmentViewModel: ScanTreatmentViewModelProtocol {
  private weak var view: ScanTreatmentView?
  
  private lazy var networkRequest: PorcelainNetworkRequest = {
    let networkRequest = PorcelainNetworkRequest()
    networkRequest.delegate = self
    return networkRequest
  }()
  
  private lazy var dispatchGroup = DispatchGroup()

  public var resultTreatments: [ScanTreatment] = []
  public var promotions: [MirrorPromotion] = []
}

extension ScanTreatmentViewModel {
  public func attachView(_ view: ScanTreatmentView) {
    self.view = view
  }
  
  public func initialize() {
    view?.reload()
    guard let userID = AppUserDefaults.userID else { return }
    view?.showLoading()
    networkRequest.getMyAppointmentsToday(userID)
    networkRequest.getPromotions()
    dispatchGroup.notify(queue: .main) { [weak self] in
      guard let `self` = self else { return }
      self.generateResultTreatments()
      self.view?.hideLoading()
      self.view?.reload()
    }
  }
}

// MARK: - PorcelainNetworkRequestDelegateProtocol
extension ScanTreatmentViewModel: PorcelainNetworkRequestDelegateProtocol {
  internal func requestWillStart(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction) {
    if let myAppointmentsRequestAction = action as? MyAppointmentsRequestAction {
      switch myAppointmentsRequestAction {
      case .getAppointmentsToday:
        dispatchGroup.enter()
      default: break
      }
    } else if let mirrorRequestAction = action as? MirrorRequestAction {
      switch mirrorRequestAction {
      case .getPromotions:
        dispatchGroup.enter()
      default: break
      }
    }
  }
  
  internal func requestDidFail(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction, error: Error?, statusCode: Int?, errorMessage: String?) {
    if let myAppointmentsRequestAction = action as? MyAppointmentsRequestAction {
      switch myAppointmentsRequestAction {
      case .getAppointmentsToday:
        view?.showError(message: errorMessage)
        dispatchGroup.leave()
      default: break
      }
    } else if let mirrorRequestAction = action as? MirrorRequestAction {
      switch mirrorRequestAction {
      case .getPromotions:
        view?.showError(message: errorMessage)
        dispatchGroup.leave()
      default: break
      }
    }
  }
  
  internal func requestSuccessful(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction, result: Any?) {
    if let myAppointmentsRequestAction = action as? MyAppointmentsRequestAction {
      switch myAppointmentsRequestAction {
      case .getAppointmentsToday:
        parseUpcominngAppointments(result: result)
        dispatchGroup.leave()
      default: break
      }
    }  else if let mirrorRequestAction = action as? MirrorRequestAction {
      switch mirrorRequestAction {
      case .getPromotions:
        parsePromotions(result: result)
        dispatchGroup.leave()
      default: break
      }
    }
  }
}

extension ScanTreatmentViewModel {
  private func parseUpcominngAppointments(result: Any?) {
    guard let result = result else { return }
    let response = JSON(result)
    guard let responseData = response.array?[0].dictionary?["data"] else {
      view?.showError(message: "Parsing error")
      return
    }
    resultTreatments.removeAll()
    responseData.arrayValue.forEach { (data) in
      resultTreatments.append(ScanTreatment(data: data))
    }
  }
  
  private func parsePromotions(result: Any?) {
    guard let result = result else { return }
    let response = JSON(result)
    guard let responseData = response.array?[0].dictionary?["data"] else {
      view?.showError(message: "Parsing error")
      return
    }
    promotions = responseData.arrayValue.map({ MirrorPromotion(json: $0) })
  }
}
