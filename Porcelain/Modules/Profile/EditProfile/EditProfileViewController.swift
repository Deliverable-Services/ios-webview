//
//  EditProfileViewController.swift
//  Porcelain
//
//  Created by Jean on 6/16/18.
//  Copyright © 2018 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import YPImagePicker

public final class EditProfileViewController: UIViewController, TapToDismissProtocol {
  @IBOutlet private weak var scrollView: UIScrollView!
  @IBOutlet private weak var profileImageContainerView: DesignableView!
  @IBOutlet private weak var profileImageView: LoadingImageView! {
    didSet {
      profileImageView.contentMode = .scaleAspectFill
      profileImageView.placeholderImage = .imgProfilePlaceholder
    }
  }
  @IBOutlet private weak var firstNameInputView: PPInputView! {
    didSet {
      firstNameInputView.title = "First Name"
      firstNameInputView.textContentType = .givenName
      firstNameInputView.type = .text
    }
  }
  @IBOutlet private weak var lastNameInputView: PPInputView! {
    didSet {
      lastNameInputView.title = "Last Name"
      lastNameInputView.textContentType = .familyName
      lastNameInputView.type = .text
    }
  }
  @IBOutlet private weak var emailInputView: PPInputView! {
    didSet {
      emailInputView.title = "Email"
      emailInputView.textContentType = .emailAddress
      emailInputView.type = .email
    }
  }
  @IBOutlet private weak var phoneInputView: PPInputView! {
    didSet {
      phoneInputView.title = "Contact Info"
      phoneInputView.textContentType = .telephoneNumber
      phoneInputView.type = .phone
    }
  }
  @IBOutlet private weak var birthdayInputView: PPInputView! {
    didSet {
      birthdayInputView.title = "Birthday"
      birthdayInputView.type = .birthdate
    }
  }
  @IBOutlet private weak var genderInputView: PPInputView! {
    didSet {
      genderInputView.title = "Gender"
      genderInputView.type = .gender
    }
  }
  @IBOutlet private weak var addressInputView: PPInputView! {
    didSet {
      addressInputView.title = "Address"
      addressInputView.textContentType = .streetAddressLine1
      addressInputView.type = .text
    }
  }
  @IBOutlet private weak var postalCodeInputView: PPInputView! {
    didSet {
      postalCodeInputView.title = "Postal Code"
      postalCodeInputView.textContentType = .postalCode
      postalCodeInputView.type = .number
    }
  }
  @IBOutlet private weak var updateContainerView: UIView!
  @IBOutlet private weak var updateButton: DesignableButton! {
    didSet {
      updateButton.cornerRadius = 7.0
      updateButton.backgroundColor = .greyblue
      updateButton.setAttributedTitle("UPDATE".attributed.add(.appearance(FormSaveButtonAttributedTitleAppearance())), for: .normal)
    }
  }
  
  private var viewModel: EditProfileViewModelProtocol!
  
  public func configure(viewModel: EditProfileViewModelProtocol) {
    self.viewModel = viewModel
  }
  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    profileImageContainerView.cornerRadius = profileImageContainerView.bounds.width/2.0
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()

    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    updateSelectedPhoneCountryIfNeeded()
  }
  
  private func updateSelectedPhoneCountryIfNeeded() {
    if let phoneCode = viewModel.phoneCode {
      SelectCountryService.getCountry(query: .phoneCode(value: phoneCode)) { (country) in
        self.phoneInputView.country = country
      }
    } else {
      SelectCountryService.getDefaultCountry { (country) in
        self.phoneInputView.country = country
      }
    }
  }
  
  public func handleTapToDismiss(_ tapGesture: UITapGestureRecognizer) {
    view.endEditing(true)
  }
  
  @IBAction private func cameraTapped(_ sender: Any) {
    var config = YPImagePickerConfiguration.shared
    config.targetImageSize = .cappedTo(size: 300.0)
    config.screens = [.library, .photo]
    config.onlySquareImagesFromCamera = true
    config.library.mediaType = .photo
    config.library.onlySquare = true
    config.library.maxNumberOfItems = 1
    let picker = YPImagePicker(configuration: config)
    picker.didFinishPicking { [weak picker, weak self] (items, _) in
      guard let `picker` = picker, let `self` = self else { return  }
      if let photo = items.singlePhoto, let data = photo.image.data {
        self.viewModel.updateAvatar(imageData: data)
      } else {
        self.showError(message: "Image could not be loaded.")
      }
      picker.dismiss(animated: true, completion: nil)
    }
    present(picker, animated: true, completion: nil)
  }
  
  @IBAction private func updateTapped(_ sender: Any) {
    viewModel.firstName = firstNameInputView.text
    viewModel.lastName = lastNameInputView.text
    viewModel.email = emailInputView.text
    viewModel.phoneCode = phoneInputView.country?.phoneCode
    viewModel.phone = phoneInputView.text
    viewModel.birthDate = birthdayInputView.date
    viewModel.gender = genderInputView.gender
    viewModel.address = addressInputView.text
    viewModel.postalCode = postalCodeInputView.text
    viewModel.update()
  }
}

