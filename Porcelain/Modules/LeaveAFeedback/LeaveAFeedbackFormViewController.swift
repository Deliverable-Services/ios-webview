//
//  LeaveAFeedbackFormViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 03/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import DTPhotoViewerController
import YPImagePicker

private struct AttributedTitleAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? {
    return 0.57
  }
  var alignment: NSTextAlignment? {
    return .center
  }
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat? {
    return 26.0
  }
  var font: UIFont? {
    return .idealSans(style: .book(size: 16.0))
  }
  var color: UIColor? {
    return .gunmetal
  }
}

private struct AttributedTextAppearance: AttributedStringAppearanceProtocol {
  public var characterSpacing: Double? {
    return 0.4
  }
  public var alignment: NSTextAlignment?
  public var lineBreakMode: NSLineBreakMode?
  public var minimumLineHeight: CGFloat? {
    return 20.0
  }
  public var font: UIFont? = .openSans(style: .regular(size: 13.0))
  public var color: UIColor? = .gunmetal
}

private struct ErrorIndicatorAppearance: ErrorIndicatorAppearanceProtocol {
  var font: UIFont = .openSans(style: .regular(size: 12.0))
  var color: UIColor = .coral
  var position: ErrorIndicatorPosition = .topLeft(offset: CGSize(width: 0.0, height: 3.0))
}

public final class LeaveAFeedbackFormViewController: UIViewController, ErrorIndicatorViewProtocol {
  public var errorAppearance: ErrorIndicatorAppearanceProtocol = ErrorIndicatorAppearance()
  public var errorContainerView: UIView = UIView()
  public var errorDescription: String?
  
  @IBOutlet private weak var scrollView: UIScrollView!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var choicesStack: UIStackView!
  @IBOutlet private weak var feedbackPlaceholder: UILabel! {
    didSet {
      feedbackPlaceholder.font = .openSans(style: .regular(size: 13.0))
      feedbackPlaceholder.textColor = .bluishGrey
      feedbackPlaceholder.text = "Enter your feedback here…"
    }
  }
  @IBOutlet private weak var feedbackTextView: DesignableTextView! {
    didSet {
      feedbackTextView.cornerRadius = 7.0
      feedbackTextView.borderColor = .whiteThree
      feedbackTextView.borderWidth = 1.0
      feedbackTextView.topMargin = 8.0
      feedbackTextView.leftMargin = 12.0
      feedbackTextView.rightMargin = 12.0
      feedbackTextView.bottomMargin = 8.0
      feedbackTextView.tintColor = .gunmetal
      feedbackTextView.typingAttributes = defaultTypingAttributes
      feedbackTextView.delegate = self
    }
  }
  @IBOutlet private weak var separatorView1: UIView!
  @IBOutlet private weak var attachmentCollectionView: AttachmentsCollectionView! {
    didSet {
      attachmentCollectionView.config = AttachmentsCollectionConfig(
        isInteractive: true,
        spacing: 8.0,
        rowSize: 4)
    }
  }
  @IBOutlet private weak var socialStack: UIStackView!
  @IBOutlet private weak var separatorView2: UIView!
  @IBOutlet private weak var allowShareButton: UIButton! {
    didSet {
      allowShareButton.setAttributedTitle(
        UIImage.icCheckBoxUnSelected.attributed.add(.baseline(offset: -3.0)).append(
          attrs: "    I am willing to share this as a testimonial".attributed.add([
            .color(.gunmetal),
            .font(.openSans(style: .regular(size: 12.0))),
            .baseline(offset: 3.0)])),
        for: .normal)
      allowShareButton.setAttributedTitle(
        UIImage.icCheckBoxSelected.attributed.add(.baseline(offset: -3.0)).append(
          attrs: "    I am willing to share this as a testimonial".attributed.add([
            .color(.gunmetal),
            .font(.openSans(style: .regular(size: 12.0))),
            .baseline(offset: 3.0)])),
        for: .selected)
    }
  }
  @IBOutlet private weak var infoDisclosureButton: UIButton! {
    didSet {
      infoDisclosureButton.tintColor = .lightNavy
    }
  }
  @IBOutlet private weak var shareButton: DesignableButton! {
    didSet {
      shareButton.cornerRadius = 7.0
      shareButton.borderWidth = 1.0
      shareButton.borderColor = .lightNavy
      shareButton.setAttributedTitle(
        UIImage.icShare.attributed.add(.baseline(offset: -3.0)).append(
          attrs: "  Share".attributed.add([
            .color(.lightNavy),
            .font(.openSans(style: .semiBold(size: 14.0))),
            .baseline(offset: 5.0)])),
        for: .normal)
    }
  }
  @IBOutlet private weak var submitButton: DesignableButton! {
    didSet {
      var appearance = FormSaveButtonAttributedTitleAppearance()
      appearance.color = .white
      submitButton.cornerRadius = 7.0
      submitButton.setAttributedTitle(viewModel.type.submitTitle.attributed.add(.appearance(appearance)), for: .normal)
      submitButton.backgroundColor = .greyblue
    }
  }
  
