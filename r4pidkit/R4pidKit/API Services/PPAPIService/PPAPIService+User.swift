//
//  PPAPIService+User.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 28/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation

private enum APIPath: APIPathProtocol {
  case profile
  case myAvatar
  case myCredential
  case myProducts
  case myProductReview(productID: String)
  case myProductRemove(productID: String)
  case myProductConsume(productID: String)
  case myTreatments
  case myAppointments
  case myAppointmentsPast
  case myAppointmentsUpcoming
  case myAppointmentsPending
  case myAppointmentsToday
  case myAppointmentNote(appointmentID: String, noteID: String?)
  case myAppointmentCancel(appointmentID: String)
  case myAppointmentConfirm(appointmentID: String)
  case myAppointmentFeedback(appointmentID: String)
  case myAppointmentFeedbackUpdate(appointmentID: String)
  case myNotifications
  case myNotificationRead(notificationID: String)
  case myPackages
  case myPrescriptions
  case myTreatmentPlan
  case myPurchases
  case myPurchaseDetails(wcOrderID: String)
  case myPurchaseFeedback(wcOrderID: String)
  case myPurchasesWithDate(_ date: String)
  case myPurchasesDateGrouped
  case mySkinQuiz
  case mySkinQuizAnswers
  case mySkinQuizCompute
  case mySkinQuizEmailResult
  case mySkinAnalysis
  case mySkinAnalysisStatistics
  case mySkinAnalysisAreaSelection
  case mySkinType
  case mySkinLogs
  case mySkinLogAreas
  case mySkinLogConditions
  case mySkinLogCreate
  case mySkinLogUpdate(skinLogID: String)
  case mySkinLogDelete(skinLogID: String)
  case mySocialLink
  case mySocialUnlink
  case myShippingAddresses
  case myShippingAddressCreate
  case myShippingAddressUpdate(shippingID: String)
  case myShippingAsDefault(shippingID: String)
  case myShippingAddressDelete(shippingID: String)
  case myStripeCards
  case myStripeCardCreate
  case myStripeCardUpdate(cardID: String)
  case myStripeCardAsDefault(cardID: String)
  case myStripeCardDelete(cardID: String)
  case myFCMToken(_ token: String)
  
