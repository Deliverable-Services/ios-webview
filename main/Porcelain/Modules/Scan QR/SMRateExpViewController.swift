//
//  SMRateExpViewController.swift
//  Porcelain
//
//  Created by Justine Rangel on 09/01/2019.
//  Copyright © 2019 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import Cosmos
import R4pidKit

public typealias SMRateExpCompletion = (String, Double) -> Void

private struct AttributedContentTextAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? {
    return 0.5
  }
  var alignment: NSTextAlignment? {
    return .center
  }
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat? {
    return 26.0
  }
  var font: UIFont? {
    return .openSans(style: .regular(size: 16.0))
  }
  var color: UIColor? {
    return .gunmetal
  }
}

public final class SMRateExpViewController: UIViewController {
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .semiBold(size: 20.0))
      titleLabel.textColor = .gunmetal
      titleLabel.text = "Rate your experience"
    }
  }
  @IBOutlet private weak var contentLabel: UILabel! {
    didSet {
      contentLabel.attributedText = "Help us to improve our service\nby rating us".attributed.add(.appearance(AttributedContentTextAppearance()))
    }
  }
  @IBOutlet private weak var rateView: CosmosView! {
    didSet {
      rateView.rating = 0.0
    }
  }
  @IBOutlet private weak var closeButton: UIButton!

  public var appointmentID: String?
  public var didSelectRating: SMRateExpCompletion?
  public var didDismiss: VoidCompletion?
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  @IBAction private func closeTapped(_ sender: Any) {
    dismissPresenter()
    didDismiss?()
  }
}

// MARK: - ControllerProtocol
extension SMRateExpViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("segueIdentifier not set")
  }
  
  public func setupUI() {
    view.backgroundColor = .white
  }
  
  public func setupController() {
  }
  
  public func setupObservers() {
    rateView.didFinishTouchingCosmos = { [weak self] (rating) in
      guard let `self` = self else { return }
      guard let appointmentID = self.appointmentID else { return }
      self.dismissPresenter()
      self.didSelectRating?(appointmentID, rating)
    }
  }
}

// MARK: - PresentedControllerProtocol
extension SMRateExpViewController: PresentedControllerProtocol {
  public var presenterType: PresenterType? {
    return .popover(size: CGSize(width: 327.0, height: 187.0))
  }
}

extension SMRateExpViewController {
  public static func load(appointmentID: String, ratingCompletion: @escaping SMRateExpCompletion, dismissCompletion: @escaping VoidCompletion) -> SMRateExpViewController {
    let smRateExpViewController = UIStoryboard.get(.scanQR).getController(SMRateExpViewController.self)
    smRateExpViewController.appointmentID = appointmentID
    smRateExpViewController.didSelectRating = ratingCompletion
    smRateExpViewController.didDismiss = dismissCompletion
    return smRateExpViewController
  }
  
  @discardableResult
  public func show(in vc: UIViewController) -> SMRateExpViewController {
    var appearance = PresenterAppearance.default
    appearance.shadowAppearance = nil
    PresenterViewController.show(
      presentVC: self,
      settings: [
        .panToDismiss,
        .tapToDismiss,
        .appearance(appearance)],
      onVC: vc)
    return self
  }
}
