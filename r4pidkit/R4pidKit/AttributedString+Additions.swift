//
//  AttributedString+Additions.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 21/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation

extension String {
  public var attributed: NSMutableAttributedString {
    return NSMutableAttributedString(string: self)
  }
  
  public var nsString: NSString {
    return NSString(string: self)
  }
  
  public var fullRange: NSRange {
    return NSRange(self.startIndex..., in: self)
  }
  
  public func rangeOf(text: String) -> NSRange {
    return nsString.range(of: text)
  }
}

extension String {
  public var htmlAttributedString: NSMutableAttributedString? {
    guard let attributedString = try? NSAttributedString(text: self, type: .html) else { return nil }
    return NSMutableAttributedString(attributedString: attributedString)
  }
}

extension UIImage {
  public var attributed: NSMutableAttributedString {
    return NSMutableAttributedString().appendImage(self)
  }
}

public protocol AttributedStringAppearanceProtocol {
  var characterSpacing: Double? { get }
  var alignment: NSTextAlignment? { get }
  var lineBreakMode: NSLineBreakMode? { get }
  var minimumLineHeight: CGFloat? { get }
  var headIndent: CGFloat? { get }
  var font: UIFont? { get }
  var color: UIColor? { get }
}

extension AttributedStringAppearanceProtocol {
  public var headIndent: CGFloat? {
    return nil
  }
}

extension AttributedStringAppearanceProtocol {
  public var paragraphStyle: NSMutableParagraphStyle {
    let paragraphStyle = NSMutableParagraphStyle()
    if let alignment = alignment {
      paragraphStyle.alignment = alignment
    }
    if let headIndent = headIndent {
      paragraphStyle.headIndent = headIndent
    }
    if let lineBreakMode = lineBreakMode {
      paragraphStyle.lineBreakMode = lineBreakMode
    }
    if let minimumLineHeight = minimumLineHeight {
      paragraphStyle.minimumLineHeight = minimumLineHeight
    }
    return paragraphStyle
  }
}

extension NSAttributedString {
  public convenience init?(text: String, type: DocumentType) throws {
    guard let data = text.data(using: .utf8) else { return nil }
    try self.init(
      data: data,
      options: [
        .documentType : type,
        .characterEncoding: String.Encoding.utf8.rawValue],
      documentAttributes: nil)
  }
  
  public static func createAttributes(_ attrs: [Attribute]) -> [NSAttributedString.Key: Any] {
    var attributes: [NSAttributedString.Key: Any] = [:]
    attrs.forEach { (attr) in
      switch attr {
      case .appearance(let appearance):
        if let characterSpacing = appearance.characterSpacing {
          attributes[.kern] = characterSpacing
        }
        attributes[.paragraphStyle] = appearance.paragraphStyle
        if let font = appearance.font {
          attributes[.font] = font
        }
        if let color = appearance.color {
          attributes[.foregroundColor] = color
        }
      case .font(let  value):
        attributes[.font] = value
      case .color(let value):
        attributes[.foregroundColor] = value
      case .backgroundColor(let value):
        attributes[.backgroundColor] = value
      case .baseline(let value):
        attributes[.baselineOffset] = value
      case .characterSpacing(let value):
        attributes[.kern] = value
      case .underlineStyle(let value):
        attributes[.underlineStyle] = value.rawValue
      case .underlineColor(let color):
        attributes[.underlineColor] = color
      case .strikethroughStyle(let value):
        attributes[.strikethroughStyle] = value.rawValue
      case .strikethroughColor(let value):
        attributes[.strikethroughColor] = value
      case .paragraphStyle(let value):
        attributes[.paragraphStyle] = value
      case .strokeColor(let value):
        attributes[.strokeColor] = value
      case .strokeWidth(let value):
        attributes[.strokeWidth] = value
      case .link(let url):
        attributes[.link] = url
      case .textEffect(let value):
        attributes[.textEffect] = value
      case .shadow(let shadow):
        attributes[.shadow] = shadow.value
      }
    }
    return attributes
  }
  
  public static func createAttributesString(_ attrs: [Attribute]) -> [String: Any] {
    var attributesString: [String: Any] = [:]
    createAttributes(attrs).forEach { (k, v) in
      attributesString[k.rawValue] = v
    }
    return attributesString
  }
}

extension NSAttributedString {
  public enum Shadow {
    case `default`
    case custom(offset: CGSize?, blurRadius: CGFloat?, color: UIColor?)
    
    public var value: NSShadow {
      let shadow = NSShadow()
      switch self {
      case .default:
        return shadow
      case .custom(let offset, let blurRadius, let color):
        if let offset = offset {
          shadow.shadowOffset = offset
        }
        if let blurRadius = blurRadius {
          shadow.shadowBlurRadius = blurRadius
        }
        if let color = color {
          shadow.shadowColor = color
        }
        return shadow
      }
    }
  }
}