  var rawValue: String {
    switch self {
    case .profile:
      return "/me"
    case .myAvatar:
      return "/me/avatar"
    case .myCredential:
      return "/me/credential"
    case .myProducts:
      return "/me/products"
    case .myProductReview(let productID):
      return "/me/product/\(productID)/review"
    case .myProductRemove(let productID):
      return "/me/product/\(productID)/remove"
    case .myProductConsume(let productID):
      return "/me/product/\(productID)/consume"
    case .myTreatments:
      return "/me/treatments"
    case .myAppointments:
      return "/me/appointments"
    case .myAppointmentsPast:
      return "/me/appointments/past"
    case .myAppointmentsUpcoming:
      return "/me/appointments/upcoming"
    case .myAppointmentsPending:
      return "/me/appointments/pending"
    case .myAppointmentsToday:
      return "/me/appointments/today"
    case .myAppointmentNote(let appointmentID, let noteID):
      if let noteID = noteID {
        return "/me/appointment/\(appointmentID)/note/\(noteID)"
      } else {
        return "/me/appointment/\(appointmentID)/note"
      }
    case .myAppointmentCancel(let appointmentID):
      return "/me/appointment/\(appointmentID)/cancel"
    case .myAppointmentConfirm(let appointmentID):
      return "/me/appointment/\(appointmentID)/confirm"
    case .myAppointmentFeedback(let appointmentID):
      return "/me/appointment/\(appointmentID)/feedback"
    case .myAppointmentFeedbackUpdate(let appointmentID):
      return "/me/appointment/\(appointmentID)/feedback/update"
    case .myNotifications:
      return "/me/notifications"
    case .myNotificationRead(let notificationID):
      return "/me/notification/\(notificationID)/read"
    case .myPackages:
      return "/me/packages"
    case .myPrescriptions:
      return "/me/prescriptions"
    case .myTreatmentPlan:
      return "/me/treatmentplan_new"
    case .myPurchases:
      return "/me/purchases"
    case .myPurchaseDetails(let wcOrderID):
      return "/me/purchases/\(wcOrderID)/details"
    case .myPurchaseFeedback(let wcOrderID):
      return "/me/purchases/\(wcOrderID)/feedback"
    case .myPurchasesWithDate(let date):
      return "/me/purchases/\(date)"
    case .myPurchasesDateGrouped:
      return "/me/purchasesByDate"
    case .mySkinQuiz:
      return "/me/skin_quiz/UWWTY3LT"
    case .mySkinQuizAnswers:
      return "/me/skin_quiz/UWWTY3LT/answers"
    case .mySkinQuizCompute:
      return "/me/skin_quiz/UWWTY3LT/compute"
    case .mySkinQuizEmailResult:
      return "/me/skin_quiz/mail_result"
    case .mySkinAnalysis:
      return "/me/skin_analysis"
    case .mySkinAnalysisStatistics:
      return "/me/skin_analysis/statistics"
    case .mySkinAnalysisAreaSelection:
      return "/skin_analysis/area/selection"
    case .mySkinType:
      return "/me/skin_type"
    case .mySkinLogs:
      return "/me/skin_logs"
    case .mySkinLogAreas:
      return "/me/skin_log/area/selections"
    case .mySkinLogConditions:
      return "/me/skin_log/condition/selections"
    case .mySkinLogCreate:
      return "/me/skin_log/create"
    case .mySkinLogUpdate(let skinLogID):
      return "/me/skin_log/\(skinLogID)/update"
    case .mySkinLogDelete(let skinLogID):
      return "/me/skin_log/\(skinLogID)/delete"
    case .mySocialLink:
      return "/me/social/link"
    case .mySocialUnlink:
      return "/me/social/unlink"
    case .myShippingAddresses:
      return "/me/shipping/addresses"
    case .myShippingAddressCreate:
      return "/me/shipping/address"
    case .myShippingAddressUpdate(let shippingID):
      return "/me/shipping/address/\(shippingID)"
    case .myShippingAsDefault(let shippingID):
      return "/me/shipping/address/\(shippingID)/default"
    case .myShippingAddressDelete(let shippingID):
      return "/me/shipping/address/\(shippingID)"
    case .myStripeCards:
      return "/me/cards"
    case .myStripeCardCreate:
      return "/me/card/create"
    case .myStripeCardUpdate(let cardID):
      return "/me/card/\(cardID)/update"
    case .myStripeCardAsDefault(let cardID):
      return "/me/card/\(cardID)/default"
    case .myStripeCardDelete(let cardID):
      return "/me/card/\(cardID)/delete"
    case .myFCMToken(let token):
      return "/me/fcm/\(token)"
    }
  }
}

