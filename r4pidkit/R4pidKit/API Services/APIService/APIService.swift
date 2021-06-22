//
//  APIService.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 21/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import os.log

private struct Constant {
  static let identity = "\(DeviceInfo.model)(\(DeviceInfo.identifier)) \(DeviceInfo.systemName) \(DeviceInfo.systemVersion) \(AppMainInfo.identifier ?? "") \(AppMainInfo.version ?? "")(\(AppMainInfo.build ?? ""))"
}

public struct APIError: Error, APILogProtocol {
  public var message: String?
  public var failureCode: HTTPStatusCodes.Failure
  
  public init(message: String?, failureCode: HTTPStatusCodes.Failure) {
    self.message = message
    self.failureCode = failureCode
  }
  
  public var localizedDescription: String {
    switch failureCode {
    case .code(let value):
      return message ?? APIHTTPError(statusCode: value).detail ?? "Unknown error with status code: \(value)"
    }
  }
  
  public func logSelf() {
    APIError.apiLog("error: ", localizedDescription)
  }
}

public struct APISuccess: APILogProtocol {
  public var message: String?
  public var data: JSON
  public var successCode: HTTPStatusCodes.Success
  public var raw: JSON
  
  public func logSelf() {
    APISuccess.apiLog("success code: ", successCode.rawValue)
    APISuccess.apiLog("message: ", message ?? "")
    if !data.isEmpty {
      APISuccess.apiLog("data: ", data)
    } else {
      APISuccess.apiLog("has raw: ", !raw.isEmpty)
    }
  }
}

public typealias APIResponse = Result<APISuccess, APIError>

public typealias APIResponseCompletion = (APIResponse) -> Void

public typealias APIPreloadCompletion = (APISuccess?) -> Void

//Preloading start
extension APISuccess {
  fileprivate var preloadJSON: JSON {
    var data: [String: Any] = [:]
    data["message"] = message
    data["data"] = self.data.rawString()
    data["successCode"] = successCode.rawValue
    data["raw"] = raw.rawString()
    return JSON(data)
  }
  
  init?(data: JSON) {
    guard let successCode = HTTPStatusCodes.Success(rawValue: data["successCode"].int ?? -1)  else { return nil }
    message = data["message"].string
    self.data = JSON(parseJSON: data["data"].stringValue)
    self.successCode = successCode
    raw = JSON(parseJSON: data["raw"].stringValue)
  }
}
public struct APIPreloadDefaults {
  public static func get(keyURL: URL) -> APISuccess? {
    return nil
//    return APISuccess(data: JSON(parseJSON: R4pidDefaults.shared[.init(value: keyURL.absoluteString)]?.string ?? ""))
  }
  
  public static func set(keyURL: URL, value: APISuccess?) {
//    R4pidDefaults.shared[.init(value: keyURL.absoluteString)] = .init(value: value?.preloadJSON.rawString())
  }
}

//Preloading end
public enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case patch = "PATCH"
  case delete = "DELETE"
}

public struct HTTPStatusCodes {
  public enum Success: Int {
    case ok = 200
    case created
    case accepted
    case nonAuthoritativeInfo
    case noContent
    case resetContent
    case partialContent
    case multiStatus
    case alreadyReported
    case success209 = 209
    case success210 = 210
    case success211 = 211
    case imUsed = 226
  }
  
  public enum Failure {
    case code(Int)
    
    public var rawCode: Int {
      switch self {
      case .code(let value):
        guard HTTPStatusCodes.Success(rawValue: value) == nil else { return -1 } //success code but error
        return value
      }
    }
  }
}

public struct UploadPart {
  let filename: String
  let data: Data
  
  public init?(filename: String, data: Data?) {
    guard let data = data else { return nil }
    self.filename = filename
    self.data = data
  }
}

public protocol APIPathProtocol {
  var rawValue: String { get }
}

