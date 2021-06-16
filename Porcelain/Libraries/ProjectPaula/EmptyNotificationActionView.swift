//
//  EmptyNotificationActionView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 29/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public struct EmptyNotificationActionData {
  var title: String?
  var titleNumberOfLines: Int = 0
  var subtitle: String?
  var subtitleNumberOfLines: Int = 0
  var action: String?
  
  public init(title: String?, titleNumberOfLines: Int = 0, subtitle: String?, subtitleNumberOfLines: Int = 0, action: String?) {
    self.title = title
    self.titleNumberOfLines = titleNumberOfLines
    self.subtitle = subtitle
    self.subtitleNumberOfLines = subtitleNumberOfLines
    self.action = action
  }
}

private struct EmptyNotificationTitleAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? = 0.5
  var alignment: NSTextAlignment? = .center
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat? = 22.0
  var font: UIFont? = .openSans(style: .regular(size: 14.0))
  var color: UIColor? = .bluishGrey
}

public enum EmptyNotificationActionType {
  case centered(data: EmptyNotificationActionData)
  case margin(data: EmptyNotificationActionData)
  case horizontal(data: EmptyNotificationActionData)
  
  public var data: EmptyNotificationActionData {
    switch self {
    case .centered(let data):
      return data
    case .margin(let data):
      return data
    case .horizontal(let data):
      return data
    }
  }
  
  public var attributedTitle: NSAttributedString? {
    var appearance = EmptyNotificationTitleAppearance()
    switch self {
    case .centered(let data):
      appearance.characterSpacing = 0.5
      appearance.alignment = .center
      appearance.minimumLineHeight = 22.0
      appearance.lineBreakMode = .byTruncatingTail
      appearance.font = .openSans(style: .regular(size: 14.0))
      appearance.color = .bluishGrey
      return data.title?.attributed.add(.appearance(appearance))
    case .margin(let data):
      appearance.characterSpacing = 0.0
      appearance.alignment = .center
      appearance.minimumLineHeight = 22.0
      appearance.lineBreakMode = .byTruncatingTail
      appearance.font = .openSans(style: .regular(size: 13.0))
      appearance.color = .bluishGrey
      return data.title?.attributed.add(.appearance(appearance))
    case .horizontal(let data):
      appearance.characterSpacing = 0.0
      appearance.alignment = .left
      appearance.minimumLineHeight = nil
      appearance.lineBreakMode = .byTruncatingTail
      appearance.font = .openSans(style: .semiBold(size: 13.0))
      appearance.color = .white
      return data.title?.attributed.add(.appearance(appearance))
    }
  }
  
  public var titleNumberOfLines: Int {
    switch self {
    case .centered(let data):
      return data.titleNumberOfLines
    case .margin(let data):
      return data.titleNumberOfLines
    case .horizontal(let data):
      return data.titleNumberOfLines
    }
  }
  
  public var attributedSubtitle: NSAttributedString? {
    var appearance = EmptyNotificationTitleAppearance()
    switch self {
    case .centered(let data):
      appearance.characterSpacing = 0.5
      appearance.alignment = .center
      appearance.minimumLineHeight = 0.0
      appearance.font = .openSans(style: .regular(size: 14.0))
      appearance.color = .bluishGrey
      return data.subtitle?.attributed.add(.appearance(appearance))
    case .margin(let data):
      appearance.characterSpacing = 0.0
      appearance.alignment = .left
      appearance.minimumLineHeight = 0.0
      appearance.font = .openSans(style: .regular(size: 13.0))
      appearance.color = .bluishGrey
      return data.subtitle?.attributed.add(.appearance(appearance))
    case .horizontal(let data):
      appearance.characterSpacing = 0.0
      appearance.alignment = .left
      appearance.minimumLineHeight = nil
      appearance.font = .openSans(style: .regular(size: 11.5))
      appearance.color = .white
      return data.subtitle?.attributed.add(.appearance(appearance))
    }
  }
  
  public var subtitleNumberOfLines: Int {
    switch self {
    case .centered(let data):
      return data.subtitleNumberOfLines
    case .margin(let data):
      return data.subtitleNumberOfLines
    case .horizontal(let data):
      return data.subtitleNumberOfLines
    }
  }
  
  public var attributedActionTitle: NSAttributedString? {
    var appearance = EmptyNotificationTitleAppearance()
    switch self {
    case .centered(let data):
      appearance.characterSpacing = 1.0
      appearance.alignment = nil
      appearance.lineBreakMode = nil
      appearance.minimumLineHeight = nil
      appearance.font = .idealSans(style: .book(size: 14.0))
      appearance.color = .white
      return data.action?.attributed.add(.appearance(appearance))
    case .margin(let data):
      appearance.characterSpacing = 1.0
      appearance.alignment = nil
      appearance.lineBreakMode = nil
      appearance.minimumLineHeight = nil
      appearance.font = .idealSans(style: .book(size: 14.0))
      appearance.color = .white
      return data.action?.attributed.add(.appearance(appearance))
    case .horizontal(let data):
      appearance.characterSpacing = 0.0
      appearance.alignment = nil
      appearance.lineBreakMode = nil
      appearance.minimumLineHeight = nil
      appearance.font = .openSans(style: .regular(size: 11.0))
      appearance.color = .white
      return data.action?.attributed.add(.appearance(appearance))
    }
  }
}