extension PPAPIService.User {
  public static func getProfile() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.profile
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func updateAvatar(uploadPart: UploadPart) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myAvatar
    service.method = .post
    service.requestBody = PPAPIService.createFileRequestBody([
      .image: uploadPart])
    service.debugName = #function
    return service
  }
  
  public static func createCredential(phone: String, password: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myCredential
    service.method = .post
    service.requestBody = PPAPIService.createRequestBody([
      .phone: phone,
      .password: password])
    service.debugName = #function
    return service
  }
  
  public static func updateProfile(request: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.profile
    service.method = .patch
    service.requestBody = PPAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func getMyProducts() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myProducts
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func createMyProductReview(productID: String, request: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myProductReview(productID: productID)
    service.method = .post
    service.requestBody = PPAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func removeMyProduct(productID: String, request: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myProductRemove(productID: productID)
    service.method = .post
    service.requestBody = PPAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func consumeMyProduct(productID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myProductConsume(productID: productID)
    service.method = .post
    service.debugName = #function
    return service
  }
  
  public static func getMyTreatments() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myTreatments
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getMyAppointments() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myAppointments
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getMyAppointmentsPast() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myAppointmentsPast
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getMyAppointmentsUpcoming() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myAppointmentsUpcoming
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getMyAppointmentsPending() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myAppointmentsPending
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getMyAppointmentsToday() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myAppointmentsToday
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func createMyAppointmentNote(appointmentID: String, notes: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myAppointmentNote(appointmentID: appointmentID, noteID: nil)
    service.method = .post
    service.requestBody = PPAPIService.createRequestBody([.note: notes])
    service.debugName = #function
    return service
  }
  
  public static func updateMyAppointmentNote(appointmentID: String, noteID: String, notes: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myAppointmentNote(appointmentID: appointmentID, noteID: noteID)
    service.method = .patch
    service.requestBody = PPAPIService.createRequestBody([.note: notes])
    service.debugName = #function
    return service
  }
  
  public static func getMyAppointmentNote(appointmentID: String, noteID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myAppointmentNote(appointmentID: appointmentID, noteID: noteID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func deleteMyAppointmentNote(appointmentID: String, noteID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myAppointmentNote(appointmentID: appointmentID, noteID: noteID)
    service.method = .delete
    service.debugName = #function
    return service
  }
  
  public static func cancelMyAppointment(appointmentID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myAppointmentCancel(appointmentID: appointmentID)
    service.method = .post
    service.debugName = #function
    return service
  }
  
  public static func confirmMyAppointment(appointmentID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myAppointmentConfirm(appointmentID: appointmentID)
    service.method = .post
    service.debugName = #function
    return service
  }
  
  public static func submitMyAppointmentFeedback(appointmentID: String, fileRequest: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myAppointmentFeedback(appointmentID: appointmentID)
    service.method = .post
    service.requestBody = PPAPIService.createFileRequestBody(fileRequest)
    service.debugName = #function
    return service
  }
  
  public static func updateMyAppointmentFeedback(appointmentID: String, fileRequest: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myAppointmentFeedbackUpdate(appointmentID: appointmentID)
    service.method = .post
    service.requestBody = PPAPIService.createFileRequestBody(fileRequest)
    service.debugName = #function
    return service
  }
  
  public static func getMyAppointmentFeedback(appointmentID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myAppointmentFeedback(appointmentID: appointmentID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getMyNotifications() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myNotifications
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func readMyNotification(notificationID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myNotificationRead(notificationID: notificationID)
    service.method = .post
    service.debugName = #function
    return service
  }
  
  public static func getMyPackages() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myPackages
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getMyPrescriptions() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myPrescriptions
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getMyTreatmentPlan() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myTreatmentPlan
    service.method = .get
    service.debugName = #function
    return service
  }
  
  //date yyyy-MM-dd
  public static func getPurchases(date: String? = nil) -> PPAPIService {
    var service = PPAPIService()
    if let date = date {
      service.path = APIPath.myPurchasesWithDate(date)
    } else {
      service.path = APIPath.myPurchases
    }
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getPurchaseDetails(wcOrderID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myPurchaseDetails(wcOrderID: wcOrderID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func submitMyPurchaseFeedback(wcOrderID: String, fileRequest: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myPurchaseFeedback(wcOrderID: wcOrderID)
    service.method = .post
    service.requestBody = PPAPIService.createFileRequestBody(fileRequest)
    service.debugName = #function
    return service
  }
  
  public static func updateMyPurchaseFeedback(wcOrderID: String, fileRequest: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myPurchaseFeedback(wcOrderID: wcOrderID)
    service.method = .post
    service.requestBody = PPAPIService.createFileRequestBody(fileRequest)
    service.debugName = #function
    return service
  }
  
  public static func getMyPurchaseFeedback(wcOrderID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myPurchaseFeedback(wcOrderID: wcOrderID)
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getPurchasesDateGrouped() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myPurchasesDateGrouped
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getMySkinQuiz() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.mySkinQuiz
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func createMySkinQuizAnswers(request: Any) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.mySkinQuizAnswers
    service.method = .post
    service.requestBody = request
    service.debugName = #function
    return service
  }
  
  public static func getMySkinQuizAnswers() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.mySkinQuizAnswers
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func computeMySkinQuiz() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.mySkinQuizCompute
    service.method = .post
    service.debugName = #function
    return service
  }
  
  public static func emailMySkinQuizResult(request: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.mySkinQuizEmailResult
    service.method = .post
    service.requestBody = PPAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func getMySkinAnalysis(request: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.mySkinAnalysis
    service.method = .post
    service.requestBody = PPAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func getMySkinAnalysisStatistics(request: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.mySkinAnalysisStatistics
    service.method = .post
    service.requestBody = PPAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func getMySkinAnalysisAreaSelection() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.mySkinAnalysisAreaSelection
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getMySkinType() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.mySkinType
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getMySkinLogs(page: Int, pageSize: Int) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.mySkinLogs
    service.queryParameters = [
      .init(key: .page, value: String(format: "%d", page)),
      .init(key: .pageSize, value: String(format: "%d", pageSize))]
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getMySkinLogAreas() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.mySkinLogAreas
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func getMySkinLogConditions() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.mySkinLogConditions
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func mySkinLogCreate(fileRequest: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.mySkinLogCreate
    service.method = .post
    service.requestBody = PPAPIService.createFileRequestBody(fileRequest)
    service.debugName = #function
    return service
  }
  
  public static func mySkinLogUpdate(skinLogID: String, fileRequest: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.mySkinLogUpdate(skinLogID: skinLogID)
    service.method = .post
    service.requestBody = PPAPIService.createFileRequestBody(fileRequest)
    service.debugName = #function
    return service
  }
  
  public static func mySkinLogDelete(skinLogID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.mySkinLogDelete(skinLogID: skinLogID)
    service.method = .delete
    service.debugName = #function
    return service
  }
  
  public static func socialLink(request: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.mySocialLink
    service.method = .post
    service.requestBody = PPAPIService.createRequestBody(request)
    service.debugName = #function
    return  service
  }
  
  public static func socialUnlink(request: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.mySocialUnlink
    service.method = .post
    service.requestBody = PPAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func getShippingAddresses() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myShippingAddresses
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func createShippingAddress(request: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myShippingAddressCreate
    service.method = .post
    service.requestBody = PPAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func updateShippingAddress(shippingID: String, request: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myShippingAddressUpdate(shippingID: shippingID)
    service.method = .patch
    service.requestBody = PPAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func markShippingAddressAsDefault(shippingID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myShippingAsDefault(shippingID: shippingID)
    service.method = .patch
    service.debugName = #function
    return service
  }
  
  public static func deleteShippingAddress(shippingID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myShippingAddressDelete(shippingID: shippingID)
    service.method = .delete
    service.debugName = #function
    return service
  }
  
  public static func getStripCards() -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myStripeCards
    service.method = .get
    service.debugName = #function
    return service
  }
  
  public static func createStripeCard(tokenID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myStripeCardCreate
    service.method = .post
    service.requestBody = tokenID
    service.debugName = #function
    return service
  }
  
  public static func updateStripeCard(cardID: String, request: [APIServiceConstant.Key: Any]) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myStripeCardUpdate(cardID: cardID)
    service.method = .patch
    service.requestBody = PPAPIService.createRequestBody(request)
    service.debugName = #function
    return service
  }
  
  public static func markStripeCardAsDefault(cardID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myStripeCardAsDefault(cardID: cardID)
    service.method = .post
    service.debugName = #function
    return service
  }
  
  public static func deleteStripCard(cardID: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myStripeCardDelete(cardID: cardID)
    service.method = .delete
    service.debugName = #function
    return service
  }
  
  public static func updateFCMToken(_ token: String) -> PPAPIService {
    var service = PPAPIService()
    service.path = APIPath.myFCMToken(token)
    service.method = .put
    var platformDetails: [APIServiceConstant.Key: Any] = [:]
    platformDetails[.appIdentifier] = AppMainInfo.identifier
    platformDetails[.appVersion] = AppMainInfo.version
    platformDetails[.appBuild] = AppMainInfo.build
    platformDetails[.appDisplayName] = AppMainInfo.displayName
    platformDetails[.deviceIdentifier] = DeviceInfo.identifier
    platformDetails[.deviceName] = DeviceInfo.name
    platformDetails[.deviceModel] = DeviceInfo.model
    platformDetails[.deviceModelName] = DeviceInfo.modeName
    platformDetails[.deviceSystemName] = DeviceInfo.systemName
    platformDetails[.deviceSystemVersion] = DeviceInfo.systemVersion
    service.requestBody = PPAPIService.createRequestBody([
      .platform: "ios",
      .platformDetails: platformDetails])
    service.debugName = #function
    return service
  }
}
