//
//  InputValidator.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 24/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation

public enum InputValidatorError: Error {
  case empty(message: String?)
  case tooLong(message: String?)
  case tooShort(message: String?)
  case notInRange(message: String?)
  case invalid(message: String?)
}

extension InputValidatorError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .empty(let message):
      return message
    case .tooLong(let message):
      return message
    case .tooShort(let message):
      return message
    case .notInRange(let message):
      return message
    case .invalid(let message):
      return message
    }
  }
}

public protocol InputValidatorErrorConfigProtocol {
  var empty: InputValidatorError? { get }
  var tooLong: InputValidatorError? { get }
  var tooShort: InputValidatorError? { get }
  var notInRange: InputValidatorError? { get }
  var invalid: InputValidatorError { get }
}

public enum InputValidatorRegex {
  case email
  case smartPantryMacAddress
  case custom(regex: String)
  case lenght(value: Int)
  case range(min: Int, max: Int)
  
  public var regex: String {
    switch self {
    case .email:
      return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    case .smartPantryMacAddress:
      return #"^(?:[[:xdigit:]]{2}([-:]))(?:[[:xdigit:]]{2}\1){4}[[:xdigit:]]{2}$"#
    case .custom(let regex):
      return regex
    case .lenght:
      return ""
    case .range:
      return ""
    }
  }
}

public enum InputValidator {
  case validate(text: String?, validationRegex: InputValidatorRegex)
  
  public var isValid: Bool {
    switch self {
    case .validate(let text, let validationRegex):
      switch validationRegex {
      case .lenght(let value):
        guard let text = text, text.count == value else { return false }
        return true
      case .range(let min, let max):
        guard let text = text, text.count >= min, text.count <= max else { return false }
        return true	
      default:
        return NSPredicate(format: "SELF MATCHES %@", validationRegex.regex).evaluate(with: text)
      }
    }
  }
  
  public func validate(fieldName: String) throws {
    switch self {
    case .validate(let text, let validationRegex):
      switch validationRegex {
      case .lenght(let value):
        guard let text = text, !text.isEmpty  else { throw InputValidatorError.empty(message: "\(fieldName) is empty.") }
        guard text.count <= value else { throw InputValidatorError.tooLong(message: "\(fieldName) is too long.") }
        guard isValid else { throw InputValidatorError.tooShort(message: "\(fieldName) is too short.") }
      case .range:
        guard let text = text, !text.isEmpty  else { throw InputValidatorError.empty(message: "\(fieldName) is empty.") }
        guard isValid else { throw InputValidatorError.notInRange(message: "\(fieldName) is not in range") }
      default:
        guard let text = text, !text.isEmpty else { throw InputValidatorError.empty(message: "\(fieldName) is empty.") }
        guard isValid else { throw InputValidatorError.invalid(message: "\(fieldName) is invalid.") }
      }
    }
  }
  
  public func validate(errorConfig: InputValidatorErrorConfigProtocol) throws {
    switch self {
    case .validate(let text, let validationRegex):
      switch validationRegex {
      case .lenght(let value):
        guard let text = text, !text.isEmpty  else { throw errorConfig.empty ?? errorConfig.invalid }
        guard text.count <= value else { throw errorConfig.tooLong ?? errorConfig.invalid }
        guard isValid else { throw errorConfig.tooShort ?? errorConfig.invalid }
      case .range:
        guard let text = text, !text.isEmpty  else { throw errorConfig.empty ?? errorConfig.invalid }
        guard isValid else { throw errorConfig.notInRange ?? errorConfig.invalid }
      default:
        guard let text = text, !text.isEmpty else { throw errorConfig.empty ?? errorConfig.invalid }
        guard isValid else { throw errorConfig.invalid}
      }
    }
  }
  
  public func matches(for regex: String, in text: String) throws -> [String] {
    do {
      let regex = try NSRegularExpression(pattern: regex)
      let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
      return results.map { String(text[Range($0.range, in: text)!]) }
    } catch {
      throw error
    }
  }
}
