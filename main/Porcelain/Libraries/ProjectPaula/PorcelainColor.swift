//
//  PorcelainColor.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 21/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit

public typealias PorcelainColor = UIColor

extension PorcelainColor {
  @nonobjc public class var greyblue: UIColor {
    return UIColor(red: 107.0 / 255.0, green: 164.0 / 255.0, blue: 184.0 / 255.0, alpha: 1.0)
  }
  
  @nonobjc public class var lightNavy: UIColor {
    return UIColor(red: 22.0 / 255.0, green: 92.0 / 255.0, blue: 125.0 / 255.0, alpha: 1.0)
  }
  
  @nonobjc public class var whiteTwo: UIColor {
    return UIColor(white: 251.0 / 255.0, alpha: 1.0)
  }
  
  @nonobjc public class var whiteThree: UIColor {
    return UIColor(white: 233.0 / 255.0, alpha: 1.0)
  }
  
  @nonobjc public class var gunmetal: UIColor {
    return UIColor(red: 89.0 / 255.0, green: 94.0 / 255.0, blue: 96.0 / 255.0, alpha: 1.0)
  }
  
  @nonobjc public class var bluishGrey: UIColor {
    return UIColor(red: 127.0 / 255.0, green: 136.0 / 255.0, blue: 139.0 / 255.0, alpha: 1.0)
  }
  
  @nonobjc public class var greenishTeal: UIColor {
    return UIColor(red: 52.0 / 255.0, green: 191.0 / 255.0, blue: 140.0 / 255.0, alpha: 1.0)
  }
  
  @nonobjc public class var greenishTealTwo: UIColor {
    return UIColor(red: 52.0 / 255.0, green: 191.0 / 255.0, blue: 163.0 / 255.0, alpha: 1.0)
  }
  
  @nonobjc class var blueGrey: UIColor {
    return UIColor(red: 125.0 / 255.0, green: 140.0 / 255.0, blue: 164.0 / 255.0, alpha: 1.0)
  }
  
  @nonobjc public class var lightishRed: UIColor {
    return UIColor(red: 243.0 / 255.0, green: 54.0 / 255.0, blue: 73.0 / 255.0, alpha: 1.0)
  }
  
  @nonobjc public class var butterscotch: UIColor {
    return UIColor(red: 1.0, green: 186.0 / 255.0, blue: 61.0 / 255.0, alpha: 1.0)
  }
  
  @nonobjc public class var fadedPink: UIColor {
    return UIColor(red: 204.0 / 255.0, green: 168.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0)
  }
  
  @nonobjc public class var heather: UIColor {
    return UIColor(red: 161.0 / 255.0, green: 146.0 / 255.0, blue: 178.0 / 255.0, alpha: 1.0)
  }
  
  @nonobjc public class var lightNavyBlue: UIColor {
    return UIColor(red: 51.0 / 255.0, green: 87.0 / 255.0, blue: 156.0 / 255.0, alpha: 1.0)
  }
  
  @nonobjc public class var whiteFour: UIColor {
    return UIColor(white: 239.0 / 255.0, alpha: 1.0)
  }
  
  @nonobjc public class var whiteFive: UIColor {
    return UIColor(white: 249.0 / 255.0, alpha: 1.0)
  }
  
  @nonobjc public class var whiteSix: UIColor {
    return UIColor(white: 245.0 / 255.0, alpha: 1.0)
  }
  
  @nonobjc public class var coral: UIColor {
    return UIColor(red: 1.0, green: 80.0 / 255.0, blue: 80.0 / 255.0, alpha: 1.0)
  }
  
  @nonobjc class var marigold: UIColor {
    return UIColor(red: 1.0, green: 200.0 / 255.0, blue: 0.0, alpha: 1.0)
  }
  
  @nonobjc public class var gradientMetallicBlue: [CGColor] {
    return [UIColor(hex: 0x528090).cgColor,
            UIColor(hex: 0x425258).cgColor]
  }
  
  @nonobjc public class var gradientGray: [CGColor] {
    return [UIColor(hex: 0xbababa).cgColor,
            UIColor(hex: 0x909090).cgColor]
  }
  
  @nonobjc public class var gradientBlueGray: [CGColor] {
    return [UIColor(hex: 0x84abac).cgColor,
            UIColor(hex: 0x3e6566).cgColor]
  }
  
  @nonobjc public class var gradientBlue: [UIColor] {
    return [UIColor(hex: 0xFFFFFF),
            UIColor(hex: 0xF9FCFD),
            UIColor(hex: 0xF5F8F9),
            UIColor(hex: 0xE9F0F1),
            UIColor(hex: 0xE3ECEE)]
  }
  
  @nonobjc public class var gradientProductBlue: [CGColor] {
    return [UIColor(hex: 0xacd0ce).cgColor,
            UIColor(hex: 0x84abac).cgColor]
    
  }
}
