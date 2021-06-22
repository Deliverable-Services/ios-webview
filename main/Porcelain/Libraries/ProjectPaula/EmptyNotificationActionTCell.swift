//
//  EmptyNotificationActionTCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 26/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class EmptyNotificationActionTCell: UITableViewCell, EmptyNotificationActionIndicatorProtocol {
  public var emptyNotificationActionView: EmptyNotificationActionView?
  
  @IBOutlet private weak var errorContainerView: UIView!
  
  public var actionDidTapped: ((EmptyNotificationActionData) -> Void)?
  
  public var emptyNotificationActionData: EmptyNotificationActionData? {
    didSet {
      if let emptyNotificationActionData = emptyNotificationActionData  {
        showEmptyNotificationActionOnView(errorContainerView, type: .centered(data: emptyNotificationActionData))
      } else {
        hideEmptyNotificationAction()
      }
    }
  }
  
  public func emptyNotificationActionTapped(data: EmptyNotificationActionData) {
    actionDidTapped?(data)
  }
}

// MARK: - CellProtocol
extension EmptyNotificationActionTCell: CellProtocol {
}
