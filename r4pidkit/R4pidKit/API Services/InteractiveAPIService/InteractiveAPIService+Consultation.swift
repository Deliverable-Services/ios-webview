//
//  InteractiveAPIService+Consultation.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 09/10/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation

private enum APIPath: APIPathProtocol {
  case skinAnalysis(customerID: String)
  case skinAnalysisAreas
  case skinAnalysisConcerns
  case skinAnalysisSources
  case skinAnalysisSkinTypes
  case skinAnalysisCreate(customerID: String)
  case skinAnalysisUpdate(customerID: String, analysisID: String)
  case skinAnalysisDelete(customerID: String, analysisID: String)
  case skinAnalysisHistory(customerID: String, analysisID: String)
  case treatmentPlan(customerID: String)
  case treatmentPlanCreate(customerID: String)
  case treatmentPlanUpdate(customerID: String)
  case treatmentPlanHistory(customerID: String)
  case treatmentPlanDuration
  case treatmentPlanTemplates
  case productPrescription(customerID: String)
  case productPrescriptionCreate(customerID: String)
  case productPrescriptionUpdate(customerID: String, prescriptionID: String)
  case productPrescriptionHistory(customerID: String)
  case productPrescriptionTemplates
  case appointmentsPending(customerID: String)
  case appointmentsUpcoming(customerID: String)
  case appointmentsPast(customerID: String)
  case confirmAppointment(customerID: String, appointmentID: String)
  case cancelAppointment(customerID: String, appointmentID: String)
  case approveAppointment(customerID: String, appointmentID: String)
  case rejectAppointment(customerID: String, appointmentID: String)
  case noShowAppointment(customerID: String, appointmentID: String)
  case treatmentPurchases(customerID: String)
  case accountSessionTreatments(customerID: String)
  case productPurchases(customerID: String)
  
  var rawValue: String {
    switch self {
    case .skinAnalysis(let customerID):
      return "/customer/\(customerID)/skin_analysis"
    case .skinAnalysisAreas:
      return "/skin_analysis/area/selection"
    case .skinAnalysisConcerns:
      return "/skin_analysis/concern/selection"
    case .skinAnalysisSources:
      return "/skin_analysis/source/selection"
    case .skinAnalysisSkinTypes:
      return "/skin_analysis/skin_type/selection"
    case .skinAnalysisCreate(let customerID):
      return "/customer/\(customerID)/skin_analysis/create"
    case .skinAnalysisUpdate(let customerID, let analysisID):
      return "/customer/\(customerID)/skin_analysis/\(analysisID)/update"
    case .skinAnalysisDelete(let customerID, let analysisID):
      return "/customer/\(customerID)/skin_analysis/\(analysisID)/delete"
    case .skinAnalysisHistory(let customerID, let analysisID):
      return "/customer/\(customerID)/skin_analysis/\(analysisID)/history"
    case .treatmentPlan(let customerID):
      return "/customer/\(customerID)/treatment_plan"
    case .treatmentPlanCreate(let customerID):
      return "/customer/\(customerID)/treatment_plan/create"
    case .treatmentPlanUpdate(let customerID):
      return "/customer/\(customerID)/treatment_plan/update"
    case .treatmentPlanHistory(let customerID):
      return "/customer/\(customerID)/treatment_plan/history"
    case .treatmentPlanDuration:
      return "/treatment_plan/compute_duration"
    case .treatmentPlanTemplates:
      return "/treatment_plan/templates"
    case .productPrescription(let customerID):
      return "/customer/\(customerID)/prescriptions"
    case .productPrescriptionCreate(let customerID):
      return "/customer/\(customerID)/prescription"
    case .productPrescriptionUpdate(let customerID, let prescriptionID):
      return "/customer/\(customerID)/prescription/\(prescriptionID)"
    case .productPrescriptionHistory(let customerID):
      return "/customer/\(customerID)/prescription/history"
    case .productPrescriptionTemplates:
      return "/prescription/templates"
    case .appointmentsPending(let customerID):
      return "/customer/\(customerID)/appointments/pending"
    case .appointmentsUpcoming(let customerID):
      return "/customer/\(customerID)/appointments/upcoming"
    case .appointmentsPast(let customerID):
      return "/customer/\(customerID)/appointments/past"
    case .confirmAppointment(let customerID, let appointmentID):
      return "/customer/\(customerID)/appointment/\(appointmentID)/confirm"
    case .cancelAppointment(let customerID, let appointmentID):
      return "/customer/\(customerID)/appointment/\(appointmentID)/cancel"
    case .approveAppointment(let customerID, let appointmentID):
      return "/customer/\(customerID)/appointment/\(appointmentID)/approve"
    case .rejectAppointment(let customerID, let appointmentID):
      return "/customer/\(customerID)/appointment/\(appointmentID)/reject"
    case .noShowAppointment(let customerID, let appointmentID):
      return "/customer/\(customerID)/appointment/\(appointmentID)/noshow"
    case .treatmentPurchases(let customerID):
      return "/customer/\(customerID)/packages"
    case .accountSessionTreatments(let customerID):
      return "/customer/\(customerID)/account/session/treatments"
    case .productPurchases(let customerID):
      return "/customer/\(customerID)/purchases"
    }
  }
}

