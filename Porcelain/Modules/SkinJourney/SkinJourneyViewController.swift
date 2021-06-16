//
//  SkinJourneyViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 2/6/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class SkinJourneyViewController: UIViewController {
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
}

// MARK: - ControllerProtocol
extension SkinJourneyViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("SkinJourneyViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
  }
  
  public func setupObservers() {
  }
}
