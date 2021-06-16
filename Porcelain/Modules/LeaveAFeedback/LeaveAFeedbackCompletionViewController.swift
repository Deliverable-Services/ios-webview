//
//  ReportAnIssueCompletionViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 03/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct AttributedDescriptionAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? {
    return 0.5
  }
  var alignment: NSTextAlignment? {
    return .center
  }
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat? {
    return 28.0
  }
  var font: UIFont? {
    return .idealSans(style: .book(size: 18.0))
  }
  var color: UIColor? {
    return .gunmetal
  }
}

public struct LeaveAFeedbackCompletionHandler {
  public var image: UIImage? = .icBigCheck
  public var message: String?
  public var completion: VoidCompletion?
}

public final class LeaveAFeedbackCompletionViewController: UIViewController {
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var descriptionLabel: UILabel!
  @IBOutlet private weak var gotItButton: DesignableButton! {
    didSet {
      gotItButton.cornerRadius = 7.0
      gotItButton.setAttributedTitle(
        "GOT IT!".attributed.add([.color(.white), .font(.openSans(style: .semiBold(size: 13.0)))]),
        for: .normal)
      gotItButton.backgroundColor = .greyblue
    }
  }
  
  public var handler: LeaveAFeedbackCompletionHandler!
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  @IBAction private func gotItTapped(_ sender: Any) {
    handler.completion?()
    dismissViewController()
  }
}

// MARK: - ControllerProtocol
extension LeaveAFeedbackCompletionViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    return "showLeaveAFeedbackCompletion"
  }
  
  public func setupUI() {
    imageView.image = handler.image
    descriptionLabel.attributedText = handler.message?.attributed.add(.appearance(AttributedDescriptionAppearance()))
  }
  
  public func setupController() {
  }
  
  public func setupObservers() {
  }
}

public protocol LeaveAFeedbackCompletionPresenterProtocol {
}

extension LeaveAFeedbackCompletionPresenterProtocol where Self: ControllerProtocol & UIViewController {
  public func showLeaveAFeedbackCompletion(handler: LeaveAFeedbackCompletionHandler) {
    let leaveAFeedbackCompletionVC = UIStoryboard.get(.feedback).getController(LeaveAFeedbackCompletionViewController.self)
    leaveAFeedbackCompletionVC.handler = handler
    present(leaveAFeedbackCompletionVC, animated: true) {
    }
  }
}