// MARK: - NavigationProtocol
extension EditProfileViewController: NavigationProtocol {
}

// MARK: - ControllerProtocol
extension EditProfileViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("EditProfileViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: .icLeftArrow, selector: #selector(popViewController))
    viewModel.attachView(self)
    viewModel.initialize()
  }
  
  public func setupObservers() {
    observeKeyboard()
    observeTapToDismiss(view: view)
    phoneInputView.phoneCodeDidTapped = { [weak self] in
      guard let `self` = self else { return }
      let handler = SelectCountryHandler()
      handler.didSelectCountry = { [weak self] (country) in
        guard let `self` = self else  { return }
        self.phoneInputView.country = country
        self.phoneInputView.becomeFirstResponder()
      }
      SelectCountryViewController.load(handler: handler, in: self)
    }
  }
}

// MARK: - EditProfileView
extension EditProfileViewController: EditProfileView {
  public func reload(section: EditProfileSection) {
    switch section {
    case .updateAvatar:
      profileImageView.url = viewModel.avatar
    case .updateProfile:
      firstNameInputView.text = viewModel.firstName
      lastNameInputView.text = viewModel.lastName
      emailInputView.text = viewModel.email
      phoneInputView.text = viewModel.phone
      phoneInputView.isUserInteractionEnabled = viewModel.phone == nil
      birthdayInputView.date = viewModel.birthDate
      genderInputView.gender = viewModel.gender
      addressInputView.text = viewModel.address
      postalCodeInputView.text = viewModel.postalCode
    }
  }
  
  public func showLoading(section: EditProfileSection) {
    switch section {
    case .updateAvatar:
      appDelegate.showLoading()
    case .updateProfile:
      appDelegate.showLoading()
    }
  }
  
  public func hideLoading(section: EditProfileSection) {
    switch section {
    case .updateAvatar:
      appDelegate.hideLoading()
    case .updateProfile:
      appDelegate.hideLoading()
    }
  }
  
  public func showError(message: String?) {
    showAlert(title: "Oops!", message: message)
  }
  
  public func successUpdate() {
    popViewController()
  }
}

// MARK: - KeyboardHandlerProtocol
extension EditProfileViewController: KeyboardHandlerProtocol {
  public func keyboardWillHide(_ notification: Notification) {
    scrollView.contentInset = .zero
  }
  
  public func keyboardWillShow(_ notification: Notification) {
    let height = evaluateKeyboardFrameFromNotification(notification).height - (view.safeAreaInsets.bottom + updateContainerView.bounds.height)
    scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: height, right: 0.0)
  }
}

public protocol EditProfilePresenterProtocol {
}

extension EditProfilePresenterProtocol where Self: ControllerProtocol & UIViewController {
  public func showEditProfile(customer: Customer, animated: Bool = true) {
    let editProfileViewController = UIStoryboard.get(.profile).getController(EditProfileViewController.self)
    editProfileViewController.configure(viewModel: EditProfileViewModel(customer: customer))
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(editProfileViewController, animated: animated)
    } else {
      let navigationController = NavigationController(rootViewController: editProfileViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
  }
}