  private lazy var buttonChoices: [UIButton] = {
    return viewModel.type.choices.enumerated().map { (indx, title) -> UIButton in
      let button = UIButton(type: .custom)
      button.tag = indx
      button.contentHorizontalAlignment = .left
      button.setAttributedTitle(
        UIImage.icRadioUnselected.attributed.add(.baseline(offset: -3.0)).append(
          attrs: "    \(title)".attributed.add([
            .color(.gunmetal),
            .font(.openSans(style: .regular(size: 13.0))),
            .baseline(offset: 3.0)])),
        for: .normal)
      button.setAttributedTitle(
        UIImage.icRadioSelected.attributed.add(.baseline(offset: -3.0)).append(
          attrs: "    \(title)".attributed.add([
            .color(.gunmetal),
            .font(.openSans(style: .regular(size: 13.0))),
            .baseline(offset: 3.0)])),
        for: .selected)
      button.addTarget(self, action: #selector(choiceTapped(_:)), for: .touchUpInside)
      return button
    }
  }()
  
  private lazy var defaultTypingAttributes = NSAttributedString.createAttributesString([.appearance(AttributedTextAppearance())])
  
  private var isShareEnabled: Bool = false {
    didSet {
      shareButton.alpha = isShareEnabled ? 1.0: 0.5
    }
  }
  
  private var viewModel: LeaveAFeedbackFormViewModelProtocol!
  
  fileprivate func configure(viewModel: LeaveAFeedbackFormViewModelProtocol) {
    self.viewModel = viewModel
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()

    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    generateLeftNavigationButton(image: isPushed ? .icLeftArrow: .icClose, selector: #selector(popOrDismissViewController))
  }
  
  @objc
  private func choiceTapped(_ sender: UIButton) {
    buttonChoices.forEach { (button) in
      button.isSelected = sender == button
    }
    let choice = viewModel.type.choices[sender.tag]
    viewModel.feedback.feedback = choice
    if viewModel.feedback.feedback == "Others", feedbackTextView.text.isEmpty {
      feedbackTextView.becomeFirstResponder()
    } else {
      feedbackTextView.resignFirstResponder()
    }
    feedbackTextView.borderColor = .whiteThree
    hideErrorIndicator()
  }
  
  @IBAction private func allowShareTapped(_  sender: UIButton) {
    sender.isSelected = !sender.isSelected
    isShareEnabled = sender.isSelected
    AppUserDefaults.allowToShareFeedbackSocial = sender.isSelected
  }
  
  @IBAction private func infoDisclosureTapped(_ sender: Any) {
    showTermsAndConditions()
  }
  
  @IBAction private func shareTapped(_ sender: Any) {
    guard AppUserDefaults.allowToShareFeedbackSocial else { return }
    let rating = Int(viewModel.feedback.rating ?? 0)
    var message = "\(rating) "
    for indx in (1...5) {
      if indx <= rating {
        message.append("\u{2b50}")
      }
    }
    message.append("\n")
    if viewModel.feedback.feedback == "Others", !feedbackTextView.text.isEmpty {
      message.append("\(feedbackTextView.text ?? "")")
    } else {
      message.append([viewModel.feedback.feedback, feedbackTextView.text].compactMap({ $0 }).joined(separator: ": "))
    }
    var shareItems: [SocialHandler.ShareItem] = []
    attachmentCollectionView.images.forEach { (image) in
      shareItems.append(.image(image))
    }
    shareItems.append(.url(viewModel.url))
    shareItems.append(.message(message))
    guard !shareItems.isEmpty else { return }
    SocialHandler.shared.showShareActivity(items: shareItems)
  }
  
  @IBAction private func submitTapped(_ sender: Any) {
    if (viewModel.feedback.feedback ?? "").isEmpty {
      showError(message: "Please select a choice.")
    } else if viewModel.feedback.feedback == "Others", feedbackTextView.text.isEmpty {
      errorContainerView = feedbackTextView
      errorDescription = "This field is required."
      feedbackTextView.borderColor = .coral
      showErrorIndicator()
    } else {
      let newImages = attachmentCollectionView.images
      guard (attachmentCollectionView.attachments.count) == newImages.count else {
        showError(message: "Images not loaded.")
        return
      }
      viewModel.attachments = newImages.map({ AttachmentData(image: $0, imageURL: nil) })
      viewModel.submit()
    }
  }
}

// MARK: - NavigationProtocol
extension LeaveAFeedbackFormViewController: NavigationProtocol {
}

// MARK: - LeaveAFeedbackCompletionPresenterProtocol
extension LeaveAFeedbackFormViewController: LeaveAFeedbackCompletionPresenterProtocol {
}

// MARK: - TACsPresenterProtocol
extension LeaveAFeedbackFormViewController: TACsPresenterProtocol {
}

// MARK: - ControllerProtocol
extension LeaveAFeedbackFormViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("LeaveAFeedbackFormViewController segueIdentifier not set")
  }
  
