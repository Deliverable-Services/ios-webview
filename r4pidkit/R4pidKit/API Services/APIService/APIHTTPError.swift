//
//  APIHTTPError.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 30/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation

public struct APIHTTPError {
  public var detail: String?
  public var status: String?
  
  public init(statusCode: Int) {
    switch statusCode {
      case 400:
      detail = "Server cannot process your request since its invalid."
      status = "Client Error: Bad request"
      case 401:
      detail = "Server has refused your authentication."
      status = "Client Error: Unauthorized"
      case 402:
      detail = "Server cannot process your request since you've reached your daily limit."
      status = "Client Error: Payment Required"
      case 403:
      detail = "Server cannot process your request since its forbidden."
      status = "Client Error: Forbidden"
      case 404:
      detail = "Server cannot process your request since its not found."
      status = "Client Error: Not Found"
      case 405:
      detail = "Server cannot process your request since the request method is not allowed."
      status = "Client Error: Method Not Allowed"
      case 406:
      detail = "Server cannot process your request since the request is not acceptable."
      status = "Client Error: Not Acceptable"
      case 407:
      detail = "Server cannot process your request since the request should authenticate with proxy."
      status = "Client Error: Proxy Authentication Required"
      case 408:
      detail = "Server cannot process your request since the request has timed out."
      status = "Client Error: Request Timeout"
      case 409:
      detail = "Server cannot process your request since the request has conflict."
      status = "Client Error: Conflict"
      case 410:
      detail = "Server cannot process your request since the request resource is no longer available."
      status = "Client Error: Gone"
      case 411:
      detail = "Server cannot process your request since the request did not specify its lenght."
      status = "Client Error: Length Required"
      case 412:
      detail = "Server cannot process your request since the request did not meet the preconditions."
      status = "Client Error: Precondition Required"
      case 413:
      detail = "Server cannot process your request since the request is too large."
      status = "Client Error: Payload Too Large"
      case 414:
      detail = "Server cannot process your request since the request URI is too large."
      status = "Client Error: URI Too Long"
      case 415:
      detail = "Server cannot process your request since the request media type is not supported."
      status = "Client Error: Unsupported Media Type"
      case 416:
      detail = "Server cannot process your request since the request range is not satisfiable."
      status = "Client Error: Range Not Satisfiable"
      case 417:
      detail = "Server cannot process your request since the request expectation failed."
      status = "Client Error: Expectation Failed"
      case 418:
      detail = "Server: I'm A Teapot."
      status = "Client Error: I'm A Teapot"
      case 421:
      detail = "Server cannot process your request since the request redirected."
      status = "Client Error: Misdirected Request"
      case 422:
      detail = "Server cannot process your request since the request was well-formed but was unable to be followed due to semantic errors."
      status = "Client Error: Unprocessable Entity"
      case 423:
      detail = "Server cannot process your request since the request resource that is being accessed is locked."
      status = "Client Error: Locked"
      case 424:
      detail = "Server cannot process your request since the request failed due to failure of a previous request."
      status = "Client Error: Failed Dependency"
      case 426:
      detail = "Server cannot process your request since the request should be upgraded."
      status = "Client Error: Update Required"
      case 428:
      detail = "Server cannot process your request since the request is required to be conditional."
      status = "Client Error: Precondition Required"
      case 429:
      detail = "Server cannot process your request since the you've have sent too many requests in a given amount of time."
      status = "Client Error: Too Many Requests"
      case 431:
      detail = "Server cannot process your request since the request headers may be too large."
      status = "Client Error: Request Header Fields Too Large"
      case 451:
      detail = "Server cannot process your request since it may be unavailable for legal reasons."
      status = "Client Error: Unavailable For Legal Reasons"
      case 500:
      detail = "Server cannot fulfill your request due to internal errors."
      status = "Server Error: Internal Server Error"
      case 501:
      detail = "Server cannot fulfill your request since its not recognized."
      status = "Server Error: Not Implemented"
      case 502:
      detail = "Server cannot fulfill your request since an upstream request is invalid."
      status = "Server Error: Bad Gateway"
      case 503:
      detail = "Server cannot fulfill your request since its currently unavailable."
      status = "Server Error: Service Unavailable"
      case 504:
      detail = "Server cannot fulfill your request since it was acting as a gateway or proxy and did not receive a timely response from the upstream server.."
      status = "Server Error: Gateway Timeout"
      case 505:
      detail = "Server cannot fulfill your request since it does not support the HTTP protocol version used in the request."
      status = "Server Error: HTTP Version Not Supported"
      case 506:
      detail = "Server cannot fulfill your request since transparent content negotiation for the request results in a circular reference."
      status = "Server Error: Variant Also Negotiates"
      case 507:
      detail = "Server cannot fulfill your request since it is unable to store the representation needed to complete the request."
      status = "Server Error: Insufficient Storage"
      case 508:
      detail = "Server cannot fulfill your request since it detecteded an infinite loop while processing the request."
      status = "Server Error: Loop Detected"
      case 510:
      detail = "Server cannot fulfill your request since extensions to the request are required for the server to fulfil it."
      status = "Server Error: Not Extended"
      case 511:
      detail = "Server cannot fulfill your request since client needs to authenticate to gain network access."
      status = "Server Error: Network Authentication Required"
      default:
      detail = "Error cannot be determined using status code: ".appendingFormat("%d", statusCode)
      status = "Error"
    }
  }
}
