//
//  DialogViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 07/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public struct DialogTitleAppearance: AttributedStringAppearanceProtocol {
  public var characterSpacing: Double? {
    return 0.62
  }
  public var alignment: NSTextAlignment? {
    return .center
  }
  public var lineBreakMode: NSLineBreakMode? {
    return .byWordWrapping
  }
  public var minimumLineHeight: CGFloat? {
    return 26.0
  }
  public var font: UIFont? {
    return .openSans(style: .semiBold(size: 20.0))
  }
  public var color: UIColor? {
    return .gunmetal
  }
}

public struct DialogMessageAppearance: AttributedStringAppearanceProtocol {
  public var characterSpacing: Double? {
    return 0.5
  }
  public var alignment: NSTextAlignment? {
    return .center
  }
  public var lineBreakMode: NSLineBreakMode? {
    return .byWordWrapping
  }
  public var minimumLineHeight: CGFloat? {
    return 26.0
  }
  public var font: UIFont? {
    return .openSans(style: .regular(size: 16.0))
  }
  public var color: UIColor? {
    return .bluishGrey
  }
}

public protocol DialogAppearanceProtocol {
  var titleAppearance: AttributedStringAppearanceProtocol { get }
  var messageAppearance: AttributedStringAppearanceProtocol { get }
  var backgroundColor: UIColor { get }
  var cornerRadius: CGFloat { get }
}

public struct DialogAppearance: DialogAppearanceProtocol {
  public var titleAppearance: AttributedStringAppearanceProtocol {
    return DialogTitleAppearance()
  }
  public var messageAppearance: AttributedStringAppearanceProtocol {
    return DialogMessageAppearance()
  }
  public var backgroundColor: UIColor {
    return .white
  }
  
  public var cornerRadius: CGFloat {
    return 7.0
  }
}

public struct DialogAction {
  public struct Appearance: AttributedStringAppearanceProtocol, Designable {
    public var characterSpacing: Double?
    public var alignment: NSTextAlignment?
    public var lineBreakMode: NSLineBreakMode?
    public var minimumLineHeight: CGFloat?
    public var font: UIFont?
    public var color: UIColor?
    public var cornerRadius: CGFloat =  7.0
    public var borderWidth: CGFloat =  0.0
    public var borderColor: UIColor = .clear
    public var backgroundColor: UIColor = .white
    public var height: CGFloat = 48.0
  }
  
  let title: String
  let appearance: Appearance
  init(title: String, appearance: Appearance) {
    self.title = title
    self.appearance = appearance
  }
  
  public static func cancel(title: String) -> DialogAction {
    let buttonAppearance = DialogButtonAttributedTitleAppearance(color: .greyblue)
    var appearance = Appearance()
    appearance.characterSpacing = buttonAppearance.characterSpacing
    appearance.font = buttonAppearance.font
    appearance.color = buttonAppearance.color
    appearance.cornerRadius = 7.0
    appearance.borderWidth = 1.0
    appearance.borderColor = .greyblue
    appearance.backgroundColor = .white
    return DialogAction(title: title, appearance: appearance)
  }
  
  public static func confirm(title: String) -> DialogAction {
    let buttonAppearance = DialogButtonAttributedTitleAppearance(color: .white)
    var appearance = Appearance()
    appearance.characterSpacing = buttonAppearance.characterSpacing
    appearance.font = buttonAppearance.font
    appearance.color = buttonAppearance.color
    appearance.cornerRadius = 7.0
    appearance.borderWidth = 0.0
    appearance.borderColor = .clear
    appearance.backgroundColor = .greyblue
    return DialogAction(title: title, appearance: appearance)
  }
}

public protocol DialogView {
  func dismiss()
}

public typealias DialogActionCompletion = (DialogAction, DialogView) -> Void

public final class DialogHandler {
  
  /// may set new appearance by conforming with DialogAppearanceProtocol
  public var appearance: DialogAppearanceProtocol = DialogAppearance()
  public var title: String?
  public var message: String?
  
  /// take priority with message and overrides it
  public var attributedMessage: NSAttributedString?
  
  /// confirm GOT IT! by default, must have atleast 1 action  to work
  public var actions: [DialogAction] = [.confirm(title: "GOT IT!")]
  