  public func setupUI() {
    navigationItem.title = viewModel.type.navigationTitle.uppercased()
    switch viewModel.type {
    case .tellUsMore:
      socialStack.isHidden = false
    case .reportAnIssue:
      socialStack.isHidden = true
    }
    titleLabel.attributedText = viewModel.type.title.attributed.add(.appearance(AttributedTitleAppearance()))
    feedbackPlaceholder.text = viewModel.type.placeholder
    buttonChoices.forEach { (button) in
      choicesStack.addArrangedSubview(button)
    }
  }
  
  public func setupController() {
    viewModel.attachView(self)
    viewModel.initialize()
  }
  
  public func setupObservers() {
    observeTapToDismiss(view: view)
    observeKeyboard()
    attachmentCollectionView.addAttachmentDidTapped = { [weak self] in
      guard let `self` = self else { return }
      var config = YPImagePickerConfiguration.shared
      config.targetImageSize = .cappedTo(size: 1024.0)
      config.startOnScreen = .library
      config.screens = [.library, .photo]
      config.library.mediaType = .photo
      config.library.onlySquare = false
      config.library.maxNumberOfItems = 6 - self.attachmentCollectionView.attachments.count
      let picker = YPImagePicker(configuration: config)
      picker.didFinishPicking { [weak picker, weak self] (items, _) in
        guard let `picker` = picker, let `self` = self else { return  }
        self.attachmentCollectionView.isLoading = true
        var images: [UIImage] = []
        items.forEach { (item) in
          switch item {
          case .photo(let photo):
            images.append(photo.image)
          case .video: break
          }
        }
        self.attachmentCollectionView.isLoading = false
        self.attachmentCollectionView.attachments.append(contentsOf: images.map({ AttachmentData(image: $0, imageURL: nil) }))
        picker.dismiss(animated: true, completion: nil)
      }
      self.present(picker, animated: true, completion: nil)
    }
    attachmentCollectionView.attachmentDidTapped = { [weak self] (refView, image) in
      guard let `self` = self else { return }
      let photoViewerViewController = DTPhotoViewerController(referencedView: refView, image: image)
      self.present(photoViewerViewController, animated: true) {
      }
    }
  }
}