public protocol APIServiceProtocol: APILogProtocol {
  var request: APIRequestProtocol { get }
  var path: APIPathProtocol? { get }
  var method: HTTPMethod { get }
  var requestBody: Any? { get }
  var queryParameters: [URLQueryItem]? { get }
  var debugName: String? { get }
}

extension APIServiceProtocol {
  public static func createRequestBody(_ body: [APIServiceConstant.Key: Any]) -> Any {
    var requestBody: [String: Any] = [:]
    body.forEach { (k, v) in
      if let body = v as? [APIServiceConstant.Key: Any] {
        requestBody[k.rawValue] = createRequestBody(body)
      } else if let body = v as? [[APIServiceConstant.Key: Any]] {
        requestBody[k.rawValue] = body.map({ createRequestBody($0) })
      } else {
        requestBody[k.rawValue] = v
      }
    }
    return requestBody
  }
  
  public static func generateBoudaryConstant() -> String {
    return "---------just1n3\(UUID().uuidString)r4ng3l--p0gCh4mP"
  }
  
  /// Only accepts Upload part and string(or json) values
  public static func createFileRequestBody(_ body: [APIServiceConstant.Key: Any]) -> (data: Data, boundary: String) {
    let boundary = generateBoudaryConstant()
    var dataBody = Data()
    body.forEach { (k, v) in
      if let uploadParts = v as? [UploadPart] {
        uploadParts.forEach { (uploadPart) in
          dataBody.append("--\(boundary)\r\n")
          dataBody.append("Content-Disposition: form-data; name=\"\(k.rawValue)\"; filename=\"\(uploadPart.filename)\"\r\n")
          dataBody.append("Content-Type: image/png\r\n\r\n")
          dataBody.append(uploadPart.data)
          dataBody.append("\r\n")
        }
      } else if let uploadPart = v as? UploadPart {
        dataBody.append("--\(boundary)\r\n")
        dataBody.append("Content-Disposition: form-data; name=\"\(k.rawValue)\"; filename=\"\(uploadPart.filename)\"\r\n")
        dataBody.append("Content-Type: image/png\r\n\r\n")
        dataBody.append(uploadPart.data)
        dataBody.append("\r\n")
      } else if let bString = v as? String {
        dataBody.append("--\(boundary)\r\n")
        dataBody.append("Content-Disposition: form-data; name=\"\(k.rawValue)\"\r\n\r\n")
        dataBody.append(bString)
        dataBody.append("\r\n")
      } else if let bNumber = v as? NSNumber {
        dataBody.append("--\(boundary)\r\n")
        dataBody.append("Content-Disposition: form-data; name=\"\(k.rawValue)\"\r\n\r\n")
        dataBody.append(bNumber.stringValue)
        dataBody.append("\r\n")
      }
    }
    dataBody.append("--\(boundary)--\r\n")
    return (data: dataBody, boundary: boundary)
  }
}

extension APIServiceProtocol {
  private var urlComponents: URLComponents {
    var urlComponents = URLComponents()
    urlComponents.scheme = request.scheme
    urlComponents.host = request.host
    urlComponents.port = request.port
    urlComponents.path = [request.base, path?.rawValue].compactMap({ $0 }).joined()
    urlComponents.queryItems = queryParameters
    urlComponents.percentEncodedPath = urlComponents.percentEncodedPath
      .replacingOccurrences(of: ",", with: "%2C")
    return urlComponents
  }
  
  /// Preload get success requests of the call if there is existing
  @discardableResult
  public func preload(completion: @escaping APIPreloadCompletion) -> Self {
    if let url = urlComponents.url {
      completion(APIPreloadDefaults.get(keyURL: url))
    } else {
      completion(nil)
    }
    return self
  }
  
