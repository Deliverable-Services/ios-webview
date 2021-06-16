//
//  MyProductRemoveViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 28/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct AttributedDescriptionAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? {
    return 0.45
  }
  var alignment: NSTextAlignment? {
    return .center
  }
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat? {
    return 24.0
  }
  var font: UIFont? {
    return .idealSans(style: .book(size: 18.0))
  }
  var color: UIColor? {
    return .gunmetal
  }
}

public struct MyProductRemoveData {
  var product: CustomerProduct
  var removeQuantity: Int
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

public final class MyProductRemoveViewController: UIViewController {
  @IBOutlet private weak var scrollView: UIScrollView!
  @IBOutlet private weak var descriptionLabel: UILabel!
  @IBOutlet private weak var firstButton: UIButton! {
    didSet {
      firstButton.setAttributedTitle(
        UIImage.icCheckBoxUnSelected.attributed.add(.baseline(offset: -3.0)).append(
          attrs: "    Buying this as a gift".attributed.add([
            .color(.gunmetal),
            .font(.openSans(style: .regular(size: 13.0))),
            .baseline(offset: 3.0)])),
        for: .normal)
      firstButton.setAttributedTitle(
        UIImage.icCheckBoxSelected.attributed.add(.baseline(offset: -3.0)).append(
          attrs: "    Buying this as a gift".attributed.add([
            .color(.gunmetal),
            .font(.openSans(style: .regular(size: 13.0))),
            .baseline(offset: 3.0)])),
        for: .selected)
    }
  }
  @IBOutlet private weak var secondButton: UIButton! {
    didSet {
      secondButton.setAttributedTitle(
        UIImage.icCheckBoxUnSelected.attributed.add(.baseline(offset: -3.0)).append(
          attrs: "    Currently ran out of the product".attributed.add([
            .color(.gunmetal),
            .font(.openSans(style: .regular(size: 13.0))),
            .baseline(offset: 3.0)])),
        for: .normal)
      secondButton.setAttributedTitle(
        UIImage.icCheckBoxSelected.attributed.add(.baseline(offset: -3.0)).append(
          attrs: "    Currently ran out of the product".attributed.add([
            .color(.gunmetal),
            .font(.openSans(style: .regular(size: 13.0))),
            .baseline(offset: 3.0)])),
        for: .selected)
    }
  }
  @IBOutlet private weak var thirdButton: UIButton! {
    didSet {
      thirdButton.setAttributedTitle(
        UIImage.icCheckBoxUnSelected.attributed.add(.baseline(offset: -3.0)).append(
          attrs: "    Product is not suitable for my skin".attributed.add([
            .color(.gunmetal),
            .font(.openSans(style: .regular(size: 13.0))),
            .baseline(offset: 3.0)])),
        for: .normal)
      thirdButton.setAttributedTitle(
        UIImage.icCheckBoxSelected.attributed.add(.baseline(offset: -3.0)).append(
          attrs: "    Product is not suitable for my skin".attributed.add([
            .color(.gunmetal),
            .font(.openSans(style: .regular(size: 13.0))),
            .baseline(offset: 3.0)])),
        for: .selected)
    }
  }
  @IBOutlet private weak var fourthButton: UIButton! {
    didSet {
      fourthButton.setAttributedTitle(
        UIImage.icCheckBoxUnSelected.attributed.add(.baseline(offset: -3.0)).append(
          attrs: "    Allergic/Reaction towards the product".attributed.add([
            .color(.gunmetal),
            .font(.openSans(style: .regular(size: 13.0))),
            .baseline(offset: 3.0)])),
        for: .normal)
      fourthButton.setAttributedTitle(
        UIImage.icCheckBoxSelected.attributed.add(.baseline(offset: -3.0)).append(
          attrs: "    Allergic/Reaction towards the product".attributed.add([
            .color(.gunmetal),
            .font(.openSans(style: .regular(size: 13.0))),
            .baseline(offset: 3.0)])),
        for: .selected)
    }
  }
  @IBOutlet private weak var separatorView: UIView! {
    didSet {
      separatorView.backgroundColor = .whiteThree
    }
  }
  @IBOutlet private weak var othersButton: UIButton! {
    didSet {
      othersButton.setAttributedTitle(
        UIImage.icCheckBoxUnSelected.attributed.add(.baseline(offset: -3.0)).append(
          attrs: "    Others".attributed.add([
            .color(.gunmetal),
            .font(.openSans(style: .regular(size: 13.0))),
            .baseline(offset: 3.0)])),
        for: .normal)
      othersButton.setAttributedTitle(
        UIImage.icCheckBoxSelected.attributed.add(.baseline(offset: -3.0)).append(
          attrs: "    Others".attributed.add([
            .color(.gunmetal),
            .font(.openSans(style: .regular(size: 13.0))),
            .baseline(offset: 3.0)])),
        for: .selected)
    }
  }
  @IBOutlet private weak var placeholderLabel: UILabel!
  @IBOutlet private weak var textView: DesignableTextView! {
    didSet {
      textView.cornerRadius = 7.0
      textView.borderColor = .whiteThree
      textView.borderWidth = 1.0
      textView.topMargin = 8.0
      textView.leftMargin = 12.0
      textView.rightMargin = 12.0
      textView.bottomMargin = 8.0
      textView.tintColor = .gunmetal
      textView.typingAttributes = defaultTypingAttributes
      textView.delegate = self
    }
  }
  @IBOutlet private weak var removeContainerView: UIView!
  @IBOutlet private weak var removeButton: DesignableButton! {
    didSet {
      removeButton.cornerRadius = 7.0
      removeButton.backgroundColor = .greyblue
      removeButton.setAttributedTitle(
        "REMOVE".attributed.add(.appearance(DialogButtonAttributedTitleAppearance())),
        for: .normal)
    }
  }
  
