//
//  URLRedirectionHandler.swift
//  Porcelain
//
//  Created by Justine Rangel on 13/03/2019.
//  Copyright © 2019 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import R4pidKit

private struct Constant {
  static let validHosts = ["www.porcelainskin.com"]
  static let validPaths = ["feedback", "scan"]
}

public enum URLRedirectionType {
  case feedback(appointmentID: String)
  case scan(room: String)
  case invalid(error: String)
  
  init(url: URL) {
    switch url.lastPathComponent {
    case "feedback":
      if let value = URLRedirectionType.getQueryByName("appointmentID", usingURL: url) {
        self = .feedback(appointmentID: value)
      } else {
        self = .invalid(error: "No appointment ID")
      }
    case "scan":
      if let value = URLRedirectionType.getQueryByName("room", usingURL: url) {
        self = .scan(room: value)
      } else {
        self = .invalid(error: "No room")
      }
    default:
      self = .invalid(error: "Path was not found")
    }
  }
  
  public var isSuccessful: Bool {
    switch self {
    case .invalid:
      return false
    default:
      return true
    }
  }
  
  private static func getQueryByName(_ name: String, usingURL url: URL) -> String? {
    return URLComponents(string: url.absoluteString)?.queryItems?.first(where: { $0.name == name })?.value
  }
}

public protocol URLRedirectionHandlerProtocol {
  func redirect(type: URLRedirectionType, url: URL?, link: String?)
}

extension URLRedirectionHandlerProtocol {
  @discardableResult
  public func evaluateLinkForRedirection(link: String?) -> Bool {
    if InputValidator.validate(text: link, validationRegex: .smartPantryMacAddress).isValid {
      if let room = link {
        redirect(type: .scan(room: room), url: nil, link: link)
      } else {
        redirect(type: .invalid(error: "Room is invalid."), url: nil, link: link)
      }
      return true
    } else {
      if let url = URL(string: link ?? "") {
        return evaluateURLForRedirection(url: url)
      } else {
        redirect(type: .invalid(error: "Link is invalid"), url: nil, link: link)
        return false
      }
    }
  }
  
  @discardableResult
  public func evaluateURLForRedirection(url: URL) -> Bool {
    let redirectionType = URLRedirectionType(url: url)
    redirect(type: redirectionType, url: url, link: nil)
    return redirectionType.isSuccessful
  }
}