  @discardableResult
  public func call(completion: @escaping APIResponseCompletion) -> URLSessionDataTask? {
    guard let url = urlComponents.url else {
      os_log("Fail to create URL from URLComponents: %{public}@", log: .network, type: .default, concatenate(urlComponents))
      DispatchQueue.main.async {
        completion(.failure(APIError(message: "Fail to create URL from URLComponents", failureCode: .code(-1))))
      }
      return nil
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.allHTTPHeaderFields = self.request.authHeaders()
    request.allHTTPHeaderFields?["identity"] = Constant.identity
    var requestOSLogger = APIRequestOSLogger(request: request, method: method, debugName: debugName ?? "")
    requestOSLogger.requestBody = requestBody
    requestOSLogger.headers = request.allHTTPHeaderFields
    Self.apiLog("\(debugName ?? "") \(method.rawValue.uppercased()) ", request)
    Self.apiLog("\(debugName ?? "") HEADERS: ", request.allHTTPHeaderFields ?? [:])
    do {
      requestOSLogger.logStart()
      if let requestBody = requestBody {
        if let rbTuple = requestBody as? (data: Data, boundary: String) {
          Self.apiLog("\(debugName ?? "") BODY: ", "upload data count: \(rbTuple.data.count)")
          request.httpBody = rbTuple.data
          request.setValue("multipart/form-data; boundary=\(rbTuple.boundary)", forHTTPHeaderField: "Content-Type")
        } else if let str = requestBody as? String {
          Self.apiLog("\(debugName ?? "") BODY: ", str)
          request.httpBody = str.data(using: .utf8)
        } else {
          Self.apiLog("\(debugName ?? "") BODY: ", JSON(requestBody))
          let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
          request.httpBody = jsonData
        }
      }
      let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        requestOSLogger.responseData = data
        Self.apiLog("\(self.debugName ?? "") RESPONSE: ")
        if let error = error {
          requestOSLogger.errorMessage = error.localizedDescription
          Self.apiLog("Error: \(error.localizedDescription)")
          requestOSLogger.logError()
          if self.method == .get {
            APIPreloadDefaults.set(keyURL: url, value: nil)
          }
          DispatchQueue.main.async {
            completion(.failure(APIError(message: error.localizedDescription, failureCode: .code(-1))))
          }
        } else if let httpResponse = response as? HTTPURLResponse {
          requestOSLogger.responseCode = httpResponse.statusCode
          if let data = data {
            do {
              let json = try JSON(data: data)
              requestOSLogger.responseJSON = json
              if let successCode = HTTPStatusCodes.Success(rawValue: httpResponse.statusCode) {
                let apiSuccess = APISuccess(message: json.message.string, data: json.data, successCode: successCode, raw: json)
                apiSuccess.logSelf()
                requestOSLogger.logSuccess()
                if self.method == .get {
                  APIPreloadDefaults.set(keyURL: url, value: apiSuccess)
                }
                DispatchQueue.main.async {
                  completion(.success(apiSuccess))
                }
              } else {
                if let errorMessage = json.message.string {
                  requestOSLogger.errorMessage = errorMessage
                  let apiError = APIError(message: errorMessage, failureCode: .code(httpResponse.statusCode))
                  apiError.logSelf()
                  requestOSLogger.logError()
                  if self.method == .get {
                    APIPreloadDefaults.set(keyURL: url, value: nil)
                  }
                  DispatchQueue.main.async {
                    completion(.failure(apiError))
                  }
                } else {
                  let apiError = APIError(message: json.dictionary?.first?.value.array?.first?.string, failureCode: .code(httpResponse.statusCode))
                  apiError.logSelf()
                  requestOSLogger.logError()
                  if self.method == .get {
                    APIPreloadDefaults.set(keyURL: url, value: nil)
                  }
                  DispatchQueue.main.async {
                    completion(.failure(apiError))
                  }
                }
              }
            } catch {
              var errorMessage = error.localizedDescription
              if httpResponse.statusCode == 401 {//handle authorization issue
                errorMessage = APIHTTPError(statusCode: httpResponse.statusCode).detail ?? errorMessage
                NotificationCenter.default.post(name: .apiServiceError401Notification, object: nil)
              }
              requestOSLogger.errorMessage = errorMessage
              let failureCode: HTTPStatusCodes.Failure = .code(httpResponse.statusCode)
              let apiError = APIError(message: errorMessage, failureCode: failureCode)
              requestOSLogger.responseCode = failureCode.rawCode
              apiError.logSelf()
              requestOSLogger.logError()
              if self.method == .get {
                APIPreloadDefaults.set(keyURL: url, value: nil)
              }
              DispatchQueue.main.async {
                completion(.failure(apiError))
              }
            }
          } else {
            if let successCode = HTTPStatusCodes.Success(rawValue: httpResponse.statusCode) {
              let apiSuccess = APISuccess(message: "Success", data: .init(""), successCode: successCode, raw: .init(""))
              apiSuccess.logSelf()
              requestOSLogger.logSuccess()
              if self.method == .get {
                APIPreloadDefaults.set(keyURL: url, value: apiSuccess)
              }
              DispatchQueue.main.async {
                completion(.success(apiSuccess))
              }
            } else {
              let apiError = APIError(message: nil, failureCode: .code(httpResponse.statusCode))
              apiError.logSelf()
              requestOSLogger.logError()
              if self.method == .get {
                APIPreloadDefaults.set(keyURL: url, value: nil)
              }
              DispatchQueue.main.async {
                completion(.failure(apiError))
              }
            }
          }
        } else {
          let apiError = APIError(message: "Someting went wrong", failureCode: .code(-1))
          apiError.logSelf()
          requestOSLogger.logError()
          if self.method == .get {
            APIPreloadDefaults.set(keyURL: url, value: nil)
          }
          DispatchQueue.main.async {
            completion(.failure(apiError))
          }
        }
      }
      task.resume()
      return task
    } catch {
      requestOSLogger.errorMessage = error.localizedDescription
      let apiError = APIError(message: error.localizedDescription, failureCode: .code(-1))
      apiError.logSelf()
      requestOSLogger.logError()
      if self.method == .get {
        APIPreloadDefaults.set(keyURL: url, value: nil)
      }
      DispatchQueue.main.async {
        completion(.failure(apiError))
      }
      return nil
    }
  }
}

