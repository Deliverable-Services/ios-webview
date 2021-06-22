//
//  CheckoutSuccessViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 2/27/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct AttributedContentAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? = 0.45
  var alignment: NSTextAlignment? = .center
  var lineBreakMode: NSLineBreakMode? = .byWordWrapping
  var minimumLineHeight: CGFloat? = 28.0
  var font: UIFont? = .idealSans(style: .book(size: 18.0))
  var color: UIColor? = .gunmetal
}

public protocol CheckoutSuccessViewControllerDelegate: class {
  func checkoutSuccessViewControllerData(viewController: CheckoutSuccessViewController) -> OrderReceivedData?
  func checkoutSuccessViewControllerNavigationTapped(viewController: CheckoutSuccessViewController)
  func checkoutSuccessViewControllerNavigationType(viewController: CheckoutSuccessViewController) -> ShopCartNavigationButton.AppearanceType?
}

public final class CheckoutSuccessViewController: UIViewController {
  @IBOutlet private weak var contentLabel: UILabel!
  @IBOutlet private weak var actionContainerView: UIView! {
    didSet {
      actionContainerView.backgroundColor = .whiteFive
    }
  }
  @IBOutlet private weak var actionButton: ShopCartNavigationButton!
  
  fileprivate weak var delegate: CheckoutSuccessViewControllerDelegate?
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  private func initialize() {
    if let message = delegate?.checkoutSuccessViewControllerData(viewController: self)?.message {
      contentLabel.attributedText = message.attributed.add(.appearance(AttributedContentAppearance()))
    } else {
      contentLabel.attributedText = """
        Your order has been received and is now being processed. Your order details has been sent to your email.
        """.attributed.add(.appearance(AttributedContentAppearance()))
    }
    if let appearanceType = delegate?.checkoutSuccessViewControllerNavigationType(viewController: self) {
      actionButton.type = appearanceType
    } else {
      actionButton.type = .default(title: "CONTINUE SHOPPING", enabled: true)
    }
  }
  
  @IBAction private func actionTapped(_ sender: Any) {
    delegate?.checkoutSuccessViewControllerNavigationTapped(viewController: self)
  }
}

//MARK: - ControllerProtocol
extension CheckoutSuccessViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("CheckoutSuccessViewController segueIdentifier not set")
  }
  
  public func setupUI() {
    view.backgroundColor = .whiteFive
  }
  
  public func setupController() {
    initialize()
  }
  
  public func setupObservers() {
  }
}

public protocol CheckoutSuccessPresenterProtocol: CheckoutSuccessViewControllerDelegate {
}

extension CheckoutSuccessPresenterProtocol where Self: ControllerProtocol & UIViewController {
  public func showCheckoutSuccess(animated: Bool = true) {
    let checkoutSuccessViewController = UIStoryboard.get(.cart).getController(CheckoutSuccessViewController.self)
    checkoutSuccessViewController.delegate = self
    checkoutSuccessViewController.modalPresentationStyle = .fullScreen
    present(checkoutSuccessViewController, animated: animated) {
    }
  }
}
