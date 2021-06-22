//
//  SegmentView.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 04/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import UIKit

class SegmentView: UIView {
  static var estimatedHeight: CGFloat = 48
  
  @IBOutlet weak var titleButton: UIButton!
  @IBOutlet weak var bottomLine: UIView!
  
  @IBAction func segmentCicked() {
    self.segmentClickedBlock?()
  }
  
  var segmentClickedBlock: (() -> ())?
  
  func selectSegment() {
    self.bottomLine.isHidden = false
  }
  
  func deselectSegment() {
    self.bottomLine.isHidden = true
  }
}
