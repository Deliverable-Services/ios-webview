//
//  PorcelainFont.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 21/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public typealias PorcelainFont = UIFont

public protocol PorcelainFontStylePrococol {
  var font: PorcelainFont { get }
}

extension PorcelainFontStylePrococol {
  public func generateFont(name: String, size: CGFloat) -> PorcelainFont {
    // fallback to system if font name is not found
    return UIFont(name: name, size: size) ?? .systemFont(ofSize: size)
  }
}

public enum IdealSansFontStyle: PorcelainFontStylePrococol {
  case book(size: CGFloat)
  case italic(size: CGFloat)
  case light(size: CGFloat)
  case thin(size: CGFloat)
  
  public var font: PorcelainFont {
    switch self {
    case .book(let size):
      return generateFont(name: "IdealSans-Book", size: size)
    case .italic(let size):
      return generateFont(name: "IdealSans-BookItalic", size: size)
    case .light(let size):
      return generateFont(name: "IdealSans-Light", size: size)
    case .thin(let size):
      return generateFont(name: "IdealSans-Thin", size: size)
    }
  }
}

public enum OpenSansFontStyle: PorcelainFontStylePrococol {
  case regular(size: CGFloat)
  case italic(size: CGFloat)
  case light(size: CGFloat)
  case lightItalic(size: CGFloat)
  case semiBold(size: CGFloat)
  case semiBoldItalic(size: CGFloat)
  case bold(size: CGFloat)
  case boldItalic(size: CGFloat)
  case extraBold(size: CGFloat)
  case extraBoldItalic(size: CGFloat)
  
  public var font: PorcelainFont {
    switch self {
    case .regular(let size):
      return generateFont(name: "OpenSans-Regular", size: size)
    case .italic(let size):
      return generateFont(name: "OpenSans-Italic", size: size)
    case .light(let size):
      return generateFont(name: "OpenSans-Light", size: size)
    case .lightItalic(let size):
      return generateFont(name: "OpenSans-LightItalic", size: size)
    case .semiBold(let size):
      return generateFont(name: "OpenSans-semiBold", size: size)
    case .semiBoldItalic(let size):
      return generateFont(name: "OpenSans-semiBoldItalic", size: size)
    case .bold(let size):
      return generateFont(name: "OpenSans-Bold", size: size)
    case .boldItalic(let size):
      return generateFont(name: "OpenSans-BoldItalic", size: size)
    case .extraBold(let size):
      return generateFont(name: "OpenSans-ExtraBold", size: size)
    case .extraBoldItalic(let size):
      return generateFont(name: "OpenSans-ExtraBoldItalic", size: size)
    }
  }
}

extension PorcelainFont {
  public static func materialDesign(size: CGFloat) -> PorcelainFont {
    return UIFont(name: "Material-Design-Iconic-Font", size: size)!
  }
  
  public static func idealSans(style: IdealSansFontStyle) -> PorcelainFont {
    return style.font
  }
  
  public static func openSans(style: OpenSansFontStyle) -> PorcelainFont {
    return style.font
  }
 }
