//
//  AudioUtil.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 2/11/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import AudioToolbox

public enum SystemSound: UInt32 {
  case mailSent = 1001
  case smsSent1 = 1004
  case smsSent2 = 1016
  
  public func play() {
    AudioServicesPlaySystemSound(rawValue)
  }
}
