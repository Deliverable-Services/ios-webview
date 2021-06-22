//
//  SelectTreatmentViewModel.swift
//  Porcelain
//
//  Created by Justine Rangel on 11/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation

public struct TreatmentModel {
  public var id: String
  public var title: String
  
  init(treatment: Treatment) {
    id = treatment.id!
    title = treatment.name!
  }
}

public protocol SelectTreatmentView: class {
  func didSelectTreatment(_ treatment: TreatmentModel)
  func reload()
}

public protocol SelectTreatmentCategoryViewModelProtocol {
  var title: String? { get }
  var treatments: [TreatmentModel] { get }
  
  func treatmentTapped(treatment: TreatmentModel)
}

public class SelectTreatmentCategoryViewModel: SelectTreatmentCategoryViewModelProtocol {
  init(title: String? = nil, treatments: [TreatmentModel]) {
    self.title = title
    self.treatments = treatments
  }
  
  public var treatmentTapped: ((TreatmentModel) -> ())?
  
  public var title: String?
  
  public var treatments: [TreatmentModel]
}

extension SelectTreatmentCategoryViewModel {
  public func treatmentTapped(treatment: TreatmentModel) {
    treatmentTapped?(treatment)
  }
}

public protocol SelectTreatmentViewModelProtocol {
  var treatmentCategories: [SelectTreatmentCategoryViewModel] { get }
  
  func attachView(_ view: SelectTreatmentView)
}

extension SelectTreatmentViewModelProtocol where Self: SelectTreatmentViewModel {
  public func addlistener() {
    guard self.view != nil else { return }
    for treatmentCategory in treatmentCategories {
      treatmentCategory.treatmentTapped = { [weak self] treatment in
        guard let `self` = self else { return }
        self.view?.didSelectTreatment(treatment)
      }
    }
  }
}

public class SelectTreatmentViewModel: SelectTreatmentViewModelProtocol {
  fileprivate weak var view: SelectTreatmentView?
  
  init(treatmentCategories: [SelectTreatmentCategoryViewModel]) {
    self.treatmentCategories = treatmentCategories
    
    addlistener()
  }
  
  public var treatmentCategories: [SelectTreatmentCategoryViewModel]
}

extension SelectTreatmentViewModel {
  public func attachView(_ view: SelectTreatmentView) {
    self.view = view
    
    addlistener()
  }
}
