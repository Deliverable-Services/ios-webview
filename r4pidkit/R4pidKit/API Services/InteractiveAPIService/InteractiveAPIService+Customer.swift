//
//  InteractiveAPIService+Customer.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 18/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation

private enum APIPath: APIPathProtocol {
  case dashboard
  case profile(customerID: String)
  case appointmentsToday(customerID: String)
  case register
  case search
  case skinQuiz(customerID: String)
  case contactLog(customerID: String)
  case contactLogAppointments(customerID: String)
  case contactLogCreate(customerID: String)
  case contactLogUpdate(customerID: String, contactLogID: String)
  case contactLogDelete(customerID: String, contactLogID: String)
  case contactLogHistory(customerID: String, contactLogID: String)
  case freshDeskTickets(customerID: String)
  case freshDeskTicket(customerID: String, ticketID: String)
  case treatmentLog(customerID: String)
  case treatmentLogCreate(customerID: String)
  case treatmentLogUpdate(customerID: String, treatmentLogID: String)
  case treatmentLogDelete(customerID: String, treatmentLogID: String)
  case treatmentLogHistory(customerID: String, treatmentLogID: String)
  case treatmentLogTreatmentSelection(customerID: String)
  case clientDataForm(customerID: String)
  case clientDataFormCreate(customerID: String)
  case clientDataFormUpdate(customerID: String)
  case clientDataFormHistory(customerID: String)
  case clientDataFormQuestions(customerID: String)
  case products(customerID: String)
  case purchases(customerID: String)
  case appointments(customerID: String)
  case treatments(customerID: String)
  case skinProfile(customerID: String)
  case note(customerID: String, noteID: String?)
  case noteHistory(customerID: String, noteID: String)
  case notes(customerID: String)
  case uploadAvatar(customerID: String)
  case lifeStyles(customerID: String)
  case lifeStyle(customerID: String, lifeStypeID: String?)
  
  var rawValue: String {
    switch self {
    case .dashboard:
      return "/customer"
    case .profile(let customerID):
      return "/customer/\(customerID)/profile"
    case .appointmentsToday(let customerID):
      return "/customer/\(customerID)/appointments/today"
    case .register:
      return "/customer/register"
    case .search:
      return "/customer/search"
    case .skinQuiz(let customerID):
      return "/customer/\(customerID)/skin_quiz/UWWTY3LT/compute"
    case .contactLog(let customerID):
      return "/customer/\(customerID)/contact_logs"
    case .contactLogAppointments(let customerID):
      return "/customer/\(customerID)/contact_logs/appointments"
    case .contactLogCreate(let customerID):
      return "/customer/\(customerID)/contact_log"
    case .contactLogUpdate(let customerID, let contactLogID):
      return "/customer/\(customerID)/contact_log/\(contactLogID)"
    case .contactLogDelete(let customerID, let contactLogID):
      return "/customer/\(customerID)/contact_log/\(contactLogID)"
    case .contactLogHistory(let customerID, let contactLogID):
      return "/customer/\(customerID)/contact_log/\(contactLogID)/history"
    case .freshDeskTickets(let customerID):
      return "/customer/\(customerID)/freshdesk/tickets"
    case .freshDeskTicket(let customerID, let ticketID):
      return "/customer/\(customerID)/freshdesk/ticket/\(ticketID)"
    case .treatmentLog(let customerID):
      return "/customer/\(customerID)/treatment_logs"
    case .treatmentLogCreate(let customerID):
      return "/customer/\(customerID)/treatment_log"
    case .treatmentLogUpdate(let customerID, let treatmentLogID):
      return "/customer/\(customerID)/treatment_log/\(treatmentLogID)"
    case .treatmentLogDelete(let customerID, let treatmentLogID):
      return "/customer/\(customerID)/treatment_log/\(treatmentLogID)"
    case .treatmentLogHistory(let customerID, let treatmentLogID):
      return "/customer/\(customerID)/treatment_log/\(treatmentLogID)"
    case .treatmentLogTreatmentSelection(let customerID):
      return "/customer/\(customerID)/treatment_log/items_selection"
    case .clientDataForm(let customerID):
      return "/customer/\(customerID)/client_data_form"
    case .clientDataFormCreate(let customerID):
      return "/customer/\(customerID)/client_data_form"
    case .clientDataFormUpdate(let customerID):
      return "/customer/\(customerID)/client_data_form/update"
    case .clientDataFormHistory(let customerID):
      return "/customer/\(customerID)/client_data_form/history"
    case .clientDataFormQuestions(let customerID):
      return "/customer/\(customerID)/client_data_form/questions"
    case .products(let customerID):
      return "/customer/\(customerID)/products"
    case .purchases(let customerID):
      return "/customer/\(customerID)/purchases"
    case .appointments(let customerID):
      return "/customer/\(customerID)/appointments"
    case .treatments(let customerID):
      return "/customer/\(customerID)/treatments"
    case .skinProfile(let customerID):
      return "/customer/\(customerID)/skin_profile"
    case .note(let customerID, let noteID):
      if let noteID = noteID {
        return "/customer/\(customerID)/note/\(noteID)"
      } else {
        return "/customer/\(customerID)/note"
      }
    case .noteHistory(let customerID, let noteID):
      return "/customer/\(customerID)/note/\(noteID)/history"
    case .notes(let customerID):
      return "/customer/\(customerID)/notes"
    case .uploadAvatar(let customerID):
      return "/customer/\(customerID)/avatar"
    case .lifeStyles(let customerID):
      return "/customer/\(customerID)/lifestyle"
    case .lifeStyle(let customerID, let lifeStypeID):
      if let lifeStypeID = lifeStypeID {
        return "/customer/\(customerID)/lifestyle/\(lifeStypeID)"
      } else {
        return "/customer/\(customerID)/lifestyle"
      }
    }
  }
}