extension NSAttributedString {
  public enum Attribute {
    case appearance(_ appearance: AttributedStringAppearanceProtocol)
    case font(_ font: UIFont)
    case color(_ color: UIColor)
    case backgroundColor(_ color: UIColor)
    case baseline(offset: Double)
    case characterSpacing(_ value: Double)
    case underlineStyle(_ style: NSUnderlineStyle)
    case underlineColor(_ color: UIColor)
    case strikethroughStyle(_ style: NSUnderlineStyle)
    case strikethroughColor(_ color: UIColor)
    case paragraphStyle(_ style: NSParagraphStyle)
    case strokeColor(_ color: UIColor)
    case strokeWidth(_ double: Double)
    case link(_ url: URL)
    case textEffect(_ effect: TextEffectStyle)
    case shadow(_ shadow: Shadow)
  }
}

extension NSMutableAttributedString {
  @discardableResult
  public func add(_ attrs: [Attribute], text: String? = nil) -> NSMutableAttributedString {
    let range = text?.rangeFrom(text: string) ?? string.fullRange
    beginEditing()
    attrs.forEach({ addAttr($0, range: range) })
    endEditing()
    return self
  }
  
  @discardableResult
  public func add(_ attrs: [Attribute], range: NSRange) -> NSMutableAttributedString {
    beginEditing()
    attrs.forEach({ addAttr($0, range: range) })
    endEditing()
    return self
  }
  
  @discardableResult
  public func add(_ attribute: Attribute, text: String? = nil) -> NSMutableAttributedString {
    let range = text?.rangeFrom(text: string) ?? string.fullRange
    beginEditing()
    addAttr(attribute, range: range)
    endEditing()
    return self
  }
  
  @discardableResult
  public func add(_ attribute: Attribute, range: NSRange) -> NSMutableAttributedString {
    beginEditing()
    addAttr(attribute, range: range)
    endEditing()
    return self
  }
  
  @discardableResult
  public func append(attrs: NSAttributedString) -> NSMutableAttributedString {
    append(attrs)
    return self
  }
  
  public func appendImage(_ image: UIImage, size: CGFloat? = nil, offset: CGPoint? = nil) -> NSMutableAttributedString {
    let attachment = NSTextAttachment()
    attachment.image = image.withRenderingMode(.alwaysOriginal)
    var imageSize = image.size
    if let size = size {
      imageSize.width = size * imageSize.width / imageSize.height
      imageSize.height = size
    }
    attachment.bounds = CGRect(origin: offset ?? .zero, size: imageSize)
    append(NSAttributedString(attachment: attachment))
    return self
  }
}

extension String {
  fileprivate func rangeFrom(text: String) -> NSRange {
    return text.rangeOf(text: self)
  }
}

extension NSMutableAttributedString {
  private func addAttr(_ attr: Attribute, range: NSRange) {
    switch attr {
    case .appearance(let appearance):
      if let characterSpacing = appearance.characterSpacing {
        addAttr(.characterSpacing(characterSpacing), range: range)
      }
      addAttr(.paragraphStyle(appearance.paragraphStyle), range: range)
      if let font = appearance.font {
        addAttr(.font(font), range: range)
      }
      if let color = appearance.color {
        addAttr(.color(color), range: range)
      }
    case .font(let  value):
      addAttribute(.font, value: value, range: range)
    case .color(let value):
      addAttribute(.foregroundColor, value: value, range: range)
    case .backgroundColor(let value):
      addAttribute(.backgroundColor, value: value, range: range)
    case .baseline(let value):
      addAttribute(.baselineOffset, value: value, range: range)
    case .characterSpacing(let value):
      addAttribute(.kern, value: value, range: range)
    case .underlineStyle(let value):
      addAttribute(.underlineStyle, value: value.rawValue, range: range)
    case .underlineColor(let color):
      addAttribute(.underlineColor, value: color, range: range)
    case .strikethroughStyle(let value):
      addAttribute(.strikethroughStyle, value: value.rawValue, range: range)
    case .strikethroughColor(let value):
      addAttribute(.strikethroughColor, value: value, range: range)
    case .paragraphStyle(let value):
      addAttribute(.paragraphStyle, value: value, range: range)
    case .strokeColor(let value):
      addAttribute(.strokeColor, value: value, range: range)
    case .strokeWidth(let value):
      addAttribute(.strokeWidth, value: value, range: range)
    case .link(let url):
      addAttribute(.link, value: url, range: range)
    case .textEffect(let value):
      addAttribute(.textEffect, value: value, range: range)
    case .shadow(let shadow):
      addAttribute(.shadow, value: shadow.value, range: range)
    }
  }
}
