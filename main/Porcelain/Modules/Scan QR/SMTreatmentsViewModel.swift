//
//  SMTreatmentsViewModel.swift
//  Porcelain
//
//  Created by Justine Rangel on 07/01/2019.
//  Copyright © 2019 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import R4pidKit
import SwiftyJSON

public struct SMTreatmentData {
  public var appointmentID: String
  public var name: String?
  public var benefits: [String]?
  public var afterCare: [String]?
  
  public init?(data: JSON) {
    guard let appointmentID = data.appointmentID.string else { return nil }
    guard data.treatment.id.numberString != nil else { return nil }
    self.appointmentID = appointmentID
    name = data.treatment.name.string
    benefits = data.treatment.benefits.array?.compactMap({ $0.string })
    afterCare = data.treatment.afterCare.array?.compactMap({ $0.string })
  }
}

public protocol ScanTreatmentView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func showError(message: String?)
}

public protocol ScanTreatmentViewModelProtocol: class {
  var selectedAppointmentID: String? { get set }
  var treatments: [SMTreatmentData] { get }
  var beautyTips: BeautyTipsData? { get set }
  
  func attachView(_ view: ScanTreatmentView)
  func initialize()
}

public final class ScanTreatmentViewModel: ScanTreatmentViewModelProtocol {
  private weak var view: ScanTreatmentView?
  
  public var selectedAppointmentID: String?
  public var treatments: [SMTreatmentData] = []
  public var beautyTips: BeautyTipsData?
}

extension ScanTreatmentViewModel {
  public func attachView(_ view: ScanTreatmentView) {
    self.view = view
  }
  
  public func initialize() {
    view?.showLoading()
    PPAPIService.User.getMyAppointmentsToday().call { (response) in
      switch response {
      case .success(let result):
        self.treatments = result.data.arrayValue.compactMap({ SMTreatmentData(data: $0) })
        self.view?.hideLoading()
        self.view?.reload()
      case .failure(let error):
        self.view?.hideLoading()
        self.view?.showError(message: error.localizedDescription)
      }
    }
  }
}