  /// nil by defaul, set this var if want to handle it
  public var actionCompletion: DialogActionCompletion?
}

public final class DialogViewController: UIViewController  {
  @IBOutlet private weak var scrollView: ObservingContentScrollView!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var textView: DesignableTextView!
  @IBOutlet private weak var buttonStack: UIStackView!
  
  private var handler: DialogHandler!
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let title = handler.title {
      titleLabel.isHidden = false
      titleLabel.attributedText = title.attributed.add(.appearance(handler.appearance.titleAppearance))
    } else {
      titleLabel.isHidden = true
    }
    if let attributedMessage = handler.attributedMessage {
      textView.attributedText = attributedMessage
    } else {
      if let message = handler.message {
        textView.isHidden = false
        textView.attributedText = message.attributed.add(.appearance(handler.appearance.messageAppearance))
      } else {
        textView.isHidden = true
      }
    }
    generateActions()
  }
  
  private func generateActions() {
    guard !handler.actions.isEmpty else {
      fatalError("Empty action is not supported")
    }
    buttonStack.removeAllArrangedSubviews()
    if handler.actions.count == 2 {
      let horizontalBStack = UIStackView()
      horizontalBStack.axis = .horizontal
      horizontalBStack.distribution = .fillEqually
      horizontalBStack.spacing = 13.0
      handler.actions.forEach { (action) in
        let button = DialogButton(action: action)
        button.addTarget(self, action: #selector(actionTapped(_:)), for: .touchUpInside)
        horizontalBStack.addArrangedSubview(button)
      }
      buttonStack.addArrangedSubview(horizontalBStack)
    } else {
      handler.actions.forEach { (action) in
        let button = DialogButton(action: action)
        button.addTarget(self, action: #selector(actionTapped(_:)), for: .touchUpInside)
        buttonStack.addArrangedSubview(button)
      }
    }
    buttonStack.layoutIfNeeded()
  }
  
  @objc
  private func actionTapped(_ sender: DialogButton) {
    guard let action = sender.action, let actionCompletion = handler.actionCompletion else {
      dismissPresenter()
      return
    }
    actionCompletion(action, self)
  }
}

// MARK: - ControllerProtocol
extension DialogViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("DialogViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
  }
  
  public func setupObservers() {
    scrollView.observeContentSizeUpdates = { [weak self] (_) in
      guard let `self` = self else { return }
      self.reloadPresenter()
    }
  }
}

// MARK: - DialogView
extension DialogViewController: DialogView  {
  public func dismiss() {
    dismissPresenter()
  }
}

// MARK: - PresentedControllerProtocol
extension DialogViewController: PresentedControllerProtocol {
  public var presenterType: PresenterType? {
    return .popover(size: CGSize(width: 327.0, height: scrollView.contentSize.height))
  }
}

extension StoryboardName {
  public static let dialog = "Dialog"
}

extension DialogViewController {
  public static func load(handler: DialogHandler) -> DialogViewController {
    let dialogViewController = UIStoryboard.get(.dialog).getController(DialogViewController.self)
    dialogViewController.handler = handler
    return dialogViewController
  }
  
  public func show(in vc: UIViewController) {
    PresenterViewController.show(
      presentVC: self,
      settings: [
        .appearance(.default)],
      onVC: vc)
  }
}

private final class DialogButton: DesignableButton {
  public private(set) var action: DialogAction?
  convenience init(action: DialogAction) {
    self.init(type: .system)
    
    self.action = action
    setAttributedTitle(action.title.attributed.add(.appearance(action.appearance)), for: .normal)
    
    addHeightConstraint(action.appearance.height)
    if action.appearance.borderWidth > 0 {
      backgroundColor = action.appearance.backgroundColor
      cornerRadius = action.appearance.cornerRadius
      borderWidth = action.appearance.borderWidth
      borderColor = action.appearance.borderColor
    } else {
      backgroundColor = .clear
      shadowAppearance = ShadowAppearance.default
      shadowAppearance?.cornerRadius = action.appearance.cornerRadius
      shadowAppearance?.fillColor = action.appearance.backgroundColor
    }
  }
}