  private lazy var choiceButtons: [UIButton] = [firstButton, secondButton, thirdButton, fourthButton, othersButton]
  
  private lazy var defaultTypingAttributes = NSAttributedString.createAttributesString([.appearance(AttributedTextAppearance())])
  
  public var data: MyProductRemoveData?
  
  public override func viewDidLoad() {
    super.viewDidLoad()
  
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    hideBarSeparator()
  }
  
  @IBAction private func choicesTapped(_ sender: UIButton) {
    choiceButtons.forEach { (button) in
      button?.isSelected = button == sender
    }
    if othersButton == sender, textView.text.isEmpty {
      textView.becomeFirstResponder()
    } else {
      textView.borderColor = .whiteThree
    }
  }
  
  @IBAction private func removeTapped(_ sender: Any) {
    guard let productID = data?.product.id else { return }
    guard let removeQuantity = data?.removeQuantity else { return }
    guard let reasonType = choiceButtons.first(where: { $0.isSelected })?.attributedTitle(for: .normal)?.string.clean() else {
      showAlert(title: "Oops!", message: "Please select a choice.")
      return
    }
    guard !(othersButton.isSelected && textView.text.isEmpty) else {
      textView.borderColor = .coral
      return
    }
    var request: [APIServiceConstant.Key: Any] = [:]
    request[.quantity] = removeQuantity
    request[.reasonType] = reasonType
    request[.details] = textView.text
    appDelegate.showLoading()
    PPAPIService.User.removeMyProduct(productID: productID, request: request).call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customerID = AppUserDefaults.customerID else { return }
          guard let product = CustomerProduct.getProduct(id: productID, customerID: customerID, inMOC: moc) else { return }
          product.quantity = product.quantity - Int32(removeQuantity)
        }, completion: { (_) in
          appDelegate.hideLoading()
          self.popOrDismissViewController()
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            appDelegate.showAlert(title: nil, message: result.message)
          }
        })
      case .failure(let error):
        appDelegate.hideLoading()
        appDelegate.showAlert(title: "Oops!", message: error.localizedDescription)
      }
    }
  }
}

// MARK: - NavigationProtocol
extension MyProductRemoveViewController: NavigationProtocol {
}

// MARK: - ControllerProtocol
extension MyProductRemoveViewController: ControllerProtocol  {
  public static var segueIdentifier: String {
    fatalError("MyProductRemoveViewController segueIdentifier not set")
  }
  
  public func setupUI() {
    descriptionLabel.attributedText = """
    Why do you want to remove
    \(data?.removeQuantity ?? 0) \([data?.product.categoryName, data?.product.name].compactMap({ $0 }).joined(separator: ", "))?
    """.attributed.add(.appearance(AttributedDescriptionAppearance()))
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: .icClose, selector: #selector(popOrDismissViewController))
  }
  
  public func setupObservers() {
    observeKeyboard()
  }
}

// MARK: - KeyboardHandlerProtocol
extension MyProductRemoveViewController: KeyboardHandlerProtocol {
  public func keyboardWillHide(_ notification: Notification) {
    scrollView.contentInset = .zero
  }
  
  public func keyboardWillShow(_ notification: Notification) {
    let height = evaluateKeyboardFrameFromNotification(notification).height - (view.safeAreaInsets.bottom + removeContainerView.bounds.height)
    scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: height, right: 0.0)
  }
}

// MARK: - UITextViewDelegate
extension MyProductRemoveViewController: UITextViewDelegate {
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

public protocol MyProductRemovePresenterProtocol {
}

extension MyProductRemovePresenterProtocol where Self: ControllerProtocol & UIViewController {
  @discardableResult
  public func showMyProductRemove(data: MyProductRemoveData, animated: Bool = true) -> MyProductRemoveViewController {
    let myProductRemoveViewController = UIStoryboard.get(.projectPorcelain).getController(MyProductRemoveViewController.self)
    myProductRemoveViewController.data = data
    let navigationController = NavigationController(rootViewController: myProductRemoveViewController)
    if #available(iOS 13.0, *) {
      navigationController.isModalInPresentation = true
    }
    present(navigationController, animated: animated) {
    }
    return myProductRemoveViewController
  }
}
