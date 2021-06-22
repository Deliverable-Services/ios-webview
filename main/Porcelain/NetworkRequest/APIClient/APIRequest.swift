//
//  APIRequest.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 19/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import SwiftyJSON

extension String: Error {
  public var localizedDescription: String {
    return self
  }
}

protocol APIRequest: APIRequestProtocol, APILoggerProtocol { }

extension APIRequest {
  func startRequest(_ successBlock: SuccessBlock?, failBlock: FailBlock?) {
    print("constructURLComponents: ", constructURLComponents())
    guard let url = constructURLComponents().url else {
      failBlock?("URL not constructed", nil, nil, nil, nil)
      return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method
    request.allHTTPHeaderFields = headers
    
    do {
      if let parameters = parameters {
        let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        request.httpBody = jsonData
      }
      
      DispatchQueue.global(qos: .background).async {
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
          if shouldDisplayNetworkLogs { self.log(request) }
          
          let httpResponse = response as? HTTPURLResponse
          let statusCode = httpResponse?.statusCode
          print("SuccessCode: \(self.successCode), statusCode: \(statusCode ?? 0)")
          
          guard statusCode != nil, data != nil else {
              if shouldDisplayNetworkLogs { self.log(error, statusCode: statusCode ?? 0) }
              failBlock?(error, statusCode, data, httpResponse, error?.localizedDescription)
              return
          }
          
          let code = statusCode ?? 0
          
          do {
            let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
            if shouldDisplayNetworkLogs { self.log(httpResponse, json: jsonDictionary as [String : AnyObject]?) }
            
            guard code == self.successCode  || (code > 199 && code < 300) else {
              if shouldDisplayNetworkLogs { self.log(error, errorMessage: jsonDictionary?["message"] as? String, statusCode: code) }
              failBlock?(error, statusCode, data, httpResponse,
                         (jsonDictionary?["message"] as? String) ?? error?.localizedDescription)
              return
            }
            
            if let json = jsonDictionary {
              successBlock?([json])
            }
            else {
              successBlock?(nil)
            }
            
          } catch {
            if let data = data, let rawJSON = String(data: data, encoding: .utf8) {
              print("Error in JSONSerialization.jsonObjectWithData -> raw json: \n", rawJSON)
            }
            guard code == self.successCode  || (code > 199 && code < 300) else {
              if shouldDisplayNetworkLogs { self.log(error, statusCode: code) }
              failBlock?(error, statusCode, data, httpResponse, error.localizedDescription)
              return
            }
            successBlock?(nil)
          }
        })
        task.resume()
      }
    } catch {
      failBlock?(error, nil, nil, nil, nil)
    }
  }
  
  private func constructURLComponents() -> URLComponents {
    var urlComponents = URLComponents()
    urlComponents.scheme = scheme()
    urlComponents.host = host()
    urlComponents.path = path
    urlComponents.port = port()
    
    if let query = queryParameters, query.count > 0 {
      urlComponents.queryItems = query.buildQueryItem()
    }

    urlComponents.percentEncodedPath = urlComponents.percentEncodedPath.replaceString(",", with: "%2C")//fix for , path encode path
    return urlComponents
  }
}