public protocol APIServiceJSONCompletionProtocol: APILogProtocol {
  var jsonData: APIRequestJSONDataProtocol? { get }
  var bundle: Bundle? { get }
}

extension APIServiceJSONCompletionProtocol where Self: APIServiceProtocol {
  public func jsonCall(completion: @escaping APIResponseCompletion) {
    if let jsonData = jsonData {
      Self.apiLog("\(debugName ?? "") - JSON FILENAME: ", jsonData.filename)
      if let url = bundle?.url(forResource: jsonData.filename, withExtension: "json") {
        do {
          let data = try Data(contentsOf: url, options: .mappedIfSafe)
          let json = try JSON(data: data)
          if let successCode = HTTPStatusCodes.Success(rawValue: jsonData.expectedResultCode) {
            let apiSuccess = APISuccess(message: json.message.string ?? "JSON file loaded!", data: json.data, successCode: successCode, raw: json)
            apiSuccess.logSelf()
            DispatchQueue.main.async {
              completion(.success(apiSuccess))
            }
          } else {
            if let errorMessage = json.message.string {
              let apiError = APIError(message: errorMessage, failureCode: .code(jsonData.expectedResultCode))
              apiError.logSelf()
              DispatchQueue.main.async {
                completion(.failure(apiError))
              }
            } else {
              let apiError = APIError(message: nil, failureCode: .code(jsonData.expectedResultCode))
              apiError.logSelf()
              DispatchQueue.main.async {
                completion(.failure(apiError))
              }
            }
          }
        } catch {
          Self.apiLog("\(debugName ?? "") - JSON file not loaded!")
          let apiError = APIError(message: error.localizedDescription, failureCode: .code(-1))
          apiError.logSelf()
          DispatchQueue.main.async {
            completion(.failure(apiError))
          }
        }
      } else {
        Self.apiLog("\(debugName ?? "") - JSON file not loaded!")
        let apiError = APIError(message: "JSON FILENAME: \(jsonData.filename) not found!", failureCode: .code(-1))
        apiError.logSelf()
        DispatchQueue.main.async {
          completion(.failure(apiError))
        }
      }
    } else {
      Self.apiLog("\(debugName ?? "") - JSON data was not set")
      let apiError = APIError(message: "JSON data was not set", failureCode: .code(-1))
      apiError.logSelf()
      DispatchQueue.main.async {
        completion(.failure(apiError))
      }
    }
  }
}