public protocol EmptyNotificationActionIndicatorProtocol: class {
  var emptyNotificationActionView: EmptyNotificationActionView? { get set }
  
  func emptyNotificationActionTapped(data: EmptyNotificationActionData)
}

extension EmptyNotificationActionIndicatorProtocol {
  public func showEmptyNotificationActionOnView(_ view: UIView, type: EmptyNotificationActionType, animated: Bool = true) {
    if emptyNotificationActionView == nil {
      let emptyNotificationActionView = EmptyNotificationActionView(frame: .zero)
      emptyNotificationActionView.actionDidTapped = { [weak self] (data) in
        guard let `self` = self else { return }
        self.emptyNotificationActionTapped(data: data)
      }
      view.addSubview(emptyNotificationActionView)
      emptyNotificationActionView.addContainerBoundsResizingMask(view)
      self.emptyNotificationActionView = emptyNotificationActionView
    }
    emptyNotificationActionView?.isHidden = false
    if animated {
      emptyNotificationActionView?.alpha = 0.0
      UIView.animate(withDuration: 0.3, animations: {
        self.emptyNotificationActionView?.alpha = 1.0
      }, completion: { (_) in
      })
    }
    emptyNotificationActionView?.type = type
  }
  
  public func hideEmptyNotificationAction(animated: Bool = true) {
    if animated {
      emptyNotificationActionView?.alpha = 1.0
      UIView.animate(withDuration: 0.3, animations: {
        self.emptyNotificationActionView?.alpha = 0.0
      }, completion: { (_) in
        self.emptyNotificationActionView?.isHidden = true
      })
    } else {
      emptyNotificationActionView?.isHidden = true
    }
  }
}

public final class EmptyNotificationActionView: UIView, ActivityIndicatorProtocol {
  public var activityIndicatorView: UIActivityIndicatorView? {
    didSet {
      activityIndicatorView?.color = .bluishGrey
      activityIndicatorView?.backgroundColor =  .clear
    }
  }
  
  @IBOutlet private weak var view: UIView!
  @IBOutlet private weak var contentStack: UIStackView!
  @IBOutlet private weak var descriptionStack: UIStackView!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var subtitleLabel: UILabel!
  @IBOutlet private weak var actionButton: DesignableButton!
  @IBOutlet private weak var actionHeightConstraint: NSLayoutConstraint!
  
  public var type: EmptyNotificationActionType? {
    didSet {
      guard let type = type else {
        isHidden = true
        return
      }
      isHidden = false
      if let attributedTitle = type.attributedTitle {
        titleLabel.isHidden = false
        titleLabel.numberOfLines = type.titleNumberOfLines
        titleLabel.attributedText = attributedTitle
      } else {
        titleLabel.isHidden = true
      }
      if let attributedSubtitle = type.attributedSubtitle {
        subtitleLabel.isHidden = false
        subtitleLabel.numberOfLines = type.subtitleNumberOfLines
        subtitleLabel.attributedText = attributedSubtitle
      } else {
        subtitleLabel.isHidden = true
      }
      if let attributedActionTitle = type.attributedActionTitle {
        actionButton.isHidden = false
        actionButton.setAttributedTitle(attributedActionTitle, for: .normal)
      } else {
        actionButton.isHidden = true
      }
      switch type {
      case .centered:
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = 24.0
        descriptionStack.alignment = .center
        descriptionStack.spacing = 16.0
        actionButton.removeShadow()
        actionButton.cornerRadius = 24.0
        actionButton.borderColor = .clear
        actionButton.borderWidth = 0.0
        actionButton.backgroundColor = .lightNavy
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
        actionHeightConstraint.constant = 48.0
      case .margin:
        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.spacing = 24.0
        descriptionStack.alignment = .center
        descriptionStack.spacing = 16.0
        var appearance: ShadowAppearance = .default
        appearance.fillColor = .greyblue
        actionButton.addShadow(appearance: appearance)
        actionButton.backgroundColor = .clear
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
        actionHeightConstraint.constant = 48.0
      case .horizontal:
        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.spacing = 8.0
        descriptionStack.alignment = .leading
        descriptionStack.spacing = 0.0
        actionButton.removeShadow()
        actionButton.cornerRadius = 14.0
        actionButton.borderColor = .white
        actionButton.borderWidth = 1.0
        actionButton.backgroundColor = .clear
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 12.0, bottom: 0.0, right: 12.0)
        actionHeightConstraint.constant = 28.0
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.5
        subtitleLabel.adjustsFontSizeToFitWidth = true
      }
    }
  }
  
  public var isLoading: Bool = false   {
    didSet {
      if isLoading {
        showActivityOnView(self)
        view.isHidden = true
      } else {
        hideActivity()
        view.isHidden = false
      }
    }
  }
  
  public var actionDidTapped: ((EmptyNotificationActionData) -> Void)?
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    guard let type = type else { return }
    switch type {
    case .margin:
      var appearance: ShadowAppearance = .default
      appearance.fillColor = .greyblue
      actionButton.addShadow(appearance: appearance)
    default:
      actionButton.removeShadow()
    }
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    commonInit()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    commonInit()
  }
  
  private func commonInit() {
    loadNib(EmptyNotificationActionView.self)
    addSubview(view)
    view.addContainerBoundsResizingMask()
  }
  
  @IBAction private func actionTapped(_ sender: Any) {
    guard let data = type?.data else { return }
    actionDidTapped?(data)
  }
}
