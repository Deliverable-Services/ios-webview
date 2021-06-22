//
//  NotificationsTCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 10/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct NotifMessageAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? {
    return 0.46
  }
  var alignment: NSTextAlignment?
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat? {
    return 18.0
  }
  var font: UIFont? {
    return .openSans(style: .regular(size: 13.0))
  }
  var color: UIColor? {
    return .bluishGrey
  }
}

public final class NotificationsTCell: UITableViewCell, AppNotificationProtocol {
  @IBOutlet private weak var containerView: DesignableView! {
    didSet {
      containerView.cornerRadius = 7.0
      containerView.borderColor = .whiteThree
      containerView.borderWidth = 1.0
    }
  }
  @IBOutlet private weak var indicatorView: DesignableView! {
    didSet {
      indicatorView.cornerRadius = 4.0
      indicatorView.backgroundColor = .coral
    }
  }
  @IBOutlet private weak var dateLabel: UILabel! {
    didSet {
      dateLabel.font = .openSans(style: .semiBold(size: 12.0))
      dateLabel.textColor = .lightNavy
    }
  }
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .semiBold(size: 14.0))
      titleLabel.textColor = .lightNavy
    }
  }
  @IBOutlet private weak var messageLabel: UILabel! {
    didSet {
      messageLabel.font = .openSans(style: .regular(size: 13.0))
      messageLabel.textColor = .bluishGrey
    }
  }
  
  public var notification: AppNotification? {
    didSet {
      dateLabel.text = dateCreated?.toString(WithFormat: "MMMM d, yyyy | h:mm a")
      titleLabel.text = notificationTitle
      titleLabel.textColor = isRead ? .bluishGrey: .lightNavy
      messageLabel.attributedText = notificationMessage?.attributed.add(.appearance(NotifMessageAppearance()))
      updateUI()
    }
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    updateUI()
  }
  
  private func updateUI() {
    if isRead {
      dateLabel.font = .openSans(style: .regular(size: 12.0))
      dateLabel.textColor = .bluishGrey
      containerView.backgroundColor = .clear
      containerView.cornerRadius = 7.0
      containerView.borderColor = .whiteThree
      containerView.borderWidth = 1.0
      containerView.removeShadow()
      indicatorView.isHidden = true
    } else {
      dateLabel.font = .openSans(style: .semiBold(size: 12.0))
      dateLabel.textColor = .lightNavy
      containerView.backgroundColor = .white
      containerView.borderWidth = 0.0
      containerView.addShadow(appearance: .default)
      indicatorView.isHidden = false
    }
  }
}

// MARK: - CellProtocol
extension NotificationsTCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 96.0)
  }
}
