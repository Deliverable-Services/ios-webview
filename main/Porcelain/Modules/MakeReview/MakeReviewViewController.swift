//
//  MakeReviewViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 13/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import Cosmos
import R4pidKit

public final class MakeReviewViewController: UIViewController {
  @IBOutlet private weak var scrollView: UIScrollView!
  @IBOutlet private weak var ratingTitleLabel: UILabel! {
    didSet {
      ratingTitleLabel.font = .openSans(style: .semiBold(size: 18.0))
      ratingTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var ratingView: CosmosView! {
    didSet {
      ratingView.settings.emptyImage = .icEmptyStar
      ratingView.settings.filledImage = .icFullStar
      ratingView.rating = 0.0
    }
  }
  @IBOutlet private weak var nameTextField: MakeReviewInputView! {
    didSet {
      nameTextField.title = "Name"
      nameTextField.textContentType = .name
      nameTextField.type = .text
    }
  }
  @IBOutlet private weak var emailTextField: MakeReviewInputView! {
    didSet {
      emailTextField.title = "Email"
      emailTextField.textContentType = .emailAddress
      emailTextField.type = .email
    }
  }
  @IBOutlet private weak var reviewTitleLabel: UILabel! {
    didSet {
      reviewTitleLabel.font = .openSans(style: .regular(size: 12.0))
      reviewTitleLabel.textColor = .bluishGrey
      reviewTitleLabel.text = "Your review"
    }
  }
  @IBOutlet private weak var reviewTextView: DesignableTextView! {
    didSet {
      reviewTextView.typingAttributes = defaultTypingAttributes
      reviewTextView.tintColor = .gunmetal
      reviewTextView.textContainer.lineFragmentPadding = 0
      reviewTextView.delegate = self
    }
  }
  @IBOutlet private weak var submitButton: DesignableButton! {
    didSet {
      submitButton.cornerRadius = 7.0
      submitButton.backgroundColor = .greyblue
      submitButton.setAttributedTitle(
        "SUBMIT".attributed.add(.appearance(DialogButtonAttributedTitleAppearance())),
        for: .normal)
    }
  }
  
  private lazy var defaultTypingAttributes = NSAttributedString.createAttributesString([.appearance(DefaultTextViewTextAppearance())])
  
  public var reviewText: String? {
    get {
      return reviewTextView.text
    }
    set {
      reviewTextView.text = newValue
      if reviewTextView.text?.isEmpty ?? true {
        textViewSetInactive(animated: false)
      } else {
        textViewSetActive(animated: false)
      }
    }
  }
  
  private var viewModel: MakeReviewViewModelProtocol!
  
  fileprivate func configure(viewModel: MakeReviewViewModelProtocol) {
    self.viewModel = viewModel
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBar.isTranslucent = true
    navigationController?.navigationBar.backgroundColor = .clear
    setStatusBarNav(style: .default)
  }
  
  @IBAction
  private func submitTapped(sender: Any) {
    viewModel.submit()
  }
}

extension MakeReviewViewController {
  private func textViewSetActive(animated: Bool) {
    if animated {
      UIView.animate(withDuration: 0.3) {
        self.reviewTitleLabel.transform = .init(translationX: 0.0, y: -13.0)
        self.reviewTextView.transform = .init(translationX: 0.0, y: 12.0)
      }
    } else {
      reviewTitleLabel.transform = .init(translationX: 0.0, y: -13.0)
      reviewTextView.transform = .init(translationX: 0.0, y: 12.0)
    }
  }
  
  private func textViewSetInactive(animated: Bool) {
    if animated {
      UIView.animate(withDuration: 0.3) {
        self.reviewTitleLabel.transform = .init(translationX: 0.0, y: 0.0)
        self.reviewTextView.transform = .init(translationX: 0.0, y: 0.0)
      }
    } else {
      reviewTitleLabel.transform = .init(translationX: 0.0, y: 0.0)
      reviewTextView.transform = .init(translationX: 0.0, y: 0.0)
    }
  }
}

// MARK: - NavigationProtocol
extension MakeReviewViewController: NavigationProtocol {
}

// MARK: - ControllerProtocol
extension MakeReviewViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("MakeReviewViewController segueIdentifier not set")
  }
  
  public func setupUI() {
    view.backgroundColor = .white
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: .icLeftArrow, selector: #selector(popOrDismissViewController))
    viewModel.attachView(self)
    viewModel.initialize()
  }
  
  public func setupObservers() {
    ratingView.didFinishTouchingCosmos = { [weak self] (rating) in
      guard let `self` = self else { return }
      self.viewModel.rating = rating
    }
    nameTextField.didUpdate = { [weak self] in
      guard let `self` = self else { return }
      self.viewModel.name = self.nameTextField.text
    }
    emailTextField.didUpdate = { [weak self] in
      guard let `self` = self else { return }
      self.viewModel.email = self.emailTextField.text
    }
    observeKeyboard()
  }
}

// MARK: - MakeReviewView
extension MakeReviewViewController: MakeReviewView {
  public func reload() {
    nameTextField.text = viewModel.name
    emailTextField.text = viewModel.email
  }
  
  public func showLoading() {
    appDelegate.showLoading()
  }
  
  public func hideLoading() {
    appDelegate.hideLoading()
  }
  
  public func updateSubmit(enabled: Bool) {
    var appearance = DialogButtonAttributedTitleAppearance()
    appearance.color = enabled ? .white: .bluishGrey
    submitButton.backgroundColor = enabled ? .greyblue: .whiteThree
    submitButton.setAttributedTitle(
      "SUBMIT".attributed.add(.appearance(appearance)),
      for: .normal)
  }
  
  public func showError(message: String?) {
    showAlert(title: "Oops!", message: message)
  }
  
  public func showSuccess(message: String?) {
    let dialogHandler = DialogHandler()
    dialogHandler.message = message
    dialogHandler.actions = [.confirm(title: "GOT IT!")]
    dialogHandler.actionCompletion = { [weak self] (_, dialogView) in
      guard let `self` = self else { return }
      dialogView.dismiss()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.popOrDismissViewController()
      }
    }
    DialogViewController.load(handler: dialogHandler).show(in: self)
  }
}

// MARK: - KeyboardHandlerProtocol
extension MakeReviewViewController: KeyboardHandlerProtocol {
  public func keyboardWillHide(_ notification: Notification) {
    scrollView.contentInset = .zero
  }
  
  public func keyboardWillShow(_ notification: Notification) {
    scrollView.contentInset = UIEdgeInsets(
      top: 0.0,
      left: 0.0,
      bottom: evaluateKeyboardFrameFromNotification(notification).height,
      right: 0.0)
  }
}

// MARK: - UITextViewDelegate
extension MakeReviewViewController: UITextViewDelegate {
  public func textViewDidChange(_ textView: UITextView) {
    viewModel.review = textView.text
  }
  
  public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    textView.typingAttributes = defaultTypingAttributes
    textViewSetActive(animated: true)
    return true
  }
  
  public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
    if textView.text.isEmpty {
      textViewSetInactive(animated: true)
    }
    return true
  }
}

public protocol MakeReviewPresenterProtocol {
}

extension MakeReviewPresenterProtocol where Self: ControllerProtocol & UIViewController {
  public func showMakeReview(type: MakeReviewType, animated: Bool = true) {
    let makeReviewViewController = UIStoryboard.get(.makeReview).getController(MakeReviewViewController.self)
    makeReviewViewController.configure(viewModel: MakeReviewViewModel(type: type))
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(makeReviewViewController, animated: animated)
    } else {
      let navigationController = NavigationController(rootViewController: makeReviewViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
  }
}