private struct APIRequestOSLogger {
  var request: URLRequest
  var method: HTTPMethod
  var headers: [String: String]?
  var requestBody: Any?
  var responseCode: Int?
  var responseData: Data?
  var responseJSON: JSON = .init("")
  var errorMessage: String?
  var debugName: String
  
  init(request: URLRequest, method: HTTPMethod, debugName: String) {
    self.request = request
    self.method = method
    self.debugName = debugName
  }
  
  private func reEvaluatePrintRequest(request: [String: Any]) -> Any {
    var newRequest: [String: Any] = [:]
    request.forEach { (k, v) in
      if let key = APIServiceConstant.Key(rawValue: k), APIServiceConstant.maskedKeys.contains(key) {
        newRequest[k] = "<private>"
      } else if let innerRequest = v as? [String: Any] {
        newRequest[k] = reEvaluatePrintRequest(request: innerRequest)
      } else {
        newRequest[k] = v
      }
    }
    return newRequest
  }
  
  func logStart() {
    let jsonBody: JSON
    if let requestBody = requestBody as? [String: Any] {
      jsonBody = JSON(reEvaluatePrintRequest(request: requestBody))
    } else {
      jsonBody = .init("")
    }
    
    var printHeaders: [String: String] = [:]
    self.headers?.forEach { (k, v) in
      if k == "Authorization" {
        printHeaders[k] = "<private>"
      } else {
        printHeaders[k] = v
      }
    }
    
    os_log(
      """
======================[START %{public}@ REQUEST]======================
SERVICE METHOD: %{public}@
%{public}@ %{public}@
HEADERS: %{public}@
BODY: %{public}@
===============================================================
""",
      log: .network,
      type: .info,
      debugName, debugName, method.rawValue, concatenate(request), concatenate(printHeaders), concatenate(jsonBody))
  }
  
  func logSuccess()  {
    let message: String
    if let successMessage = responseJSON.message.string {
      message = concatenate("SUCCESS: ", successMessage)
    } else if let responseData = responseData, let responseRaw = String(data: responseData, encoding: .utf8) {
      message = concatenate("SUCCESS: ", responseRaw)
    } else {
      message = "Hooray!"
    }
    
    let printResponse: JSON
    if let response = responseJSON.rawValue as? [String: Any] {
      printResponse = JSON(reEvaluatePrintRequest(request: response))
    } else {
      printResponse = responseJSON
    }
    
    os_log(
      """
======================[SUCCESS %{public}@ REQUEST]======================
SERVICE METHOD: %{public}@
RESPONSE CODE: %{public}d
SUCCESS: %{public}@
RESPONSE: %{public}@
=================================================================
""", log: .network,
     type: .info,
     debugName, debugName, responseCode ?? -1, message, concatenate(printResponse))
  }
  
  func logError() {
    let message: String
    if let errorMessage = errorMessage {
      message = concatenate("ERROR: ", errorMessage)
    } else if let responseData = responseData, let responseRaw = String(data: responseData, encoding: .utf8) {
      message = concatenate("ERROR: ", responseRaw)
    } else {
      message = "ERROR Unknown :("
    }
    os_log(
      """
======================[ERROR %{public}@ REQUEST]======================
SERVICE METHOD: %{public}@
RESPONSE CODE: %{public}d
ERROR: %{public}@
RESPONSE: %{public}@
===============================================================
""", log: .network,
     type: .error,
     debugName, debugName, responseCode ?? -1, message, concatenate(responseJSON))
  }
}