extension InteractiveAPIService.Consultation {
  public static func getSkinAnalysis(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.skinAnalysis(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getSkinAnalysisAreas() -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.skinAnalysisAreas
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getSkinAnalysisConcerns() -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.skinAnalysisConcerns
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getSkinAnalysisSources() -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.skinAnalysisSources
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getSkinAnalysisSkinTypes() -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.skinAnalysisSkinTypes
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func createSkinAnalysis(customerID: String, fileRequest: [APIServiceConstant.Key: Any]) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.skinAnalysisCreate(customerID: customerID)
    service.method = .post
    service.requestBody = InteractiveAPIService.createFileRequestBody(fileRequest)
    service.debugName = #function
    return service
  }
  
  public static func updateSkinAnalysis(customerID: String, analysisID: String, fileRequest: [APIServiceConstant.Key: Any]) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.skinAnalysisUpdate(customerID: customerID, analysisID: analysisID)
    service.method = .post
    service.requestBody = InteractiveAPIService.createFileRequestBody(fileRequest)
    service.debugName = #function
    return service
  }
  
  public static func deleteSkinAnalysis(customerID: String, analysisID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.skinAnalysisDelete(customerID: customerID, analysisID: analysisID)
    service.method = .delete
    service.debugName = #function
    return service
  }
  
  public static func getSkinAnalysisHistory(customerID: String, analysisID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.skinAnalysisHistory(customerID: customerID, analysisID: analysisID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getTreatmentPlan(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.treatmentPlan(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func createTreatmentPlan(customerID: String, request: [APIServiceConstant.Key: Any]) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.treatmentPlanCreate(customerID: customerID)
    service.method = .post
    service.requestBody = InteractiveAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func updateTreatmentPlan(customerID: String, request: [APIServiceConstant.Key: Any]) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.treatmentPlanUpdate(customerID: customerID)
    service.method = .patch
    service.requestBody = InteractiveAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func getTreatmentPlanHistory(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.treatmentPlanHistory(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getTreatmentPlanDuration(request: [APIServiceConstant.Key: Any]) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.treatmentPlanDuration
    service.method = .post
    service.requestBody = InteractiveAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func getTreatmentPlanTemplates() -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.treatmentPlanTemplates
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getProductPrescription(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.productPrescription(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func createProductPrescription(customerID: String, request: [APIServiceConstant.Key: Any]) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.productPrescriptionCreate(customerID: customerID)
    service.method = .post
    service.requestBody = InteractiveAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func updateProductPrescription(customerID: String, prescriptionID: String, request: [APIServiceConstant.Key: Any]) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.productPrescriptionUpdate(customerID: customerID, prescriptionID: prescriptionID)
    service.method = .patch
    service.requestBody = InteractiveAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func getProductPrescriptionHistory(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.productPrescriptionHistory(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getProductPrescriptionTemplates() -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.productPrescriptionTemplates
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getAppointmentsPending(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.appointmentsPending(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getAppointmentsUpcoming(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.appointmentsUpcoming(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getAppointmentsPast(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.appointmentsPast(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func confirmAppointment(customerID: String, appointmentID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.confirmAppointment(customerID: customerID, appointmentID: appointmentID)
    service.method = .post
    service.debugName = #function
    return service
  }
  
  public static func cancelAppointment(customerID: String, appointmentID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.cancelAppointment(customerID: customerID, appointmentID: appointmentID)
    service.method = .post
    service.debugName = #function
    return service
  }
  
  public static func approveAppointment(customerID: String, appointmentID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.approveAppointment(customerID: customerID, appointmentID: appointmentID)
    service.method = .post
    service.debugName = #function
    return service
  }
  
  public static func rejectAppointment(customerID: String, appointmentID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.rejectAppointment(customerID: customerID, appointmentID: appointmentID)
    service.method = .post
    service.debugName = #function
    return service
  }
  
  public static func noShowAppointment(customerID: String, appointmentID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.noShowAppointment(customerID: customerID, appointmentID: appointmentID)
    service.method = .post
    service.debugName = #function
    return service
  }
  
  public static func getTreatmentPurchases(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.treatmentPurchases(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getAccountSessionTreatments(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.accountSessionTreatments(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getProductPurchases(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.productPurchases(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
}