// MARK: - LeaveAFeedbackFormView
extension LeaveAFeedbackFormViewController: LeaveAFeedbackFormView {
  public func reload() {
    if let indx = viewModel.type.choices.enumerated().first(where: { $0.element == viewModel.feedback.feedback })?.offset {
      buttonChoices.enumerated().forEach { (_indx, button) in
        button.isSelected = indx == _indx
      }
    }
    attachmentCollectionView.attachments = viewModel.attachments ?? []
    feedbackTextView.text = viewModel.feedback.feedbackDetails
    feedbackPlaceholder.isHidden = !feedbackTextView.text.isEmpty
    allowShareButton.isSelected = AppUserDefaults.allowToShareFeedbackSocial
  }
  
  public func showLoading() {
    appDelegate.showLoading()
  }
  
  public func hideLoading() {
    appDelegate.hideLoading()
  }
  
  public func showError(message: String?) {
    showAlert(title: "Oops!", message: message)
  }
  
  public func showSuccess(message: String?) {
    var handler = LeaveAFeedbackCompletionHandler()
    handler.image = .icBigCheck
    handler.message = message ?? "Thank you for your feedback! We're always striving to do better for you."
    handler.completion = { [weak self] in
      guard let `self` = self else { return }
      self.popOrDismissViewController()
    }
    showLeaveAFeedbackCompletion(handler: handler) 
  }
}

// MARK: - TapToDismissProtocol
extension LeaveAFeedbackFormViewController: TapToDismissProtocol {
  public func handleTapToDismiss(_ tapGesture: UITapGestureRecognizer) {
    view.endEditing(true)
  }
}

// MARK: - KeyboardHandlerProtocol
extension LeaveAFeedbackFormViewController: KeyboardHandlerProtocol {
  public func keyboardWillHide(_ notification: Notification) {
    scrollView.contentInset = .zero
  }
  
  public func keyboardWillShow(_ notification: Notification) {
    let height = evaluateKeyboardFrameFromNotification(notification).height - (tabBarController?.tabBar.bounds.height ?? 0)
    scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: height, right: 0.0)
  }
}

// MARK: - UITextViewDelegate
extension LeaveAFeedbackFormViewController: UITextViewDelegate {
  public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    feedbackPlaceholder.isHidden = true
    feedbackTextView.borderColor = .whiteThree
    hideErrorIndicator()
    return true
  }
  
  public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
    feedbackPlaceholder.isHidden = !textView.text.isEmpty
    return true
  }
  
  public func textViewDidChange(_ textView: UITextView) {
    viewModel.feedback.feedbackDetails = textView.text
  }
}

public protocol LeaveAFeedbackFormPresenterProtocol {
}

extension LeaveAFeedbackFormPresenterProtocol where Self: ControllerProtocol & UIViewController {
  public func showLeaveAFeedbackForm(type: FeedbackType, feedback: FeedbackData, animated: Bool = true) {
    let leaveAFeedbackFormViewController = UIStoryboard.get(.feedback).getController(LeaveAFeedbackFormViewController.self)
    leaveAFeedbackFormViewController.configure(viewModel: LeaveAFeedbackFormViewModel(type: type, feedback: feedback))
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(leaveAFeedbackFormViewController, animated: animated)
    } else {
      let navigationController = NavigationController(rootViewController: leaveAFeedbackFormViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
  }
}