extension InteractiveAPIService.Customer {
  public static func getDashboardCustomers() -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.dashboard
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getCustomerProfile(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.profile(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getAppointmentsToday(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.appointmentsToday(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func registerCustomer(requestBody: [APIServiceConstant.Key: Any]) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.register
    service.method = .post
    service.requestBody = InteractiveAPIService.createRequestBody(requestBody)
    service.debugName = #function
    return service
  }
  
  public static func updateCustomer(customerID: String, requestBody: [APIServiceConstant.Key: Any]) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.profile(customerID: customerID)
    service.method = .patch
    service.requestBody = InteractiveAPIService.createRequestBody(requestBody)
    service.debugName = #function
    return service
  }
  
  public static func searchCustomers(page: Int, query: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.search
    service.method = .get
    service.queryParameters = [
      URLQueryItem(key: .page, value: "\(page)"),
      URLQueryItem(key: .q, value: query)]
    service.debugName = #function
    return service
  }
  
  public static func getSkinQuiz(customerID: String)  -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.skinQuiz(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getContactLogs(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.contactLog(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getContactLogAppointments(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.contactLogAppointments(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func createContactLog(customerID: String, request: [APIServiceConstant.Key: Any]) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.contactLogCreate(customerID: customerID)
    service.method = .post
    service.requestBody = InteractiveAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func updateContactLog(customerID: String, contactLogID: String, request: [APIServiceConstant.Key: Any]) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.contactLogUpdate(customerID: customerID, contactLogID: contactLogID)
    service.method = .patch
    service.requestBody = InteractiveAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
    public static func deleteContactLog(customerID: String, contactLogID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.contactLogDelete(customerID: customerID, contactLogID: contactLogID)
    service.method = .delete
    service.debugName = #function
    return service
  }
  
  public static func getContactLogHistory(customerID: String, contactLogID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.contactLogHistory(customerID: customerID, contactLogID: contactLogID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getFreshdeskTickets(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.freshDeskTickets(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getFreshdeskTicket(customerID: String, ticketID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.freshDeskTicket(customerID: customerID, ticketID: ticketID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func updateFreshdeskTicket(customerID: String, ticketID: String, request: [APIServiceConstant.Key: Any]) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.freshDeskTicket(customerID: customerID, ticketID: ticketID)
    service.method = .patch
    service.requestBody = InteractiveAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func getTreatmentLogs(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.treatmentLog(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func createTreatmentLog(customerID: String, request: [APIServiceConstant.Key: Any]) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.treatmentLogCreate(customerID: customerID)
    service.method = .post
    service.requestBody = InteractiveAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func updateTreatmentLog(customerID: String, treatmentLogID: String, request: [APIServiceConstant.Key: Any]) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.treatmentLogUpdate(customerID: customerID, treatmentLogID: treatmentLogID)
    service.method = .patch
    service.requestBody = InteractiveAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func deleteTreatmentLog(customerID: String, treatmentLogID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.treatmentLogDelete(customerID: customerID, treatmentLogID: treatmentLogID)
    service.method = .delete
    service.debugName = #function
    return service
  }
  
  public static func getTreatmentLogHistory(customerID: String, treatmentLogID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.treatmentLogHistory(customerID: customerID, treatmentLogID: treatmentLogID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getTreatmentLogTreatmentSelection(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.treatmentLogTreatmentSelection(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getClientDataForm(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.clientDataForm(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func createClientDataForm(customerID: String, requestBody: Any) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.clientDataFormCreate(customerID: customerID)
    service.method = .post
    service.requestBody = requestBody
    service.debugName = #function
    return service
  }
  
  public static func updateClientDataForm(customerID: String, requestBody: Any) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.clientDataFormUpdate(customerID: customerID)
    service.method = .patch
    service.requestBody = requestBody
    service.debugName = #function
    return service
  }
  
  public static func getClientDataFormHistory(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.clientDataFormHistory(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getClientDataFormQuestions(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.clientDataFormQuestions(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getCustomerProducts(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.products(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getCustomerPurchases(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.purchases(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getCustomerAppointments(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.appointments(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getCustomerTreatments(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.treatments(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getCustomerSkinProfile(customerID: String) ->  InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.skinProfile(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func createCustomerNote(customerID: String, requestBody: [APIServiceConstant.Key: Any]) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.note(customerID: customerID, noteID: nil)
    service.method = .post
    service.requestBody = InteractiveAPIService.createRequestBody(requestBody)
    service.debugName = #function
    return service
  }
  
  public static func updateCustomerNote(customerID: String, noteID: String, requestBody: [APIServiceConstant.Key: Any]) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.note(customerID: customerID, noteID: noteID)
    service.method = .patch
    service.requestBody = InteractiveAPIService.createRequestBody(requestBody)
    service.debugName = #function
    return service
  }
  
  public static func deleteCustomerNote(customerID: String, noteID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.note(customerID: customerID, noteID: noteID)
    service.method = .delete
    service.debugName = #function
    return service
  }
  
  public static func getNoteHistory(customerID: String, noteID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.noteHistory(customerID: customerID, noteID: noteID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getCustomerNotes(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.notes(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func uploadAvatar(customerID: String, uploadPart: UploadPart) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.uploadAvatar(customerID: customerID)
    service.method = .post
    service.requestBody = PPAPIService.createFileRequestBody([
      .image: uploadPart])
    service.debugName = #function
    return service
  }
  
  public static func getCustomerLifeStyles(customerID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.lifeStyles(customerID: customerID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func updateOrCreateCustomerLifeStyles(customerID: String, requestBody: [APIServiceConstant.Key: Any]) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.lifeStyle(customerID: customerID, lifeStypeID: nil)
    service.method = .put
    service.requestBody = InteractiveAPIService.createRequestBody(requestBody)
    service.debugName = #function
    return service
  }
  
  public static func deleteCustomerLifeStyle(customerID: String, lifeStyleID: String) -> InteractiveAPIService {
    var service = InteractiveAPIService()
    service.path = APIPath.lifeStyle(customerID: customerID, lifeStypeID: nil)
    service.method = .delete
    service.debugName = #function
    return service
  }
}
