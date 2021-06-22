//
//  MyProductCompletionViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 28/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import Cosmos
import R4pidKit

private struct AttributedSubtitleAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? = 0.5
  var alignment: NSTextAlignment? = .center
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat? = 21.0
  var font: UIFont? = .openSans(style: .regular(size: 14.0))
  var color: UIColor? = .bluishGrey
}

private struct AttributedRemoveDescriptionAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? = 0.43
  var alignment: NSTextAlignment? = .left
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat? = 21.0
  var font: UIFont? = .openSans(style: .regular(size: 13.0))
  var color: UIColor? = .bluishGrey
}

public final class MyProductCompletionViewController: UIViewController {
  @IBOutlet private weak var closeButton: UIButton! {
     didSet {
       closeButton.setImage(.icClose, for: .normal)
     }
   }
  @IBOutlet private weak var scrollView: ObservingContentScrollView! {
    didSet {
      scrollView.alwaysBounceVertical = false
    }
  }
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .idealSans(style: .book(size: 18.0))
      titleLabel.textColor = .gunmetal
      titleLabel.text = "Done with this product?"
    }
  }
  @IBOutlet private weak var reviewStack: UIStackView!
  @IBOutlet private weak var subtitleLabel: UILabel! {
    didSet {
      subtitleLabel.attributedText = """
        We hope you enjoyed it!
        Please leave us a review to share the love
        """.attributed.add(.appearance(AttributedSubtitleAppearance()))
    }
  }
  @IBOutlet private weak var ratingView: CosmosView! {
    didSet {
      ratingView.rating = 0.0
    }
  }
  @IBOutlet private weak var placeholderLabel: UILabel!
  @IBOutlet private weak var textView: DesignableTextView! {
    didSet {
      textView.typingAttributes = defaultTypingAttributes
      textView.textContainer.lineFragmentPadding = 0
      textView.delegate = self
    }
  }
  @IBOutlet private weak var sendButton: DesignableButton! {
    didSet {
      sendButton.setAttributedTitle(
        "SEND".attributed.add(.appearance(DialogButtonAttributedTitleAppearance())),
        for: .normal)
      var appearance = ShadowAppearance.default
      appearance.fillColor = .greyblue
      sendButton.shadowAppearance = appearance
    }
  }
  @IBOutlet private weak var reviewSuccesStack: UIStackView!
  @IBOutlet private weak var removeDescriptionLabel: UILabel! {
      didSet {
        removeDescriptionLabel.attributedText = """
          Clicking the DONE button means you’ve finished your products list to help you track what you have hand at home.

          If you would like to see what you had previously purchased, you can refer to Purchase History.
          """.attributed.add(.appearance(AttributedRemoveDescriptionAppearance()))
          .add([.font(.openSans(style: .semiBold(size: 13.0)))], text: "DONE")
          .add([.color(.lightNavy), .font(.openSans(style: .semiBold(size: 13.0)))], text: "Purchase History")
      }
    }
  @IBOutlet private weak var removeProductButton: DesignableButton! {
    didSet {
      removeProductButton.cornerRadius = 7.0
      removeProductButton.borderColor = .coral
      removeProductButton.borderWidth = 1.0
      var appearance = DialogButtonAttributedTitleAppearance()
      appearance.color = .coral
      removeProductButton.setAttributedTitle(
      "REMOVE PRODUCT".attributed.add(.appearance(appearance)),
      for: .normal)
    }
  }
  
  fileprivate var productID: String!
  
  private var isReviewSuccess: Bool = false {
    didSet {
      reviewStack.isHidden = isReviewSuccess
      reviewSuccesStack.isHidden = !reviewStack.isHidden
    }
  }
  
  private lazy var defaultTypingAttributes = NSAttributedString.createAttributesString([.appearance(DefaultTextViewTextAppearance())])
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  @IBAction private func closeTapped(_ sender: Any) {
    dismissPresenter()
  }
  
  @IBAction private func sendTapped(_ sender: Any) {
    guard let customer = AppUserDefaults.customer, let email = customer.email else {
      showAlert(title: "Oops!", message: "Customer email is missing.")
      return
    }
    textView.resignFirstResponder()
    guard !textView.text.isEmpty else {
      textView.borderColor = .coral
      return
    }
    var request: [APIServiceConstant.Key: Any] = [:]
    request[.review] = textView.text
    request[.reviewer] = [customer.firstName, customer.lastName].compactMap({ $0 }).joined(separator: " ")
    request[.email] = email
    request[.rating] = Int(ratingView.rating)
    sendButton.isLoading = true
    PPAPIService.Product.createProductReview(productID: productID, request: request).call { (response) in
      switch response {
      case .success:
        self.sendButton.isLoading = false
        self.isReviewSuccess = true
      case .failure(let error):
        self.sendButton.isLoading = false
        self.isReviewSuccess = false
        self.showAlert(title: "Oops!", message: error.localizedDescription)
      }
    }
  }
  
  @IBAction private func removeFromListTapped(_ sender: Any) {
    appDelegate.showLoading()
    PPAPIService.User.consumeMyProduct(productID: productID).call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customerID = AppUserDefaults.customerID else { return }
          guard let product = CustomerProduct.getProduct(id: self.productID, customerID: customerID, inMOC: moc) else { return }
          product.quantity = max(0, product.quantity - 1)
        }, completion: { (_) in
          appDelegate.hideLoading()
          self.dismissPresenter()
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            appDelegate.showAlert(title: nil, message: result.message)
          }
        })
      case .failure(let error):
        appDelegate.hideLoading()
        self.showAlert(title: "Oops!", message: error.localizedDescription)
      }
    }
  }
}
// MARK: - PresentedControllerProtocol
extension MyProductCompletionViewController: PresentedControllerProtocol {
  public var presenterType: PresenterType? {
    return .popover(size: CGSize(width: 327.0, height: scrollView.contentSize.height))
  }
}

// MARK: - ControllerProtocol
extension MyProductCompletionViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("MyProductCompletionViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    isReviewSuccess = false
  }
  
  public func setupObservers() {
    scrollView.observeContentSizeUpdates = { [weak self] (_) in
      guard let `self` = self else { return }
      self.reloadPresenter()
    }
  }
}

// MARK: - UITextViewDelegate
extension MyProductCompletionViewController: UITextViewDelegate {
  public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    self.textView.borderColor = .whiteThree
    placeholderLabel.isHidden = true
    return true
  }
  
  public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
    placeholderLabel.isHidden = !textView.text.isEmpty
    return true
  }
}

public protocol MyProductCompletionPresenterProtocol {
}

extension MyProductCompletionPresenterProtocol where Self: ControllerProtocol & UIViewController {
  @discardableResult
  public func showMyProductCompletion(productID: String, animated: Bool = true) -> MyProductCompletionViewController {
    let myProductCompletionViewController = UIStoryboard.get(.projectPorcelain).getController(MyProductCompletionViewController.self)
    myProductCompletionViewController.productID = productID
    let appearance = PresenterAppearance.default
    PresenterViewController.show(
      presentVC: myProductCompletionViewController,
      settings: [
        .appearance(appearance)],
      onVC: self)
    return myProductCompletionViewController
  }
}
